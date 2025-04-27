// ignore_for_file: unused_local_variable, empty_catches

import 'dart:convert';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart' as intl;
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:shared_widgets/config/app_invoice_styles.dart';
import 'package:shared_widgets/utils/parse_numbers.dart';
import 'package:yousentech_pos_invoice_printing/print_invoice/utils/roll_print_helper2.dart';

Future<pw.Document> rollSesstionPrint(
    {required List sessionInfo,
    required List invoices,
    required List refund,
    required PdfPageFormat format}) async {
  // PrintingInvoiceController printingController =
  //     Get.put(PrintingInvoiceController());

  // Customer? company = SharedPr.currentCompanyObject;
  final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
  final intl.NumberFormat formatter = intl.NumberFormat('#,##0.00', 'en_US');
  await AppInvoiceStyle.loadFonts();
  List<String> sessionInfotitle = [
    'session_number',
    'session_state',
    'openingBalanceSession',
    'sessionStartTime',
    'sessionCloseTime',
    'user'
  ];
  List<String> invoicestitle = [
    'invoice_footer_total',
    'invoice_footer_total_tax',
    'total_discount',
    'invoice_footer_total_before_tax',
    '${'details'.tr} ${'out_invoice'.tr}',
    '${'details'.tr} ${'payment_out_invoice'.tr}',
    '${'details'.tr} ${'invoiceUnlinkedPayment'.tr}'
  ];
  List<String> refundtitle = [
    'invoice_footer_total',
    'invoice_footer_total_tax',
    'total_discount',
    'invoice_footer_total_before_tax',
    '${'details'.tr} ${'out_refund'.tr}',
    '${'details'.tr} ${'payment_out_refund'.tr}',
    '${'details'.tr} ${'refundUnlinkedPayment'.tr}'
  ];
  double sumInvoiceDetails = 0;
  for (var element in invoices[4]) {
    sumInvoiceDetails += double.parse(element['value']);
  }
  double sumInvoicePayment = 0;
  for (var element in invoices[5]) {
    String sanitizedInput = element['value'].replaceAll(',', '');
    double value;
    try {
      // value = double.parse(sanitizedInput);
      sumInvoicePayment += double.parse(sanitizedInput);
    } catch (e) {}
  }
  double suminvoiceUnlinkedPayment = 0;
  for (var element in invoices[6]) {
    String sanitizedInput = element['value'].replaceAll(',', '');
    double value;
    try {
      // value = double.parse(sanitizedInput);
      suminvoiceUnlinkedPayment += double.parse(sanitizedInput);
    } catch (e) {}
  }
  var totalDataInvoice = [
    {
      'name': '${'total_t'.tr} ${'units'.tr} ${'sold'.tr}',
      'value': sumInvoiceDetails
    },
    {'name': '${'total'.tr} ${'amount'.tr}', 'value': sumInvoicePayment},
    {
      'name': '${'total'.tr} ${'amount'.tr}',
      'value': suminvoiceUnlinkedPayment
    },
  ];
  double sumRefundDetails = 0;
  double sumRefundPayment = 0;
  double sumrefundUnlinkedPayment = 0;

  if (refund.isNotEmpty) {
    for (var element in refund[4]) {
      sumRefundDetails += double.parse(element['value']);
    }
    for (var element in refund[5]) {
      sumRefundPayment += double.parse(element['value']);
    }
    for (var element in refund[6]) {
      String sanitizedInput = element['value'].replaceAll(',', '');
      double value;
      try {
        // value = double.parse(sanitizedInput);
        sumrefundUnlinkedPayment += double.parse(sanitizedInput);
      } catch (e) {}
    }
  }

  var totalDataRefund = [
    {
      'name': '${'total_t'.tr} ${'units'.tr} ${'sold'.tr}',
      'value': sumRefundDetails
    },
    {'name': '${'total'.tr} ${'amount'.tr}', 'value': sumRefundPayment},
    {'name': '${'total'.tr} ${'amount'.tr}', 'value': sumrefundUnlinkedPayment},
  ];
  var isSvg =
      String.fromCharCodes(base64.decode(SharedPr.currentCompanyObject!.image!))
          .endsWith('</svg>');
  print(refund);
  pdf.addPage(pw.Page(
    pageFormat: const PdfPageFormat(
      80 * PdfPageFormat.mm, // 80mm width
      double.infinity, // Example: fixed 200mm height
    ),
    textDirection:
        SharedPr.lang == 'en' ? pw.TextDirection.ltr : pw.TextDirection.rtl,
    margin: const pw.EdgeInsets.only(
      top: 10,
      bottom: 10,
      right: 15,
      left: 15,
    ),
    build: (pw.Context context) =>
        pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
      pw.Column(
        children: [
          infoText(
              value: 'session_report_details'.tr,
              isblack: true,
              isbold: true,
              fontsize: 15),
          pw.SizedBox(height: 10),
          if (isSvg) ...[
            pw.SvgImage(
                svg: String.fromCharCodes(
                    base64.decode(SharedPr.currentCompanyObject!.image!)),
                width: 25,
                height: 25)
          ] else ...[
            if (SharedPr.currentCompanyObject?.image == null) ...[
              pw.Image(
                  pw.MemoryImage(
                      base64Decode(SharedPr.currentCompanyObject!.image!)),
                  width: 25,
                  height: 25),
            ],
          ],
          pw.SizedBox(height: 10),
          infoText(
            value: SharedPr.currentCompanyObject!.name ?? "##",
            isblack: true,
          ),
          pw.SizedBox(height: 5),
          infoText(
            value: SharedPr.currentCompanyObject!.city ?? "##",
            isblack: true,
          ),
          pw.SizedBox(height: 5),
          infoText(
            value: SharedPr.currentCompanyObject!.country?.countryName ?? "##",
            isblack: true,
          ),
          pw.SizedBox(height: 5),
          infoText(
            value:
                '${'tell'.tr} - ${SharedPr.currentCompanyObject!.phone ?? "##"}',
            isblack: true,
          ),
          pw.SizedBox(height: 10),
          divider(padding: 22),
          pw.SizedBox(height: 5),
          infoText(
              value: 'session_info'.tr,
              isblack: true,
              isbold: true,
              fontsize: 9),
          pw.SizedBox(height: 5),
          ...List.generate(
            sessionInfo.length - 1,
            (index) {
              return pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      infoText(
                        value: "${sessionInfotitle[index].tr} :  ",
                        isblack: true,
                      ),
                      infoText(
                        value:
                            "${sessionInfo[index]} ${index == 2 ? "S.R".tr : ''}",
                        isblack: true,
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                ],
              );
            },
          )
        ],
      ),
      divider(padding: 22),
      pw.SizedBox(height: 5),
      infoText(
          value: 'out_invoice'.tr, isblack: true, isbold: true, fontsize: 9),
      pw.SizedBox(height: 5),
      ...List.generate(
        invoices.length,
        (indexInvoices) {
          return pw.Column(
            children: [
              if (indexInvoices > 3) ...[
                if (indexInvoices == (invoices.length - 1) &&
                    invoices[indexInvoices].length == 0) ...[
                  pw.Container()
                ] else ...[
                  divider(padding: 22),
                  pw.SizedBox(height: 5),
                  infoText(
                      value: invoicestitle[indexInvoices].tr,
                      isblack: true,
                      isbold: true,
                      fontsize: 9),
                  pw.SizedBox(height: 5),
                  ...List.generate(
                      invoices[indexInvoices].length,
                      (index) => pw.Column(children: [
                            pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                infoText(
                                  value:
                                      "${invoices[indexInvoices][index]['name']} :  ",
                                  isblack: true,
                                ),
                                infoText(
                                  value:
                                      "${formatter.format(ParseNumbers.parseDouble(invoices[indexInvoices][index]['value']))} ${(indexInvoices - 4) == 0 ? "units".tr : "S.R".tr}",
                                  isblack: true,
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 5),
                          ])),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      infoText(
                        value:
                            "${totalDataInvoice[indexInvoices - 4]['name']} :",
                        isblack: true,
                      ),
                      infoText(
                        value:
                            "${formatter.format(ParseNumbers.parseDouble(totalDataInvoice[indexInvoices - 4]['value'].toString()))} ${(indexInvoices - 4) == 0 ? "units".tr : "S.R".tr}",
                        // "${totalDataInvoice[indexInvoices - 4]['value']} ${"S.R".tr}",
                        isblack: true,
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                ],
              ] else ...[
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    infoText(
                      value: "${invoicestitle[indexInvoices].tr} : ",
                      isblack: true,
                    ),
                    infoText(
                      value:
                          "${formatter.format(ParseNumbers.parseDouble(invoices[indexInvoices].toString()))} ${"S.R".tr}",
                      // "${invoices[indexInvoices]} ${"S.R".tr} ",
                      isblack: true,
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
              ]
            ],
          );
        },
      ),
      if (refund.isNotEmpty) ...[
        divider(padding: 22),
        pw.SizedBox(height: 5),
        infoText(
            value: 'out_refund'.tr, isblack: true, isbold: true, fontsize: 9),
        pw.SizedBox(height: 5),
      ],
      ...List.generate(
        refund.length,
        (indexRefund) {
          print(refund);
          return pw.Column(
            children: [
              if (indexRefund > 3) ...[
                if (indexRefund == (refund.length - 1) &&
                    refund[indexRefund].length == 0) ...[
                  pw.Container()
                ] else ...[
                  divider(padding: 22),
                  pw.SizedBox(height: 5),
                  infoText(
                      value: refundtitle[indexRefund],
                      isblack: true,
                      isbold: true,
                      fontsize: 9),
                  pw.SizedBox(height: 5),
                  ...List.generate(
                      refund[indexRefund].length,
                      (index) => pw.Column(children: [
                            pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                infoText(
                                  value:
                                      "${refund[indexRefund][index]['name']} :  ",
                                  isblack: true,
                                ),
                                infoText(
                                  value:
                                      // "${refund[indexRefund][index]['value']} ${"S.R".tr}",
                                      "${formatter.format(ParseNumbers.parseDouble(refund[indexRefund][index]['value'].toString()))} ${(indexRefund - 4) == 0 ? "units".tr : "S.R".tr}",
                                  isblack: true,
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 5),
                          ])),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      infoText(
                        value: "${totalDataRefund[indexRefund - 4]['name']} :",
                        isblack: true,
                      ),
                      infoText(
                        value:
                            // "${totalDataRefund[indexRefund - 4]['value']} ${"S.R".tr}",
                            "${formatter.format(ParseNumbers.parseDouble(totalDataRefund[indexRefund - 4]['value'].toString()))} ${(indexRefund - 4) == 0 ? "units".tr : "S.R".tr}",
                        isblack: true,
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.SizedBox(height: 5),
                ]
              ] else ...[
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    infoText(
                      value: "${refundtitle[indexRefund].tr} :  ",
                      isblack: true,
                    ),
                    infoText(
                      value:
                          // "${refund[indexRefund]} ${"S.R".tr}",
                          "${formatter.format(ParseNumbers.parseDouble(refund[indexRefund].toString()))} ${"S.R".tr}",
                      isblack: true,
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
              ]
            ],
          );
        },
      ),
      divider(padding: 22),
      pw.SizedBox(height: 5),
      infoText(
        value: "${sessionInfo[sessionInfo.length - 1]} ",
        isblack: true,
      ),
      pw.SizedBox(height: 5),
      infoText(value: 'Thank you !', isblack: true, isbold: true, fontsize: 9),
    ]),
  ));

  return pdf;
}

divider({double? padding}) {
  return pw.Padding(
      padding: pw.EdgeInsets.symmetric(horizontal: padding ?? 0),
      child: pw.Column(children: [
        pw.Divider(height: 0, borderStyle: pw.BorderStyle.dashed),
        pw.SizedBox(height: 2),
        pw.Divider(height: 0, borderStyle: pw.BorderStyle.dashed),
      ]));
}
