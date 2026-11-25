import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors.dart';
import '../../sync/data/outbox_writer.dart';
import '../../sync/data/payloads.dart';

class ProductInput {
  const ProductInput({
    required this.name,
    this.nameAr,
    this.barcode,
    this.categoryId,
    this.costPrice = 0,
    this.sellingPrice = 0,
    this.minStock = 0,
    this.unit = 'pcs',
    this.isActive = true,
  });
  final String name;
  final String? nameAr;
  final String? barcode;
  final int? categoryId;
  final int costPrice;
  final int sellingPrice;
  final double minStock;
  final String unit;
  final bool isActive;
}

/// Catalog reads and writes. Stock is NOT editable here: use
/// InventoryService.adjustStock or a sale/purchase so a movement is recorded.
class ProductsRepository {
  ProductsRepository(this._db, this._now) : _outbox = OutboxWriter(_db, _now);
  final AppDatabase _db;
  final DateTime Function() _now;
  final OutboxWriter _outbox;
  static const _uuid = Uuid();

  Future<Category> createCategory(String name, {String? description}) {
    return _db.transaction(() async {
      final now = _now();
      final c = await _db
          .into(_db.categories)
          .insertReturning(
            CategoriesCompanion.insert(
              localUuid: _uuid.v4(),
              name: name,
              description: Value(description),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _outbox.enqueue(
        entityType: EntityType.category,
        entityUuid: c.localUuid,
        operation: OutboxOperation.create,
        payload: categoryPayload(c),
      );
      return c;
    });
  }

  Future<Product> createProduct(ProductInput input) {
    return _db.transaction(() async {
      final now = _now();
      final p = await _db
          .into(_db.products)
          .insertReturning(
            ProductsCompanion.insert(
              localUuid: _uuid.v4(),
              name: input.name,
              nameAr: Value(input.nameAr),
              barcode: Value(_cleanBarcode(input.barcode)),
              categoryId: Value(input.categoryId),
              costPrice: Value(input.costPrice),
              sellingPrice: Value(input.sellingPrice),
              minStock: Value(input.minStock),
              unit: Value(input.unit),
              isActive: Value(input.isActive),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _enqueueProduct(p, OutboxOperation.create);
      return p;
    });
  }

  Future<Product> updateProduct(int id, ProductInput input) {
    return _db.transaction(() async {
      final now = _now();
      final rows =
          await (_db.update(
            _db.products,
          )..where((p) => p.id.equals(id))).writeReturning(
            ProductsCompanion(
              name: Value(input.name),
              nameAr: Value(input.nameAr),
              barcode: Value(_cleanBarcode(input.barcode)),
              categoryId: Value(input.categoryId),
              costPrice: Value(input.costPrice),
              sellingPrice: Value(input.sellingPrice),
              minStock: Value(input.minStock),
              unit: Value(input.unit),
              isActive: Value(input.isActive),
              updatedAt: Value(now),
              syncStatus: const Value(SyncStatus.pending),
            ),
          );
      if (rows.isEmpty) {
        throw InvalidOperationException('المنتج غير موجود');
      }
      await _enqueueProduct(rows.single, OutboxOperation.update);
      return rows.single;
    });
  }

  Future<Product?> findByBarcode(String barcode) {
    return (_db.select(_db.products)..where(
          (p) => p.barcode.equals(barcode.trim()) & p.isActive.equals(true),
        ))
        .getSingleOrNull();
  }

  Future<Product> getById(int id) =>
      (_db.select(_db.products)..where((p) => p.id.equals(id))).getSingle();

  /// Paged list for the catalog screen (keeps memory low on 3 GB devices).
  Stream<List<Product>> watchProducts({
    String search = '',
    int limit = 50,
    int offset = 0,
  }) {
    final q = _db.select(_db.products)
      ..where((p) => p.isActive.equals(true))
      ..orderBy([(p) => OrderingTerm.asc(p.name)])
      ..limit(limit, offset: offset);
    final term = search.trim();
    if (term.isNotEmpty) {
      q.where(
        (p) =>
            p.name.contains(term) |
            p.nameAr.contains(term) |
            p.barcode.equals(term),
      );
    }
    return q.watch();
  }

  /// Products at or below their minimum stock level.
  Stream<List<Product>> watchLowStock() {
    return (_db.select(_db.products)
          ..where(
            (p) =>
                p.isActive.equals(true) &
                p.currentStock.isSmallerOrEqual(p.minStock),
          )
          ..orderBy([(p) => OrderingTerm.asc(p.currentStock)]))
        .watch();
  }

  Future<void> _enqueueProduct(Product p, OutboxOperation op) async {
    String? categoryUuid;
    if (p.categoryId != null) {
      final c = await (_db.select(
        _db.categories,
      )..where((c) => c.id.equals(p.categoryId!))).getSingle();
      categoryUuid = c.localUuid;
    }
    await _outbox.enqueue(
      entityType: EntityType.product,
      entityUuid: p.localUuid,
      operation: op,
      payload: productPayload(p, categoryUuid: categoryUuid),
    );
  }

  static String? _cleanBarcode(String? b) {
    final t = b?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}
