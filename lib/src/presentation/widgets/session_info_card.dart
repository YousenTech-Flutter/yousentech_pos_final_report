import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:shared_widgets/config/app_invoice_colors.dart';
import 'package:shared_widgets/config/app_invoice_styles.dart';
import 'package:yousentech_pos_final_report/src/domain/final_report_viewmodel.dart';

sessionInfoCard({
  required List sessionInfo,
  int? expanded,
  bool isTotal = false,
}) {
  FinalReportController finalReportController =
      Get.isRegistered<FinalReportController>()
          ? Get.find<FinalReportController>()
          : Get.put(FinalReportController());
  List title = [
    {'name': 'Point of Sale', 'value': "${SharedPr.currentPosObject!.name}"},
    {'name': 'session number', 'value': "${sessionInfo[0]}"},
    {'name': 'opening balance', 'value': "${sessionInfo[2]}"},
    {'name': 'user', 'value': "${sessionInfo[sessionInfo.length - 1]}"},
    {'name': 'state', 'value': "${sessionInfo[1]}"},
    {'name': 'FROM', 'value': "${sessionInfo[3]}"},
    {
      'name': 'TO',
      'value': "${finalReportController.formatdate(DateTime.now().toString())}"
    },
  ];
  return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: AppInvoceColor.grayTableBorder,
      child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  ...List.generate(
                    title.length,
                    (index) {
                      if (index < 4) {
                        return pw.Text(title[index]['name'],
                            style: AppInvoiceStyle.headerStyle(
                                fontsize: 11, isblack: true));
                      }
                      return pw.Container();
                    },
                  ),
                ]),
            pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  ...List.generate(
                    title.length,
                    (index) {
                      if (index < 4) {
                        return pw.Text(title[index]['value'],
                            style: AppInvoiceStyle.headerStyle(
                                fontsize: 11, isblack: true));
                      }
                      return pw.Container();
                    },
                  ),
                ]),
            pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  ...List.generate(
                    title.length,
                    (index) {
                      if (index >= 4) {
                        return pw.Text(title[index]['name'],
                            style: AppInvoiceStyle.headerStyle(
                                fontsize: 11, isblack: true));
                      }
                      return pw.Container();
                    },
                  ),
                ]),
            pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  ...List.generate(
                    title.length,
                    (index) {
                      if (index >= 4) {
                        return pw.Text(title[index]['value'],
                            style: AppInvoiceStyle.headerStyle(
                                fontsize: 11, isblack: true));
                      }
                      return pw.Container();
                    },
                  ),
                ])
          ]));
}
