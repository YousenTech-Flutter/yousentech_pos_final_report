import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart' as intl;
import 'package:shared_widgets/config/app_invoice_colors.dart';
import 'package:shared_widgets/config/app_invoice_styles.dart';

detailsTable({
  required List title,
  required List value,
  required String text,
}) {
  final intl.NumberFormat formatter = intl.NumberFormat('#,##0.00', 'en_US');
  return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: pw.Column(children: [
        pw.Row(children: [
          pw.Text(text,
              style: AppInvoiceStyle.headerStyle(
                  fontsize: 14, color: AppInvoceColor.brown)),
        ]),
        pw.Padding(
            padding: const pw.EdgeInsets.all(2.0),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                ...List.generate(
                  title.length,
                  (index) => pw.Expanded(
                      child: pw.Text("${title[index]} ",
                          style: AppInvoiceStyle.headerStyle(
                              fontsize: 11, isbold: true, isblack: true))),
                ),
              ],
            )),
        ...List.generate(
          value.length,
          (index) => pw.Padding(
              padding: const pw.EdgeInsets.all(2.0),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                      child: pw.Text("${value[index]['name']}",
                          style: AppInvoiceStyle.headerStyle(
                              fontsize: 11,
                              isbold: true,
                              color: AppInvoceColor.brown))),
                  pw.Expanded(
                    child: pw.Text(value[index]['value'].toString(),
                        style: AppInvoiceStyle.headerStyle(
                            fontsize: 11, isbold: true, isblack: true)),
                  ),
                  pw.Expanded(
                      child: pw.Text(
                          "${value[index]['value'].toString()} ${"S.R".tr}",
                          style: AppInvoiceStyle.headerStyle(
                              fontsize: 11, isbold: true, isblack: true))),
                ],
              )),
        ),
      ]));
}
