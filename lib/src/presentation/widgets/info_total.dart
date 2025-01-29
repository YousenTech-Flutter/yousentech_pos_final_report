import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart' as intl;
import 'package:shared_widgets/config/app_invoice_colors.dart';
import 'package:shared_widgets/config/app_invoice_styles.dart';

infoTotal({
  required List title,
  required List value,
  required String text,
}) {
  final intl.NumberFormat formatter = intl.NumberFormat('#,##0.00', 'en_US');
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Expanded(
          flex: 2,
          child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: pw.Column(children: [
                pw.Row(children: [
                  pw.Text(text,
                      style: AppInvoiceStyle.headerStyle(
                          fontsize: 14, color: AppInvoceColor.brown)),
                ]),
                ...List.generate(
                  title.length,
                  (index) => pw.Padding(
                      padding: const pw.EdgeInsets.all(2.0),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text("${title[index]}",
                              style: AppInvoiceStyle.headerStyle(
                                  fontsize: 11, isbold: true, isblack: true)),
                          pw.Text(
                              // "${value.isEmpty ? 0 : value[index] ?? 0}  SR",
                              "${formatter.format(value.isEmpty ? 0 : value[index] is String ? double.parse(value[index] ?? 0.0) : value[index] ?? 0.0)} ${"S.R".tr}",
                              style: AppInvoiceStyle.headerStyle(
                                  fontsize: 11, isbold: true, isblack: true)),
                        ],
                      )),
                ),
              ]))),
      pw.Expanded(child: pw.Container())
    ],
  );
}
