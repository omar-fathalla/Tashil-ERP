import 'package:drift/drift.dart';

import 'sync_columns.dart';

class Categories extends Table with SyncColumns {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get description => text().nullable()();
}

/// Money columns are integers in piastres (1 EGP = 100) to avoid
/// floating-point rounding. Quantities are reals so weighed goods (kg) work.
class Products extends Table with SyncColumns {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get barcode => text().nullable().unique()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get nameAr => text().nullable()();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
  IntColumn get costPrice => integer().withDefault(const Constant(0))();
  IntColumn get sellingPrice => integer().withDefault(const Constant(0))();

  /// Running balance. Only ever changed together with a StockMovement row.
  RealColumn get currentStock => real().withDefault(const Constant(0))();
  RealColumn get minStock => real().withDefault(const Constant(0))();
  TextColumn get unit => text().withDefault(const Constant('pcs'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}
