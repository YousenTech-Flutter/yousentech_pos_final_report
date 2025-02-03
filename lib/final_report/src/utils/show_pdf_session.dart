import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../domain/final_report_viewmodel.dart';
import '../presentation/views/print_session.dart';

showPDFSession() {
  final FinalReportController finalReportController =
      Get.isRegistered<FinalReportController>()
          ? Get.find<FinalReportController>()
          : Get.put(FinalReportController());
  finalReportController.isPDFDialogOpen = true;

  return Get.defaultDialog(
          // cancel: IconButton(
          //     onPressed: () {
          //       // finalReportController.closePrintDiloge();
          //       if (Get.isSnackbarOpen) {
          //         Get.back(closeOverlays: true);
          //       }
          //       if (Get.isDialogOpen != null && Get.isDialogOpen == true) {
          //         Get.back();
          //       }
          //     },
          //     icon: Container(
          //       padding: const EdgeInsets.all(5),
          //       decoration: BoxDecoration(
          //           color: AppColor.backgroundTable,
          //           borderRadius: BorderRadius.circular(5)),
          //       child: Icon(
          //         Icons.close,
          //         size: Get.width * 0.01,
          //       ),
          //     )),
          title: finalReportController.title.tr,
          barrierDismissible: true,
          content: SizedBox(
              height: Get.height * 0.6,
              width: Get.width * 0.3,
              child: PrinterSession()))
      .then((_) {
    // print("=============then====================");
    finalReportController.isPDFDialogOpen = false;
  });
}
