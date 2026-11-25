import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors.dart';
import '../../inventory/data/stock_ledger.dart';
import '../../sync/data/outbox_writer.dart';
import '../../sync/data/payloads.dart';

class PurchaseLine {
  const PurchaseLine({
    required this.productId,
    required this.quantity,
    required this.unitCost,
  });
  final int productId;
  final double quantity;

  /// Piastres per unit.
  final int unitCost;
}

class PurchaseDraft {
  const PurchaseDraft({
    required this.lines,
    this.supplierName,
    this.referenceNumber,
    this.notes,
  });
  final List<PurchaseLine> lines;
  final String? supplierName;
  final String? referenceNumber;
  final String? notes;
}

class PurchaseResult {
  PurchaseResult(this.purchase, this.items);
  final Purchase purchase;
  final List<PurchaseItem> items;
}

/// Goods receipt: raises stock, records IN movements and updates the product
/// cost using a weighted average, all in ONE transaction.
class PurchaseService {
  PurchaseService(this._db, this._now)
    : _ledger = StockLedger(_db, _now),
      _outbox = OutboxWriter(_db, _now);

  final AppDatabase _db;
  final DateTime Function() _now;
  final StockLedger _ledger;
  final OutboxWriter _outbox;
  static const _uuid = Uuid();

  Future<PurchaseResult> receive(PurchaseDraft draft) {
    if (draft.lines.isEmpty) {
      throw InvalidOperationException('إذن الاستلام فاضي');
    }
    for (final l in draft.lines) {
      if (l.quantity <= 0 || l.unitCost < 0) {
        throw InvalidOperationException('الكمية أو التكلفة غير صحيحة');
      }
    }

    return _db.transaction(() async {
      final now = _now();
      final purchaseUuid = _uuid.v4();
      final total = draft.lines.fold<int>(
        0,
        (sum, l) => sum + (l.quantity * l.unitCost).round(),
      );

      final purchase = await _db
          .into(_db.purchases)
          .insertReturning(
            PurchasesCompanion.insert(
              localUuid: purchaseUuid,
              referenceNumber: Value(draft.referenceNumber),
              date: now,
              supplierName: Value(draft.supplierName),
              total: total,
              notes: Value(draft.notes),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final items = <PurchaseItem>[];
      final touched = <int, String>{};
      for (final l in draft.lines) {
        final p = await _product(l.productId);
        touched[p.id] = p.localUuid;
        items.add(
          await _db
              .into(_db.purchaseItems)
              .insertReturning(
                PurchaseItemsCompanion.insert(
                  localUuid: _uuid.v4(),
                  purchaseId: purchase.id,
                  productId: p.id,
                  productName: p.nameAr ?? p.name,
                  quantity: l.quantity,
                  unitCost: l.unitCost,
                  total: (l.quantity * l.unitCost).round(),
                ),
              ),
        );

        await (_db.update(_db.products)..where((x) => x.id.equals(p.id))).write(
          ProductsCompanion(
            costPrice: Value(
              weightedAverageCost(
                p.currentStock,
                p.costPrice,
                l.quantity,
                l.unitCost,
              ),
            ),
          ),
        );
        await _ledger.apply(
          product: p,
          delta: l.quantity,
          type: MovementType.stockIn,
          referenceType: ReferenceType.purchase,
          referenceUuid: purchaseUuid,
          unitCost: l.unitCost,
          allowNegative: true,
        );
      }

      // Cost prices changed, so the catalog in the cloud must hear about it.
      for (final id in touched.keys) {
        final p = await _product(id);
        await _outbox.enqueue(
          entityType: EntityType.product,
          entityUuid: p.localUuid,
          operation: OutboxOperation.update,
          payload: productPayload(p),
        );
      }
      await _outbox.enqueue(
        entityType: EntityType.purchase,
        entityUuid: purchaseUuid,
        operation: OutboxOperation.create,
        payload: purchasePayload(purchase, items, touched),
      );
      return PurchaseResult(purchase, items);
    });
  }

  Future<Product> _product(int id) async {
    final p = await (_db.select(
      _db.products,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
    if (p == null) throw InvalidOperationException('المنتج غير موجود');
    return p;
  }
}

/// Moving weighted-average cost. Negative or zero old stock is ignored so a
/// shortfall never drags the cost down.
int weightedAverageCost(double oldQty, int oldCost, double inQty, int inCost) {
  if (oldQty <= 0) return inCost;
  return ((oldQty * oldCost + inQty * inCost) / (oldQty + inQty)).round();
}
