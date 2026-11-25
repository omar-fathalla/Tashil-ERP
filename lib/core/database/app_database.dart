import 'package:drift/drift.dart';

import 'converters/enums.dart';
import 'tables/catalog_tables.dart';
import 'tables/inventory_tables.dart';
import 'tables/purchase_tables.dart';
import 'tables/sales_tables.dart';
import 'tables/sync_outbox_table.dart';

export 'converters/enums.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Categories,
    Products,
    StockMovements,
    Sales,
    SaleItems,
    Purchases,
    PurchaseItems,
    SyncOutbox,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        'CREATE INDEX idx_movements_product ON stock_movements (product_id, created_at)',
      );
      await customStatement('CREATE INDEX idx_sales_date ON sales (date)');
      await customStatement(
        'CREATE INDEX idx_outbox_status ON sync_outbox (status, id)',
      );
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
