// ignore_for_file: unused_local_variable

import 'dart:math';
import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos_shared_preferences/helper/app_enum.dart';
import 'package:pos_shared_preferences/models/final_report_info.dart';
import 'package:pos_shared_preferences/models/pos_session/invoice_count.dart';
import 'package:pos_shared_preferences/models/pos_session/posSession.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:printing/printing.dart';
import 'package:shared_widgets/utils/response_result.dart';
import 'package:yousentech_pos_final_report/final_report/src/domain/final_report_service.dart';
import 'package:yousentech_pos_final_report/final_report/src/utils/a4_sesion_print_helper.dart';
import 'package:yousentech_pos_final_report/final_report/src/utils/show_pdf_session.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/domain/invoice_printing_viewmodel.dart';
import 'package:yousentech_pos_invoice_printing/yousentech_pos_invoice_printing.dart';
import 'package:intl/intl.dart' as intl;
import '../utils/roll_sesion_print_helper.dart';

class FinalReportController extends GetxController {
  FinalReportInfo? finalReportInfo;
  bool isDefault = true; // Default option
  bool checkbox = false;
  RxBool isbestsellertab = false.obs;
  pw.Document? pdf;
  String title = '';
  List<InvoiceCount> countInvoices = [];
  List sessionCard = [];
  List invoicePaymentMethod = [];
  double totalPaymentMethod = 0.0;
  double totalPaymentMethodReturn = 0.0;
  List invoiceCategories = [];
  List topSession = [];
  List lessProductsBasedInAvailableQty = [];
  List<String> totalOrdrestital = [];
  List<double> totalOrdresvalue = [];
  PosSession? sessionData;
  List<FlSpot> spotSaleOrder = [];
  // bool seeAllPayment = false;
  int paymentLength = 0;
  bool isPDFDialogOpen = false;
  bool isFromSessionList = false;

  final intl.NumberFormat formatter = intl.NumberFormat('#,##0.00', 'en_US');
  @override
  void onInit() {
    // await getFinalReportInfo();

    super.onInit();
  }

  FinalReportService finalReportService = FinalReportService.getInstance();
  // ========================================== [ START CREATE PRODUCT ] =============================================
  Future<ResponseResult> getFinalReportInfo(
      {int? ssessionID, String dateFilterKey = 'week'}) async {
    var result = await finalReportService.finalReportInfo(
        dateFilterKey: dateFilterKey,
        id: ssessionID,
        isSessionList: ssessionID != null ? true : false);

    if (result is FinalReportInfo) {
      finalReportInfo = result;
      sessionCard = [
        {
          "orders": formatter.format(0.0),
        },
        {"totalOutInvoice": formatter.format(result.totalOutInvoice)},
        {
          "totalOutRefund": formatter.format(result.totalOutRefund),
        },
        {"netSales": formatter.format(result.netSales)},
        {"remaining": formatter.format(0.0)}
      ];
      invoicePaymentMethod =
          sumTotalAmountById(finalReportInfo!.invoicePaymentOptions!);
      paymentLength =
          invoicePaymentMethod.length >= 5 ? 5 : invoicePaymentMethod.length;
      invoiceCategories = sumtotalQtyBycategoryId(
          finalReportInfo!.quantitiesBasedInCategories!);
      topSession = finalReportInfo!.topSession ?? [];
      lessProductsBasedInAvailableQty =
          finalReportInfo!.lessProductsBasedInAvailableQty ?? [];
      // TODO :=====
      // InvoicePendingController invoicePendingController =
      //     Get.isRegistered<InvoicePendingController>()
      //         ? Get.find<InvoicePendingController>()
      //         : Get.put(InvoicePendingController());
      // ResponseResult resultCount =
      //     await invoicePendingController.countInvoicesByType();
      // if (resultCount.status) {
      //   countInvoices = resultCount.data;
      // }
      spotSaleOrder.clear();
      spotSaleOrder.add(const FlSpot(0.0, 0.0));
      totalOrdrestital.clear();
      totalOrdresvalue.clear();

      for (var i = 0; i < (invoiceCategories).length; i++) {
        spotSaleOrder
            .add(FlSpot((i + 1).toDouble(), invoiceCategories[i].totalQty));
        totalOrdrestital.add(SharedPr.lang == 'en'
            ? invoiceCategories[i].name.enUS
            : invoiceCategories[i].name.ar001);
        totalOrdresvalue.add(invoiceCategories[i].totalQty);
      }

      update(["session_card"]);
      return ResponseResult(status: true, data: result);
    } else {
      return ResponseResult(message: result);
    }
  }

