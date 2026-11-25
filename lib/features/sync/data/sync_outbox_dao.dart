import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

/// Read side of the outbox, used by the background sync worker (phase 3).
class SyncOutboxDao {
  SyncOutboxDao(this._db, this._now);
  final AppDatabase _db;
  final DateTime Function() _now;

  /// Oldest first, so the cloud receives operations in the order they happened.
  Future<List<OutboxEntry>> nextBatch({int limit = 50, int maxRetries = 10}) {
    return (_db.select(_db.syncOutbox)
          ..where(
            (o) =>
                o.status.isNotValue(SyncStatus.synced.name) &
                o.retryCount.isSmallerThanValue(maxRetries),
          )
          ..orderBy([(o) => OrderingTerm.asc(o.id)])
          ..limit(limit))
        .get();
  }

  Stream<int> watchPendingCount() {
    final count = _db.syncOutbox.id.count();
    return (_db.selectOnly(_db.syncOutbox)
          ..addColumns([count])
          ..where(_db.syncOutbox.status.isNotValue(SyncStatus.synced.name)))
        .map((row) => row.read(count) ?? 0)
        .watchSingle();
  }

  Future<void> markSynced(List<int> ids) async {
    final now = _now();
    await (_db.update(_db.syncOutbox)..where((o) => o.id.isIn(ids))).write(
      SyncOutboxCompanion(
        status: Value(SyncStatus.synced),
        syncedAt: Value(now),
      ),
    );
  }

  Future<void> markFailed(int id, String error) {
    return _db.customUpdate(
      'UPDATE sync_outbox SET status = ?, retry_count = retry_count + 1, '
      'last_error = ? WHERE id = ?',
      variables: [
        Variable.withString(SyncStatus.failed.name),
        Variable.withString(error),
        Variable.withInt(id),
      ],
      updates: {_db.syncOutbox},
    );
  }
}
