import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors.dart';
import '../../sync/data/outbox_writer.dart';
import '../../sync/data/payloads.dart';

/// The only code path allowed to change Products.currentStock.
/// It always writes the matching StockMovement row and its outbox entry in
/// the same transaction.
class StockLedger {
  StockLedger(this._db, this._now) : _outbox = OutboxWriter(_db, _now);
  final AppDatabase _db;
  final DateTime Function() _now;
  final OutboxWriter _outbox;
  static const _uuid = Uuid();

  /// Applies a signed [delta] to the product's stock and returns the movement.
  /// Runs in its own transaction, or joins the caller's one if there is one.
  Future<StockMovement> apply({
    required Product product,
    required double delta,
    required MovementType type,
    required ReferenceType referenceType,
    String? referenceUuid,
    int unitCost = 0,
    String? note,
    bool allowNegative = false,
  }) {
    return _db.transaction(() async {
      final balanceAfter = product.currentStock + delta;
      if (!allowNegative && balanceAfter < -1e-9) {
        throw InsufficientStockException(
          product.name,
          product.currentStock,
          -delta,
        );
      }
      final now = _now();
      await (_db.update(
        _db.products,
      )..where((p) => p.id.equals(product.id))).write(
        ProductsCompanion(
          currentStock: Value(balanceAfter),
          updatedAt: Value(now),
          syncStatus: const Value(SyncStatus.pending),
        ),
      );
      final movement = await _db
          .into(_db.stockMovements)
          .insertReturning(
            StockMovementsCompanion.insert(
              localUuid: _uuid.v4(),
              productId: product.id,
              type: type,
              quantity: delta,
              unitCost: Value(unitCost),
              referenceType: referenceType,
              referenceUuid: Value(referenceUuid),
              note: Value(note),
              balanceAfter: balanceAfter,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _outbox.enqueue(
        entityType: EntityType.stockMovement,
        entityUuid: movement.localUuid,
        operation: OutboxOperation.create,
        payload: movementPayload(movement, product.localUuid),
      );
      return movement;
    });
  }
}
