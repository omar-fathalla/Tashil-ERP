import 'package:flutter_test/flutter_test.dart';
import 'package:tashil_erp/core/database/app_database.dart';
import 'package:tashil_erp/features/products/data/products_repository.dart';
import 'package:tashil_erp/features/sales/data/sales_service.dart';

import '../helpers/test_env.dart';

void main() {
  late TestEnv env;
  setUp(() => env = TestEnv());
  tearDown(() => env.dispose());

  test('every change lands in the outbox in order', () async {
    final p = await env.productWithStock(stock: 5);
    await env.sales.createSale(
      SaleDraft(lines: [SaleLine(productId: p.id, quantity: 1)]),
    );
    final kinds = (await env.outbox.nextBatch())
        .map((e) => '${e.entityType.code}:${e.operation.code}')
        .toList();
    expect(kinds, [
      'PRODUCT:CREATE',
      'STOCK_MOVEMENT:CREATE', // receipt
      'PRODUCT:UPDATE', // cost changed
      'PURCHASE:CREATE',
      'STOCK_MOVEMENT:CREATE', // sale
      'SALE:CREATE',
    ]);
  });

  test(
    'synced entries leave the queue; failed ones retry until the cap',
    () async {
      await env.products.createProduct(const ProductInput(name: 'A'));
      await env.products.createProduct(const ProductInput(name: 'B'));
      final batch = await env.outbox.nextBatch();
      expect(batch, hasLength(2));

      await env.outbox.markSynced([batch.first.id]);
      await env.outbox.markFailed(batch.last.id, 'timeout');

      final next = await env.outbox.nextBatch();
      expect(next.single.id, batch.last.id);
      expect(next.single.status, SyncStatus.failed);
      expect(next.single.retryCount, 1);
      expect(next.single.lastError, 'timeout');
      expect(await env.outbox.nextBatch(maxRetries: 1), isEmpty);
      expect(await env.outbox.watchPendingCount().first, 1);
    },
  );
}