  Future<ResponseResult> getCountSessionDraftInvoicesNeedProcess(
      {int? ssessionID}) async {
    var result = await finalReportService
        .getCountSessionDraftInvoicesNeedProcess(ssessionID: ssessionID);
    if (result is int) {
      return ResponseResult(status: true, data: result);
    } else {
      return ResponseResult(message: result);
    }
  }
// ========================================== [ START CREATE PRODUCT ] =============================================

  List sessionInfo() {
    if (isFromSessionList) {
      //  var x=   intl.DateFormat('yyyy-MM-dd HH:mm').format(sessionData!.startTime);
      return [
        sessionData!.id,
        sessionData!.state!.text,
        sessionData!.balanceOpening,
        formatdate(sessionData!.startTime),
        formatdate(sessionData!.closeTime),
        sessionData!.userOpenName,
      ];
    } else {
      return [
        SharedPr.currentSaleSession!.id,
        SharedPr.currentSaleSession!.state!.text,
        SharedPr.currentSaleSession!.balanceOpening,
        formatdate(SharedPr.currentSaleSession!.startTime),
        formatdate(SharedPr.currentSaleSession!.closeTime),
        SharedPr.currentSaleSession!.userOpenName,
      ];
    }
  }

  formatdate(String? date) {
    if (date == "" || date == null) {
      return "";
    }
    var dateTime = DateTime.parse(date ?? "");

    // Format the DateTime object

    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime).toString();
  }

  List invoiceResult() {
    return [
      finalReportInfo!.saleOrderSummery!
              .where((saleOrderSummery) =>
                  saleOrderSummery.moveType == MoveType.out_invoice.name)
              .first
              .totalPrice ??
          0.0,
      finalReportInfo!.saleOrderSummery!
              .where((saleOrderSummery) =>
                  saleOrderSummery.moveType == MoveType.out_invoice.name)
              .first
              .totalTaxes ??
          0.0,
      finalReportInfo!.saleOrderSummery!
              .where((saleOrderSummery) =>
                  saleOrderSummery.moveType == MoveType.out_invoice.name)
              .first
              .totalDiscount ??
          0.0,
      finalReportInfo!.saleOrderSummery!
              .where((saleOrderSummery) =>
                  saleOrderSummery.moveType == MoveType.out_invoice.name)
              .first
              .totalPriceSubtotal ??
          0.0,
      finalReportInfo!.quantitiesBasedInCategories!
          .where((category) => category.moveType == MoveType.out_invoice.name)
          .map((category) => {
                'name': SharedPr.lang == "ar"
                    ? category.name!.ar001
                    : category.name!.enUS,
                'value': formatter.format(category.totalQty ?? 0.0)
              })
          .toList(),
      finalReportInfo!.invoicePaymentOptions!
          .where((accountJournal) =>
              accountJournal.moveType == MoveType.out_invoice.name)
          .map((accountJournal) => {
                'name': SharedPr.lang == "ar"
                    ? accountJournal.accountJournalName!.ar001
                    : accountJournal.accountJournalName!.enUS,
                'value': formatter.format(accountJournal.totalAmount ?? 0.0)
              })
          .toList(),
      finalReportInfo!.invoiceUnlinkedPayment == null
          ? []
          : finalReportInfo!.invoiceUnlinkedPayment!
              .where((accountJournal) =>
                  accountJournal.moveType == MoveType.out_invoice.name)
              .map((accountJournal) => {
                    'name': SharedPr.lang == "ar"
                        ? accountJournal.accountJournalName!.ar001
                        : accountJournal.accountJournalName!.enUS,
                    'value': formatter.format(accountJournal.totalAmount ?? 0.0)
                  })
              .toList()
    ];
  }

  List refundResult() {
    var saleOrderSummery = finalReportInfo!.saleOrderSummery!.firstWhereOrNull(
        (saleOrderSummery) =>
            saleOrderSummery.moveType == MoveType.out_refund.name);

    if (saleOrderSummery == null) {
      return [];
    }

    return [
      formatter.format(finalReportInfo!.saleOrderSummery!
              .where((saleOrderSummery) =>
                  saleOrderSummery.moveType == MoveType.out_refund.name)
              .first
              .totalPrice ??
          0.0),
      formatter.format(finalReportInfo!.saleOrderSummery!
              .where((saleOrderSummery) =>
                  saleOrderSummery.moveType == MoveType.out_refund.name)
              .first
              .totalTaxes ??
          0.0),
      formatter.format(finalReportInfo!.saleOrderSummery!
              .where((saleOrderSummery) =>
                  saleOrderSummery.moveType == MoveType.out_refund.name)
              .first
              .totalDiscount ??
          0.0),
      formatter.format(finalReportInfo!.saleOrderSummery!
              .where((saleOrderSummery) =>
                  saleOrderSummery.moveType == MoveType.out_refund.name)
              .first
              .totalPriceSubtotal ??
          0.0),
      finalReportInfo!.quantitiesBasedInCategories!
          .where((category) => category.moveType == MoveType.out_refund.name)
          .map((category) => {
                'name': SharedPr.lang == "ar"
                    ? category.name!.ar001
                    : category.name!.enUS,
                'value': formatter.format(category.totalQty ?? 0.0)
              })
          .toList(),
      finalReportInfo!.invoicePaymentOptions!
          .where((accountJournal) =>
              accountJournal.moveType == MoveType.out_refund.name)
          .map((accountJournal) => {
                'name': SharedPr.lang == "ar"
                    ? accountJournal.accountJournalName!.ar001
                    : accountJournal.accountJournalName!.enUS,
                'value': formatter.format(accountJournal.totalAmount ?? 0.0)
              })
          .toList(),
      finalReportInfo!.invoiceUnlinkedPayment == null
          ? []
          : finalReportInfo!.invoiceUnlinkedPayment!
              .where((accountJournal) =>
                  accountJournal.moveType == MoveType.out_refund.name)
              .map((accountJournal) => {
                    'name': SharedPr.lang == "ar"
                        ? accountJournal.accountJournalName!.ar001
                        : accountJournal.accountJournalName!.enUS,
                    'value': formatter.format(accountJournal.totalAmount ?? 0.0)
                  })
              .toList()
    ];
  }

  nextPressedSessionReport({
    required String format,
  }) async {
    PrintingInvoiceController printingInvoiceController =
        Get.put(PrintingInvoiceController());
    final PdfPageFormat pdfFormat =
        printingInvoiceController.getFormatByName(formatName: format);
    final bool result;
    Printer? printer;

    late Printer defaultPrinter;
    // TODO :=====
    // ConnectedPrinterController printingController =
    //     Get.isRegistered<ConnectedPrinterController>()
    //         ? Get.find<ConnectedPrinterController>()
    //         : Get.put(ConnectedPrinterController());
    // if (printingController.connectedPrinterList.isNotEmpty) {
    //   String? printerName = printingController.connectedPrinterList
    //       .firstWhere((elem) => elem.paperType == format)
    //       .printerName;
    //   printer = printingController.systemPrinterList
    //       .firstWhere((elem) => elem.name == printerName);
    // } else {
    //   defaultPrinter = await PrintHelper.setDefaultPrinter();
    // }
    // Random random = Random();
    // var randomnum = 1000 + random.nextInt(9000);
    // result = await Printing.directPrintPdf(
    //   format: pdfFormat,
    //   printer: printer ?? defaultPrinter,
    //   onLayout: buildPDFLayout(
    //     format: pdfFormat,
    //   ),
    //   name:
    //       "${SharedPr.currentPosObject!.name}_${randomnum}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
    // );
  }

  closePrintDiloge() {
    if (Get.isSnackbarOpen) {
      Get.back(closeOverlays: true);
    }

    if (SharedPr.printingPreferenceObj!.showPreview!) {
      Get.back();
    }
  }

  downloadPDF({
    required String format,
  }) async {
    PrintingInvoiceController printingInvoiceController =
        Get.put(PrintingInvoiceController());
    final PdfPageFormat pdfFormat =
        printingInvoiceController.getFormatByName(formatName: format);
    final pdfDirectory =
        printingInvoiceController.pdfCreatDirectory('PDF Session Report');
    buildPDFLayout(format: pdfFormat);
    Random random = Random();
    var randomnum = 1000 + random.nextInt(9000);
    await printingInvoiceController.pdfCreatfile(
        pdfSession: pdf,
        pdfDirectory: pdfDirectory,
        filename:
            '${SharedPr.currentPosObject!.name}_${randomnum}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}');
  }

  printingSessionReport({
    String? titleValue,
  }) async {
    title = titleValue ?? '';

    PrintingInvoiceController printingInvoiceController =
        Get.isRegistered<PrintingInvoiceController>()
            ? Get.find<PrintingInvoiceController>()
            : Get.put(PrintingInvoiceController());
    await printingInvoiceController.loadFonts();
    await showPDFSession();
  }

  Future<Uint8List> generateA4SessionPdf({
    required PdfPageFormat format,
  }) async {
    pdf = await a4SesstionPrint(
        format: format,
        sessionInfo: sessionInfo(),
        invoices: invoiceResult(),
        refund: refundResult());
    return pdf!.save();
  }

  Future<Uint8List> generateRollSessionPdf({
    required PdfPageFormat format,
  }) async {
    pdf = await rollSesstionPrint(
        format: format,
        sessionInfo: sessionInfo(),
        invoices: invoiceResult(),
        refund: refundResult());
    return pdf!.save();
  }

  buildPDFLayout({
    required PdfPageFormat format,
  }) {
    return (format) => isDefault
        ? generateRollSessionPdf(
            format: format,
          )
        : generateA4SessionPdf(
            format: format,
          );
  }

  List<InvoicePaymentOptions> sumTotalAmountById(
      List<InvoicePaymentOptions> data) {
    totalPaymentMethod = 0.0;
    totalPaymentMethodReturn = 0.0;
    List<InvoicePaymentOptions> reslutItem = [];
    List<int> ids = [];

    for (InvoicePaymentOptions item in data) {
      if (item.moveType == MoveType.out_refund.name) {
        totalPaymentMethodReturn = totalPaymentMethodReturn + item.totalAmount!;
      }
      totalPaymentMethod = totalPaymentMethod + item.totalAmount!;
      if (ids.contains(item.id)) {
        int index = ids.indexOf(item.id!);
        reslutItem[index].totalAmount =
            reslutItem[index].totalAmount! + item.totalAmount!;
        reslutItem[index].invoiceCount = reslutItem[index].invoiceCount! + 1;
      } else {
        ids.add(item.id!);
        reslutItem.add(item);
      }
    }
    return reslutItem;
  }

  setPaymentLength() {
    paymentLength = invoicePaymentMethod.length;
    update(["session_card"]);
  }

  List<QuantitiesBasedOnCategories> sumtotalQtyBycategoryId(
      List<QuantitiesBasedOnCategories> data) {
    List<QuantitiesBasedOnCategories> reslutItem = [];
    List<int> ids = [];
    for (QuantitiesBasedOnCategories item in data) {
      if (ids.contains(item.soPosCategId)) {
        int index = ids.indexOf(item.soPosCategId!);
        reslutItem[index].totalQty =
            reslutItem[index].totalQty! + item.totalQty!;
      } else {
        ids.add(item.soPosCategId!);
        reslutItem.add(item);
      }
    }
    return reslutItem;
  }
}
