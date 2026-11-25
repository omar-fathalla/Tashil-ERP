import 'package:drift/drift.dart';

import '../converters/enums.dart';

/// Columns every syncable table carries from day one, so the schema never
/// needs restructuring when cloud sync is switched on.
mixin SyncColumns on Table {
  /// Globally unique id; the cloud uses this, never the local integer id.
  TextColumn get localUuid => text().unique()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus =>
      textEnum<SyncStatus>().withDefault(Constant(SyncStatus.pending.name))();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}
