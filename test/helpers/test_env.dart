import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:tashil_erp/core/database/app_database.dart';
import 'package:tashil_erp/features/inventory/data/inventory_service.dart';
import 'package:tashil_erp/features/products/data/products_repository.dart';
import 'package:tashil_erp/features/purchases/data/purchase_service.dart';
import 'package:tashil_erp/features/sales/data/sales_service.dart';
import 'package:tashil_erp/features/sync/data/sync_outbox_dao.dart';

/// Fresh in-memory database plus all services, with a controllable clock.
class TestEnv {
  TestEnv() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    products = ProductsRepository(db, clock);
    sales = SalesService(db, clock);
    purchases = PurchaseService(db, clock);
    inventory = InventoryService(db, clock);
    outbox = SyncOutboxDao(db, clock);
  }

  DateTime now = DateTime(2026, 11, 25, 10);
  DateTime clock() => now;

  late final AppDatabase db;
  late final ProductsRepository products;
  late final SalesService sales;
  late final PurchaseService purchases;
  late final InventoryService inventory;
  late final SyncOutboxDao outbox;

  /// Creates a product and receives [stock] units at [cost] piastres.
  Future<Product> productWithStock({
    String name = 'Pepsi 330ml',
    String? barcode = '6221031490101',
    int price = 1500,
    int cost = 1000,
    double stock = 10,
    double minStock = 2,
  }) async {
    final p = await products.createProduct(
      ProductInput(
        name: name,
        barcode: barcode,
        sellingPrice: price,
        minStock: minStock,
      ),
    );
    if (stock > 0) {
      await purchases.receive(
        PurchaseDraft(
          lines: [
            PurchaseLine(productId: p.id, quantity: stock, unitCost: cost),
          ],
        ),
      );
    }
    return products.getById(p.id);
  }

  Future<void> dispose() => db.close();
}
