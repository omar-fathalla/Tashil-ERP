import 'package:drift/drift.dart';

import '../converters/enums.dart';
import 'catalog_tables.dart';
import 'sync_columns.dart';

/// Goods receipt.
class Purchases extends Table with SyncColumns {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get referenceNumber => text().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get supplierName => text().nullable()();
  IntColumn get total => integer()();
  TextColumn get status => textEnum<PurchaseStatus>().withDefault(
    Constant(PurchaseStatus.completed.name),
  )();
  TextColumn get notes => text().nullable()();
}

class PurchaseItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get localUuid => text().unique()();
  IntColumn get purchaseId => integer().references(Purchases, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  TextColumn get productName => text()();
  RealColumn get quantity => real()();
  IntColumn get unitCost => integer()();
  IntColumn get total => integer()();
}
