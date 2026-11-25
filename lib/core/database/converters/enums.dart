import 'package:drift/drift.dart';

/// Sync state of a local record or an outbox entry.
enum SyncStatus { pending, synced, failed }

/// Lifecycle of an invoice. Invoices are never deleted, only cancelled.
enum SaleStatus { completed, cancelled }

/// Lifecycle of a goods receipt.
enum PurchaseStatus { completed, cancelled }

enum PaymentMethod { cash, card, wallet }

/// Direction of a stock movement. Stored as IN / OUT / ADJUST.
enum MovementType {
  stockIn('IN'),
  stockOut('OUT'),
  adjust('ADJUST');

  const MovementType(this.code);
  final String code;
}

/// What caused a stock movement. Stored as SALE / PURCHASE / ADJUST / RETURN.
enum ReferenceType {
  sale('SALE'),
  purchase('PURCHASE'),
  adjust('ADJUST'),
  saleReturn('RETURN');

  const ReferenceType(this.code);
  final String code;
}

/// Operation recorded in the sync outbox. Stored as CREATE / UPDATE.
enum OutboxOperation {
  create('CREATE'),
  update('UPDATE');

  const OutboxOperation(this.code);
  final String code;
}

/// Entity kinds the outbox can carry to the cloud.
enum EntityType {
  category('CATEGORY'),
  product('PRODUCT'),
  sale('SALE'),
  purchase('PURCHASE'),
  stockMovement('STOCK_MOVEMENT');

  const EntityType(this.code);
  final String code;
}

class MovementTypeConverter extends TypeConverter<MovementType, String> {
  const MovementTypeConverter();
  @override
  MovementType fromSql(String fromDb) =>
      MovementType.values.firstWhere((e) => e.code == fromDb);
  @override
  String toSql(MovementType value) => value.code;
}

class ReferenceTypeConverter extends TypeConverter<ReferenceType, String> {
  const ReferenceTypeConverter();
  @override
  ReferenceType fromSql(String fromDb) =>
      ReferenceType.values.firstWhere((e) => e.code == fromDb);
  @override
  String toSql(ReferenceType value) => value.code;
}

class OutboxOperationConverter extends TypeConverter<OutboxOperation, String> {
  const OutboxOperationConverter();
  @override
  OutboxOperation fromSql(String fromDb) =>
      OutboxOperation.values.firstWhere((e) => e.code == fromDb);
  @override
  String toSql(OutboxOperation value) => value.code;
}

class EntityTypeConverter extends TypeConverter<EntityType, String> {
  const EntityTypeConverter();
  @override
  EntityType fromSql(String fromDb) =>
      EntityType.values.firstWhere((e) => e.code == fromDb);
  @override
  String toSql(EntityType value) => value.code;
}
