import '../../../core/database/app_database.dart';

/// JSON shapes sent to the cloud. Ids are UUIDs; local integer ids never leave
/// the device. Money is in piastres, dates are ISO-8601 UTC.
String _iso(DateTime d) => d.toUtc().toIso8601String();

Map<String, Object?> productPayload(Product p, {String? categoryUuid}) => {
  'uuid': p.localUuid,
  'barcode': p.barcode,
  'name': p.name,
  'nameAr': p.nameAr,
  'categoryUuid': categoryUuid,
  'costPrice': p.costPrice,
  'sellingPrice': p.sellingPrice,
  'currentStock': p.currentStock,
  'minStock': p.minStock,
  'unit': p.unit,
  'isActive': p.isActive,
  'updatedAt': _iso(p.updatedAt),
};

Map<String, Object?> categoryPayload(Category c) => {
  'uuid': c.localUuid,
  'name': c.name,
  'description': c.description,
  'updatedAt': _iso(c.updatedAt),
};

Map<String, Object?> movementPayload(StockMovement m, String productUuid) => {
  'uuid': m.localUuid,
  'productUuid': productUuid,
  'type': m.type.code,
  'quantity': m.quantity,
  'unitCost': m.unitCost,
  'referenceType': m.referenceType.code,
  'referenceUuid': m.referenceUuid,
  'note': m.note,
  'balanceAfter': m.balanceAfter,
  'createdAt': _iso(m.createdAt),
};

Map<String, Object?> salePayload(
  Sale s,
  List<SaleItem> items,
  Map<int, String> productUuids,
) => {
  'uuid': s.localUuid,
  'invoiceNumber': s.invoiceNumber,
  'date': _iso(s.date),
  'subTotal': s.subTotal,
  'discount': s.discount,
  'tax': s.tax,
  'total': s.total,
  'paymentMethod': s.paymentMethod.name,
  'status': s.status.name,
  'customerName': s.customerName,
  'notes': s.notes,
  'updatedAt': _iso(s.updatedAt),
  'items': [
    for (final i in items)
      {
        'uuid': i.localUuid,
        'productUuid': productUuids[i.productId],
        'productName': i.productName,
        'barcode': i.barcode,
        'quantity': i.quantity,
        'unitPrice': i.unitPrice,
        'costPrice': i.costPrice,
        'total': i.total,
      },
  ],
};

Map<String, Object?> purchasePayload(
  Purchase p,
  List<PurchaseItem> items,
  Map<int, String> productUuids,
) => {
  'uuid': p.localUuid,
  'referenceNumber': p.referenceNumber,
  'date': _iso(p.date),
  'supplierName': p.supplierName,
  'total': p.total,
  'status': p.status.name,
  'notes': p.notes,
  'updatedAt': _iso(p.updatedAt),
  'items': [
    for (final i in items)
      {
        'uuid': i.localUuid,
        'productUuid': productUuids[i.productId],
        'productName': i.productName,
        'quantity': i.quantity,
        'unitCost': i.unitCost,
        'total': i.total,
      },
  ],
};
