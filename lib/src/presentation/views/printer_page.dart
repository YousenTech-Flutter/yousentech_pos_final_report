// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_widgets/config/app_colors.dart';

import '../../domain/final_report_viewmodel.dart';

class PrinterSessionPage extends StatefulWidget {
  void Function()? onPressedCheckbox;
  void Function()? onPressedDonload;
  void Function(BuildContext, FutureOr<Uint8List> Function(PdfPageFormat),
      PdfPageFormat)? onPressedPrint;
  PrinterSessionPage(
      {super.key,
      this.onPressedCheckbox,
      required this.onPressedPrint,
      required this.onPressedDonload});

  @override
  State<PrinterSessionPage> createState() => _PrinterSessionPageState();
}

class _PrinterSessionPageState extends State<PrinterSessionPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PdfPreviewAction(
        icon: GetBuilder<FinalReportController>(builder: (controller) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: widget.onPressedCheckbox,
                child: Column(
                  children: [
                    Checkbox(
                      checkColor: controller.checkbox ? AppColor.purple : null,
                      fillColor: controller.checkbox
                          ? WidgetStateProperty.all(AppColor.white)
                          : null,
                      value: controller.checkbox,
                      side: BorderSide(
                        color: AppColor.white, // Border color
                        width: 2.0, // Border width
                      ),
                      onChanged: null,
                    ),
                    Text(
                      'A4',
                      style: TextStyle(fontSize: 10.r, color: AppColor.white),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (widget.onPressedPrint != null) {
                    PdfPreviewAction pdfPreviewAction = PdfPreviewAction(
                      icon: Container(),
                      onPressed: widget.onPressedPrint!,
                    );
                    pdfPreviewAction.pressed(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.cyanTeal.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        5.0), // Set your desired radius here
                  ),
                ),
                child: Text(
                  'print'.tr,
                  style: TextStyle(color: AppColor.white, fontSize: 10.r),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (widget.onPressedDonload != null) {
                    widget.onPressedDonload!();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.cyanTeal.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        5.0), // Set your desired radius here
                  ),
                ),
                child: Text(
                  'Download'.tr,
                  style: TextStyle(color: AppColor.white, fontSize: 10.r),
                ),
              )
            ],
          );
        }),
        onPressed: null);
  }
}
