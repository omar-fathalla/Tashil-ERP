import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/inventory/data/inventory_service.dart';
import '../features/products/data/products_repository.dart';
import '../features/purchases/data/purchase_service.dart';
import '../features/sales/data/sales_service.dart';
import '../features/sync/data/sync_outbox_dao.dart';
import 'database/app_database.dart';
import 'database/database_provider.dart';

export 'database/database_provider.dart';

final productsRepositoryProvider = Provider<ProductsRepository>(
  (ref) => ProductsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
  ),
);

final salesServiceProvider = Provider<SalesService>(
  (ref) =>
      SalesService(ref.watch(appDatabaseProvider), ref.watch(clockProvider)),
);

final purchaseServiceProvider = Provider<PurchaseService>(
  (ref) =>
      PurchaseService(ref.watch(appDatabaseProvider), ref.watch(clockProvider)),
);

final inventoryServiceProvider = Provider<InventoryService>(
  (ref) => InventoryService(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
  ),
);

final syncOutboxDaoProvider = Provider<SyncOutboxDao>(
  (ref) =>
      SyncOutboxDao(ref.watch(appDatabaseProvider), ref.watch(clockProvider)),
);

final lowStockProvider = StreamProvider<List<Product>>(
  (ref) => ref.watch(productsRepositoryProvider).watchLowStock(),
);

final pendingSyncCountProvider = StreamProvider<int>(
  (ref) => ref.watch(syncOutboxDaoProvider).watchPendingCount(),
);
