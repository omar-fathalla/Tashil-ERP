import 'package:drift/drift.dart';

import '../converters/enums.dart';
import 'catalog_tables.dart';
import 'sync_columns.dart';

/// Append-only audit trail of every stock change.
class StockMovements extends Table with SyncColumns {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  TextColumn get type => text().map(const MovementTypeConverter())();

  /// Signed change applied to currentStock (+ for IN, - for OUT).
  RealColumn get quantity => real()();
  IntColumn get unitCost => integer().withDefault(const Constant(0))();
  TextColumn get referenceType => text().map(const ReferenceTypeConverter())();
  TextColumn get referenceUuid => text().nullable()();
  TextColumn get note => text().nullable()();

  /// Balance right after this movement, handy for audits.
  RealColumn get balanceAfter => real()();
}
