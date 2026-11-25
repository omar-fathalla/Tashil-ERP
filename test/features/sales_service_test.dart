import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tashil_erp/core/database/app_database.dart';
import 'package:tashil_erp/core/errors.dart';
import 'package:tashil_erp/features/products/data/products_repository.dart';
import 'package:tashil_erp/features/sales/data/sales_service.dart';

import '../helpers/test_env.dart';

void main() {
  late TestEnv env;
  setUp(() => env = TestEnv());
  tearDown(() => env.dispose());

  test('sale lowers stock, writes OUT movement and outbox in one go', () async {
    final p = await env.productWithStock(stock: 10);

    final r = await env.sales.createSale(
      SaleDraft(lines: [SaleLine(productId: p.id, quantity: 3)]),
    );

    expect(r.sale.subTotal, 4500);
    expect(r.sale.total, 4500);
    expect(r.sale.invoiceNumber, 'POS1-20261125-0001');
    expect((await env.products.getById(p.id)).currentStock, 7);

    final moves = await env.inventory.movementsOf(p.id);
    final out = moves.last;
    expect(out.type, MovementType.stockOut);
    expect(out.referenceType, ReferenceType.sale);
    expect(out.quantity, -3);
    expect(out.balanceAfter, 7);
    expect(out.referenceUuid, r.sale.localUuid);

    final pending = await env.outbox.nextBatch();
    final saleEntry = pending.singleWhere(
      (e) => e.entityType == EntityType.sale,
    );
    final payload = jsonDecode(saleEntry.payloadJson) as Map<String, dynamic>;
    expect(payload['uuid'], r.sale.localUuid);
    expect((payload['items'] as List).single['productUuid'], p.localUuid);
  });

  test('sale items keep a snapshot of name and prices', () async {
    final p = await env.productWithStock(price: 1500, cost: 1000);
    final r = await env.sales.createSale(
      SaleDraft(lines: [SaleLine(productId: p.id, quantity: 1)]),
    );

    await env.products.updateProduct(
      p.id,
      const ProductInput(name: 'Renamed', sellingPrice: 9999),
    );

    final item = (await env.sales.itemsOf(r.sale.id)).single;
    expect(item.productName, 'Pepsi 330ml');
    expect(item.unitPrice, 1500);
    expect(item.costPrice, 1000);
  });

  test('discount and tax are applied to the total', () async {
    final p = await env.productWithStock(price: 1000);
    final r = await env.sales.createSale(
      SaleDraft(
        lines: [SaleLine(productId: p.id, quantity: 2)],
        discount: 500,
        taxRatePercent: 14,
      ),
    );
    expect(r.sale.subTotal, 2000);
    expect(r.sale.tax, 210); // 14% of 1500
    expect(r.sale.total, 1710);
  });

  test('insufficient stock rolls back everything', () async {
    final a = await env.productWithStock(name: 'A', barcode: '1', stock: 5);
    final b = await env.productWithStock(name: 'B', barcode: '2', stock: 1);
    final outboxBefore = (await env.outbox.nextBatch(limit: 1000)).length;

    await expectLater(
      env.sales.createSale(
        SaleDraft(
          lines: [
            SaleLine(productId: a.id, quantity: 2),
            SaleLine(productId: b.id, quantity: 3), // fails here
          ],
        ),
      ),
      throwsA(isA<InsufficientStockException>()),
    );

    expect((await env.products.getById(a.id)).currentStock, 5);
    expect((await env.products.getById(b.id)).currentStock, 1);
    expect(await env.db.select(env.db.sales).get(), isEmpty);
    expect(await env.db.select(env.db.saleItems).get(), isEmpty);
    expect((await env.outbox.nextBatch(limit: 1000)).length, outboxBefore);
  });

  test('same product on two lines is checked against running stock', () async {
    final p = await env.productWithStock(stock: 4);
    await expectLater(
      env.sales.createSale(
        SaleDraft(
          lines: [
            SaleLine(productId: p.id, quantity: 3),
            SaleLine(productId: p.id, quantity: 3),
          ],
        ),
      ),
      throwsA(isA<InsufficientStockException>()),
    );
    expect((await env.products.getById(p.id)).currentStock, 4);
  });

  test(
    'cancel returns stock with RETURN movements and keeps the invoice',
    () async {
      final p = await env.productWithStock(stock: 10);
      final r = await env.sales.createSale(
        SaleDraft(lines: [SaleLine(productId: p.id, quantity: 4)]),
      );

      final cancelled = await env.sales.cancelSale(
        r.sale.id,
        reason: 'customer',
      );
      expect(cancelled.status, SaleStatus.cancelled);
      expect((await env.products.getById(p.id)).currentStock, 10);

      final last = (await env.inventory.movementsOf(p.id)).last;
      expect(last.referenceType, ReferenceType.saleReturn);
      expect(last.quantity, 4);

      expect(
        () => env.sales.cancelSale(r.sale.id),
        throwsA(isA<InvalidOperationException>()),
      );
    },
  );

  test('invoice numbers increase per day and restart the next day', () async {
    final p = await env.productWithStock(stock: 10);
    final line = [SaleLine(productId: p.id, quantity: 1)];
    final a = await env.sales.createSale(SaleDraft(lines: line));
    final b = await env.sales.createSale(SaleDraft(lines: line));
    env.now = DateTime(2026, 11, 26, 9);
    final c = await env.sales.createSale(SaleDraft(lines: line));
    expect(a.sale.invoiceNumber, 'POS1-20261125-0001');
    expect(b.sale.invoiceNumber, 'POS1-20261125-0002');
    expect(c.sale.invoiceNumber, 'POS1-20261126-0001');
  });

  test('rejects empty sales and non-positive quantities', () async {
    final p = await env.productWithStock();
    expect(
      () => env.sales.createSale(const SaleDraft(lines: [])),
      throwsA(isA<InvalidOperationException>()),
    );
    expect(
      () => env.sales.createSale(
        SaleDraft(lines: [SaleLine(productId: p.id, quantity: 0)]),
      ),
      throwsA(isA<InvalidOperationException>()),
    );
  });
}
