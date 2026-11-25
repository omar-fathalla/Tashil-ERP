import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors.dart';
import '../../inventory/data/stock_ledger.dart';
import '../../sync/data/outbox_writer.dart';
import '../../sync/data/payloads.dart';

class SaleLine {
  const SaleLine({
    required this.productId,
    required this.quantity,
    this.unitPrice,
  });
  final int productId;
  final double quantity;

  /// Overrides the product's selling price (piastres) when set.
  final int? unitPrice;
}

class SaleDraft {
  const SaleDraft({
    required this.lines,
    this.paymentMethod = PaymentMethod.cash,
    this.discount = 0,
    this.taxRatePercent = 0,
    this.customerName,
    this.notes,
  });
  final List<SaleLine> lines;
  final PaymentMethod paymentMethod;

  /// Invoice-level discount in piastres.
  final int discount;
  final double taxRatePercent;
  final String? customerName;
  final String? notes;
}

class SaleResult {
  SaleResult(this.sale, this.items);
  final Sale sale;
  final List<SaleItem> items;
}

/// Completes and cancels sales. Each call is ONE database transaction:
/// invoice + items + stock + movements + outbox all commit together or not at all.
class SalesService {
  SalesService(
    this._db,
    this._now, {
    this.deviceCode = 'POS1',
    this.allowNegativeStock = false,
  }) : _ledger = StockLedger(_db, _now),
       _outbox = OutboxWriter(_db, _now);

  final AppDatabase _db;
  final DateTime Function() _now;
  final StockLedger _ledger;
  final OutboxWriter _outbox;

  /// Prefix that keeps invoice numbers unique across devices.
  final String deviceCode;
  final bool allowNegativeStock;
  static const _uuid = Uuid();

