import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors.dart';
import 'stock_ledger.dart';

/// Manual stock corrections (stock-take). Records an ADJUST movement for the
/// difference instead of overwriting the balance.
class InventoryService {
  InventoryService(this._db, this._now) : _ledger = StockLedger(_db, _now);
  final AppDatabase _db;
  final StockLedger _ledger;
  // ignore: unused_field
  final DateTime Function() _now;

  /// Sets the stock to [countedQuantity]. Returns null if nothing changed.
  Future<StockMovement?> adjustStock(
    int productId,
    double countedQuantity, {
    required String note,
  }) {
    if (countedQuantity < 0) {
      throw InvalidOperationException('الكمية لا يمكن أن تكون بالسالب');
    }
    return _db.transaction(() async {
      final p = await (_db.select(
        _db.products,
      )..where((x) => x.id.equals(productId))).getSingleOrNull();
      if (p == null) throw InvalidOperationException('المنتج غير موجود');
      final delta = countedQuantity - p.currentStock;
      if (delta.abs() < 1e-9) return null;
      return _ledger.apply(
        product: p,
        delta: delta,
        type: MovementType.adjust,
        referenceType: ReferenceType.adjust,
        unitCost: p.costPrice,
        note: note,
      );
    });
  }

  Future<List<StockMovement>> movementsOf(int productId) {
    return (_db.select(_db.stockMovements)
          ..where((m) => m.productId.equals(productId))
          ..orderBy([(m) => OrderingTerm.asc(m.id)]))
        .get();
  }
}
