/// Thrown when a sale would take a product's stock below zero.
class InsufficientStockException implements Exception {
  InsufficientStockException(this.productName, this.available, this.requested);
  final String productName;
  final double available;
  final double requested;

  @override
  String toString() =>
      'الرصيد غير كافٍ لـ "$productName": المتاح $available، المطلوب $requested';
}

class InvalidOperationException implements Exception {
  InvalidOperationException(this.message);
  final String message;
  @override
  String toString() => message;
}
