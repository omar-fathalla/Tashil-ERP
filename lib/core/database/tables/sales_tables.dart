import 'package:drift/drift.dart';

import '../converters/enums.dart';
import 'catalog_tables.dart';
import 'sync_columns.dart';

class Sales extends Table with SyncColumns {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get invoiceNumber => text().unique()();
  DateTimeColumn get date => dateTime()();
  IntColumn get subTotal => integer()();
  IntColumn get discount => integer().withDefault(const Constant(0))();
  IntColumn get tax => integer().withDefault(const Constant(0))();
  IntColumn get total => integer()();
  TextColumn get paymentMethod => textEnum<PaymentMethod>()();
  TextColumn get status =>
      textEnum<SaleStatus>().withDefault(Constant(SaleStatus.completed.name))();
  TextColumn get customerName => text().nullable()();
  TextColumn get notes => text().nullable()();
}

/// Name and prices are snapshots taken at sale time, so editing a product
/// later never changes old invoices.
class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get localUuid => text().unique()();
  IntColumn get saleId => integer().references(Sales, #id)();
  IntColumn get productId => integer().references(Products, #id)();
  TextColumn get productName => text()();
  TextColumn get barcode => text().nullable()();
  RealColumn get quantity => real()();
  IntColumn get unitPrice => integer()();
  IntColumn get costPrice => integer()();
  IntColumn get total => integer()();
}
