// ignore_for_file: unused_local_variable

import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos_shared_preferences/models/customer_model.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:shared_widgets/config/app_invoice_colors.dart';
import 'package:shared_widgets/config/app_invoice_styles.dart';
import 'package:yousentech_pos_invoice_printing/yousentech_pos_invoice_printing.dart';

import '../presentation/widgets/details_table.dart';
import '../presentation/widgets/info_total.dart';
import '../presentation/widgets/session_info_card.dart';

Future<pw.Document> a4SesstionPrint(
    {required List sessionInfo,
    required List invoices,
    required List refund,
    required PdfPageFormat format}) async {
  PrintingInvoiceController printingController =
      Get.put(PrintingInvoiceController());
  List listHeder = [
    {'title': "sesetionInfo", 'expanded': 2},
    {'title': "invoices", 'expanded': 1},
    {'title': "refund", 'expanded': 1},
  ];
  List<String> invoicestitle = [
    'totale invoice',
    'total tax',
    'total descont',
    'total invoice with out tax',
    // 'details invoice',
    // 'details invoice payment'
  ];
  List<String> refundtitle = [
    'totale refund',
    'total tax',
    'total descont',
    'total refund with out tax',
    // 'details refund',
    // 'details refund payment'
  ];
  List<String> paymenttitle = ['payment', 'transactions', 'amount'];
  List<String> catgerytitle = ['name', 'count', 'amount'];
  // print(refundtitle.length);
  Customer? company = SharedPr.currentCompanyObject;
  final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
  // await AppInvoiceStyle.loadFonts();
  pdf.addPage(pw.MultiPage(
      textDirection:
          SharedPr.lang == "ar" ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      pageFormat: format,
      margin: const pw.EdgeInsets.only(
        top: 45,
        bottom: 32,
        right: 30,
        left: 30,
      ),
      build: (pw.Context context) => [
            pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: pw.Text(
                    //"POS Report",
                    "session_report".tr,
                    style: AppInvoiceStyle.headerStyle(
                        fontsize: 16, color: AppInvoceColor.brown))),
            pw.SizedBox(height: 5),
            sessionInfoCard(sessionInfo: sessionInfo),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 1, color: AppInvoceColor.graydivider),
            infoTotal(title: invoicestitle, value: invoices, text: 'Invoice'),
            pw.Divider(thickness: 1, color: AppInvoceColor.graydivider),
            pw.SizedBox(height: 10),
            detailsTable(
                title: catgerytitle,
                value: invoices[4],
                text: 'Invoice by Category'),
            pw.Divider(thickness: 1, color: AppInvoceColor.graydivider),
            pw.SizedBox(height: 10),
            detailsTable(
                title: paymenttitle,
                value: invoices[5],
                text: 'Invoice Payment Methods'),
            pw.Divider(thickness: 1, color: AppInvoceColor.graydivider),
            pw.SizedBox(height: 10),
            if (invoices[6].isNotEmpty) ...[
              detailsTable(
                  title: paymenttitle,
                  value: invoices[6],
                  text: 'Unlinked Payment For Out Invoices'),
              pw.Divider(thickness: 1, color: AppInvoceColor.graydivider),
              pw.SizedBox(height: 10)
            ],
            infoTotal(title: refundtitle, value: refund, text: 'Refund'),
            pw.Divider(thickness: 1, color: AppInvoceColor.graydivider),
            pw.SizedBox(height: 10),
            if (refund.isNotEmpty) ...[
              if (refund[4].isNotEmpty) ...[
                detailsTable(
                    title: catgerytitle,
                    value: refund[4],
                    text: 'Refund by Category'),
                pw.Divider(thickness: 1, color: AppInvoceColor.graydivider),
                pw.SizedBox(height: 10)
              ],
              if (refund[5].isNotEmpty) ...[
                detailsTable(
                    title: paymenttitle,
                    value: refund[5],
                    text: 'Refund Payment Methods'),
                pw.Divider(thickness: 1, color: AppInvoceColor.graydivider),
                pw.SizedBox(height: 10)
              ],
              if (refund[6].isNotEmpty) ...[
                detailsTable(
                    title: paymenttitle,
                    value: refund[6],
                    text: 'Unlinked Payment For Out Refunds'),
                pw.Divider(thickness: 1, color: AppInvoceColor.graydivider),
              ],
            ]
          ]));
  return pdf;
}
