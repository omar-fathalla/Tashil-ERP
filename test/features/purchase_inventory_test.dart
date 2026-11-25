import 'package:flutter_test/flutter_test.dart';
import 'package:tashil_erp/core/database/app_database.dart';
import 'package:tashil_erp/features/products/data/products_repository.dart';
import 'package:tashil_erp/features/purchases/data/purchase_service.dart';

import '../helpers/test_env.dart';

void main() {
  late TestEnv env;
  setUp(() => env = TestEnv());
  tearDown(() => env.dispose());

  test('goods receipt raises stock and records IN movement', () async {
    final p = await env.products.createProduct(
      const ProductInput(name: 'Rice 1kg', unit: 'kg'),
    );
    final r = await env.purchases.receive(
      PurchaseDraft(
        supplierName: 'Supplier X',
        lines: [PurchaseLine(productId: p.id, quantity: 20, unitCost: 3000)],
      ),
    );
    expect(r.purchase.total, 60000);
    final after = await env.products.getById(p.id);
    expect(after.currentStock, 20);
    expect(after.costPrice, 3000);
    final m = (await env.inventory.movementsOf(p.id)).single;
    expect(m.type, MovementType.stockIn);
    expect(m.referenceType, ReferenceType.purchase);
  });

  test('cost is a weighted average of old and new stock', () async {
    final p = await env.productWithStock(stock: 10, cost: 1000);
    await env.purchases.receive(
      PurchaseDraft(
        lines: [PurchaseLine(productId: p.id, quantity: 30, unitCost: 1400)],
      ),
    );
    // (10*1000 + 30*1400) / 40 = 1300
    expect((await env.products.getById(p.id)).costPrice, 1300);
  });

  test('weightedAverageCost ignores zero or negative old stock', () {
    expect(weightedAverageCost(0, 999, 5, 200), 200);
    expect(weightedAverageCost(-3, 999, 5, 200), 200);
  });

  test('stock adjustment records the difference, not a new balance', () async {
    final p = await env.productWithStock(stock: 10);
    final m = await env.inventory.adjustStock(p.id, 7, note: 'stock-take');
    expect(m!.quantity, -3);
    expect(m.type, MovementType.adjust);
    expect((await env.products.getById(p.id)).currentStock, 7);
    expect(await env.inventory.adjustStock(p.id, 7, note: 'same'), isNull);
  });

  test('stock always equals the sum of its movements', () async {
    final p = await env.productWithStock(stock: 50);
    await env.purchases.receive(
      PurchaseDraft(
        lines: [PurchaseLine(productId: p.id, quantity: 12.5, unitCost: 1000)],
      ),
    );
    await env.inventory.adjustStock(p.id, 60, note: 'count');
    final moves = await env.inventory.movementsOf(p.id);
    final sum = moves.fold<double>(0, (s, m) => s + m.quantity);
    expect((await env.products.getById(p.id)).currentStock, sum);
    expect(moves.last.balanceAfter, sum);
  });

  test('low stock stream lists products at or below minimum', () async {
    await env.productWithStock(
      name: 'OK',
      barcode: '1',
      stock: 10,
      minStock: 2,
    );
    await env.productWithStock(
      name: 'Low',
      barcode: '2',
      stock: 2,
      minStock: 2,
    );
    final low = await env.products.watchLowStock().first;
    expect(low.map((p) => p.name), ['Low']);
  });

  test('findByBarcode trims input and skips inactive products', () async {
    final p = await env.productWithStock(barcode: '6221031490101');
    expect((await env.products.findByBarcode(' 6221031490101 '))?.id, p.id);
    await env.products.updateProduct(
      p.id,
      const ProductInput(name: 'x', barcode: '6221031490101', isActive: false),
    );
    expect(await env.products.findByBarcode('6221031490101'), isNull);
  });
}
