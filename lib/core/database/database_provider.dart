import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Single database instance for the whole app. Tests override this with an
/// in-memory database.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(driftDatabase(name: 'tashil_erp'));
  ref.onDispose(db.close);
  return db;
});

/// Injectable clock so tests can control "now".
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
