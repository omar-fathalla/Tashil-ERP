import 'package:drift/drift.dart';

import '../converters/enums.dart';

/// Queue of finished operations waiting to be pushed to the cloud.
/// Written in the same transaction as the business change it describes.
@DataClassName('OutboxEntry')
class SyncOutbox extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text().map(const EntityTypeConverter())();
  TextColumn get entityUuid => text()();
  TextColumn get operation => text().map(const OutboxOperationConverter())();
  TextColumn get payloadJson => text()();
  TextColumn get status =>
      textEnum<SyncStatus>().withDefault(Constant(SyncStatus.pending.name))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}
