/// Bidirectional-text helpers.
///
/// Invoice numbers, barcodes, phone numbers and dates are left-to-right runs
/// inside Arabic text. Without isolation the bidi algorithm reorders their
/// parts (`0001-20261125-0042` would show as `0042-20261125-0001`).
abstract final class Bidi {
  /// Wraps [s] in Unicode LEFT-TO-RIGHT ISOLATE ... POP DIRECTIONAL ISOLATE.
  static String ltr(String s) => '\u2066$s\u2069';
}
