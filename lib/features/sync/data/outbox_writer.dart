import 'dart:convert';

import '../../../core/database/app_database.dart';

/// Writes outbox rows. Callers must already be inside a transaction so the
/// outbox row commits or rolls back together with the business change.
class OutboxWriter {
  OutboxWriter(this._db, this._now);
  final AppDatabase _db;
  final DateTime Function() _now;

  Future<void> enqueue({
    required EntityType entityType,
    required String entityUuid,
    required OutboxOperation operation,
    required Map<String, Object?> payload,
  }) {
    return _db
        .into(_db.syncOutbox)
        .insert(
          SyncOutboxCompanion.insert(
            entityType: entityType,
            entityUuid: entityUuid,
            operation: operation,
            payloadJson: jsonEncode(payload),
            createdAt: _now(),
          ),
        );
  }
}
