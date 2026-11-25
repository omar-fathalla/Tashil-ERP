import 'package:material_ui/material_ui.dart';

import '../bidi.dart';
import '../money.dart';
import '../tokens.dart';

class ReceiptLine {
  const ReceiptLine(this.name, this.quantity, this.unitPricePiastres);
  final String name;
  final double quantity;
  final int unitPricePiastres;
  int get totalPiastres => (unitPricePiastres * quantity).round();
}

/// On-screen preview of the 58mm thermal receipt.
///
/// It is drawn at the printer's real width (384 dots) in black on white,
/// whatever the app theme, because the same widget is later rasterised to a
/// bitmap for the SUNMI printer (Arabic text cannot be sent as printer text).
class ReceiptPreview extends StatelessWidget {
  const ReceiptPreview({
    super.key,
    required this.storeName,
    required this.invoiceNo,
    required this.dateTime,
    required this.lines,
    this.discountPiastres = 0,
    this.footer = 'شكراً لزيارتكم',
  });

  final String storeName;
  final String invoiceNo;
  final String dateTime;
  final List<ReceiptLine> lines;
  final int discountPiastres;
  final String footer;

  @override
  Widget build(BuildContext context) {
    const ink = Colors.black;
    const base = TextStyle(
      fontFamily: 'Cairo',
      color: ink,
      fontSize: 18,
      height: 1.3,
      fontFeatures: [FontFeature.tabularFigures()],
    );
    final bold = base.copyWith(
      fontWeight: FontWeight.w700,
      fontVariations: const [FontVariation.weight(700)],
    );
    final subtotal = lines.fold<int>(0, (s, l) => s + l.totalPiastres);
    final total = subtotal - discountPiastres;

    Widget row(String a, String b, {TextStyle? style}) => Row(
      children: [
        Expanded(child: Text(a, style: style ?? base)),
        Text(b, style: style ?? base, textDirection: TextDirection.ltr),
      ],
    );

    const rule = Divider(color: ink, thickness: 1, height: 12);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        width: TashilSizes.receiptDots,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              storeName,
              textAlign: TextAlign.center,
              style: bold.copyWith(fontSize: 26),
            ),
            Text(
              'فاتورة ${Bidi.ltr(invoiceNo)}',
              textAlign: TextAlign.center,
              style: base,
            ),
            Text(dateTime, textAlign: TextAlign.center, style: base),
            rule,
            for (final l in lines) ...[
              Text(l.name, style: bold),
              row(
                Bidi.ltr(
                  '${Money.qty(l.quantity)} × ${Money.amount(l.unitPricePiastres)}',
                ),
                Money.amount(l.totalPiastres),
              ),
            ],
            rule,
            row('الإجمالي الفرعي', Money.amount(subtotal)),
            if (discountPiastres != 0)
              row('خصم', '-${Money.amount(discountPiastres)}'),
            row(
              'الإجمالي',
              Money.format(total),
              style: bold.copyWith(fontSize: 22),
            ),
            rule,
            Text(footer, textAlign: TextAlign.center, style: base),
          ],
        ),
      ),
    );
  }
}