  Future<SaleResult> createSale(SaleDraft draft) {
    if (draft.lines.isEmpty) {
      throw InvalidOperationException('الفاتورة فاضية');
    }
    for (final l in draft.lines) {
      if (l.quantity <= 0) {
        throw InvalidOperationException('الكمية لازم تكون أكبر من صفر');
      }
    }
    if (draft.discount < 0 || draft.taxRatePercent < 0) {
      throw InvalidOperationException(
        'الخصم والضريبة لا يمكن أن يكونا بالسالب',
      );
    }

    return _db.transaction(() async {
      final now = _now();
      final saleUuid = _uuid.v4();

      // Load products once and price each line from a snapshot.
      final products = <int, Product>{};
      for (final l in draft.lines) {
        products[l.productId] ??= await _product(l.productId);
      }
      var subTotal = 0;
      final priced = <(SaleLine, Product, int, int)>[];
      for (final l in draft.lines) {
        final p = products[l.productId]!;
        if (!p.isActive) {
          throw InvalidOperationException('المنتج "${p.name}" موقوف');
        }
        final unitPrice = l.unitPrice ?? p.sellingPrice;
        final lineTotal = (l.quantity * unitPrice).round();
        subTotal += lineTotal;
        priced.add((l, p, unitPrice, lineTotal));
      }
      if (draft.discount > subTotal) {
        throw InvalidOperationException('الخصم أكبر من قيمة الفاتورة');
      }
      final taxable = subTotal - draft.discount;
      final tax = (taxable * draft.taxRatePercent / 100).round();

      final sale = await _db
          .into(_db.sales)
          .insertReturning(
            SalesCompanion.insert(
              localUuid: saleUuid,
              invoiceNumber: await _nextInvoiceNumber(now),
              date: now,
              subTotal: subTotal,
              discount: Value(draft.discount),
              tax: Value(tax),
              total: taxable + tax,
              paymentMethod: draft.paymentMethod,
              customerName: Value(draft.customerName),
              notes: Value(draft.notes),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final items = <SaleItem>[];
      for (final (line, p, unitPrice, lineTotal) in priced) {
        items.add(
          await _db
              .into(_db.saleItems)
              .insertReturning(
                SaleItemsCompanion.insert(
                  localUuid: _uuid.v4(),
                  saleId: sale.id,
                  productId: p.id,
                  productName: p.nameAr ?? p.name,
                  barcode: Value(p.barcode),
                  quantity: line.quantity,
                  unitPrice: unitPrice,
                  costPrice: p.costPrice,
                  total: lineTotal,
                ),
              ),
        );
        // Re-read so repeated lines of the same product see the latest stock.
        await _ledger.apply(
          product: await _product(p.id),
          delta: -line.quantity,
          type: MovementType.stockOut,
          referenceType: ReferenceType.sale,
          referenceUuid: saleUuid,
          unitCost: p.costPrice,
          allowNegative: allowNegativeStock,
        );
      }

      await _outbox.enqueue(
        entityType: EntityType.sale,
        entityUuid: saleUuid,
        operation: OutboxOperation.create,
        payload: salePayload(sale, items, {
          for (final p in products.values) p.id: p.localUuid,
        }),
      );
      return SaleResult(sale, items);
    });
  }

  /// Cancels a completed sale: stock comes back through RETURN movements.
  /// Nothing is deleted, so the audit trail stays intact.
  Future<Sale> cancelSale(int saleId, {String? reason}) {
    return _db.transaction(() async {
      final sale = await (_db.select(
        _db.sales,
      )..where((s) => s.id.equals(saleId))).getSingleOrNull();
      if (sale == null) throw InvalidOperationException('الفاتورة غير موجودة');
      if (sale.status == SaleStatus.cancelled) {
        throw InvalidOperationException('الفاتورة ملغية بالفعل');
      }
      final items = await (_db.select(
        _db.saleItems,
      )..where((i) => i.saleId.equals(saleId))).get();
      final uuids = <int, String>{};
      for (final i in items) {
        final p = await _product(i.productId);
        uuids[p.id] = p.localUuid;
        await _ledger.apply(
          product: p,
          delta: i.quantity,
          type: MovementType.stockIn,
          referenceType: ReferenceType.saleReturn,
          referenceUuid: sale.localUuid,
          unitCost: i.costPrice,
          note: reason,
          allowNegative: true,
        );
      }
      final now = _now();
      final updated =
          (await (_db.update(
                _db.sales,
              )..where((s) => s.id.equals(saleId))).writeReturning(
                SalesCompanion(
                  status: const Value(SaleStatus.cancelled),
                  updatedAt: Value(now),
                  syncStatus: const Value(SyncStatus.pending),
                ),
              ))
              .single;
      await _outbox.enqueue(
        entityType: EntityType.sale,
        entityUuid: sale.localUuid,
        operation: OutboxOperation.update,
        payload: salePayload(updated, items, uuids),
      );
      return updated;
    });
  }

  Future<List<SaleItem>> itemsOf(int saleId) =>
      (_db.select(_db.saleItems)..where((i) => i.saleId.equals(saleId))).get();

  Future<Product> _product(int id) async {
    final p = await (_db.select(
      _db.products,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
    if (p == null) throw InvalidOperationException('المنتج غير موجود');
    return p;
  }

  /// e.g. POS1-20261125-0007. Sequence restarts daily per device.
  Future<String> _nextInvoiceNumber(DateTime now) async {
    final d = '${now.year}${_pad2(now.month)}${_pad2(now.day)}';
    final prefix = '$deviceCode-$d-';
    final count = _db.sales.id.count();
    final n =
        await (_db.selectOnly(_db.sales)
              ..addColumns([count])
              ..where(_db.sales.invoiceNumber.like('$prefix%')))
            .map((r) => r.read(count) ?? 0)
            .getSingle();
    return '$prefix${(n + 1).toString().padLeft(4, '0')}';
  }

  static String _pad2(int v) => v.toString().padLeft(2, '0');
}
