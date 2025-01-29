// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_widgets/config/app_colors.dart';
import 'package:yousentech_pos_final_report/src/domain/final_report_viewmodel.dart';
import 'package:yousentech_pos_final_report/src/presentation/views/printer_page.dart';

// import 'package:yousen_tech_pos/features/authenticate/domain/authenticate_viewmodel.dart';

class PrinterSession extends StatefulWidget {
  PrinterSession({
    super.key,
  });

  @override
  State<PrinterSession> createState() => _PrinterSessionState();
}

class _PrinterSessionState extends State<PrinterSession> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<FinalReportController>(builder: (controller) {
        return PdfPreview(
            // dpi: 1000,
            dpi: 150,
            useActions: false,
            canDebug: false,
            actionBarTheme:
                PdfActionBarTheme(backgroundColor: AppColor.cyanTeal),
            actions: [
              PrinterSessionPage(
                onPressedCheckbox: () {
                  controller.isDefault = !controller.isDefault;
                  controller.checkbox = !controller.checkbox;
                  controller.update();
                  // print(
                  //     "finalReportController.isDefault ${finalReportController.isDefault}");
                },
                onPressedDonload: () async {
                  await controller.downloadPDF(
                    format: controller.checkbox ? "A4" : "Roll80",
                  );
                  controller.closePrintDiloge();
                },
                onPressedPrint: (
                  BuildContext context,
                  LayoutCallback build,
                  PdfPageFormat pageFormat,
                ) async {
                  await controller.nextPressedSessionReport(
                    format: controller.checkbox ? "A4" : "Roll80",
                  );
                  controller.closePrintDiloge();
                },
              ),
            ],
            build: (format) {
              return controller.isDefault
                  ? controller.generateRollSessionPdf(
                      format: format,
                    )
                  : controller.generateA4SessionPdf(
                      format: format,
                    );
            });
      }),
    );
  }
}
