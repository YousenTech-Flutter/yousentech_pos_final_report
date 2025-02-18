// ignore_for_file: unused_field, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:pos_shared_preferences/helper/app_enum.dart';
import 'package:pos_shared_preferences/models/final_report_info.dart';
import 'package:pos_shared_preferences/models/sale_order.dart';
import 'package:pos_shared_preferences/pos_shared_preferences.dart';
import 'package:shared_widgets/config/app_odoo_models.dart';
import 'package:shared_widgets/shared_widgets/handle_exception_helper.dart';
import 'package:shared_widgets/shared_widgets/odoo_connection_helper.dart';
import 'package:yousentech_pos_final_report/final_report/src/domain/final_report_repository.dart';
import 'package:yousentech_pos_local_db/yousentech_pos_local_db.dart';
import 'package:flutter/foundation.dart';

class FinalReportService extends FinalReportRepository {
  GeneralLocalDB<SaleOrderInvoice>? _generalLocalDBInstance;
  static FinalReportService? invoiceOperationService;

  FinalReportService._() {
    _generalLocalDBInstance = GeneralLocalDB.getInstance<SaleOrderInvoice>(
            fromJsonFun: SaleOrderInvoice.fromJson)
        as GeneralLocalDB<SaleOrderInvoice>?;
  }

  static FinalReportService getInstance() {
    invoiceOperationService = invoiceOperationService ?? FinalReportService._();
    return invoiceOperationService!;
  }

//
//   @override
//   Future<dynamic> finalReportInfo() async {
//     try {
//       // if (kDebugMode) {
//       //   print(
//       //       'finalReportInfo ::: ================================= ${SharedPr.currentSaleSession?.id}');
//       // }
//       // SUM OF OUT REFUND & OUT INVOICE
//       var results = await DbHelper.db!.rawQuery('''SELECT
//               SUM(CASE WHEN move_type = 'out_refund' THEN total_price ELSE 0.0 END) AS total_out_refund,
//               SUM(CASE WHEN move_type = 'out_invoice' THEN total_price ELSE 0.0 END) AS total_out_invoice,
//               possession.start_date, possession.end_date, possession.balance_opening, possession.last_balance_opening
//               FROM saleorderinvoice INNER JOIN possession ON saleorderinvoice.session_number == possession.id
//               WHERE session_number = ${SharedPr.currentSaleSession?.id}''');
//       //// session_number = ${SharedPr.currentSaleSession?.id}
//       var results2 = await DbHelper.db!.rawQuery('''
//             SELECT
//               json_extract(json_data.value, '\$.id') AS id,
//               SUM(CAST(json_extract(json_data.value, '\$.amount') AS REAL)) AS total_amount,
//               aj.name AS account_journal_name,
//               aj.type AS type,
//               saleorderinvoice.move_type,
//               COUNT(saleorderinvoice.id) AS invoice_count
//             FROM
//               saleorderinvoice,
//               json_each(invoice_chosen_payment) AS json_data
//             JOIN
//               accountjournal aj
//             ON
//               json_extract(json_data.value, '\$.id') = aj.id
//             WHERE session_number = ? AND state IN (?, ?)
//             GROUP BY json_extract(json_data.value, '\$.id'), aj.name, move_type;
//           ''', [
//         SharedPr.currentSaleSession?.id,
//         InvoiceState.posted.name,
//         InvoiceState.saleOrder.name
//       ]);
//       var results3 = await DbHelper.db!.rawQuery('''
//               SELECT poscategory.name, product.so_pos_categ_id, sum(saleorderline.product_uom_qty) as total_qty,saleorderinvoice.move_type
//               from saleorderinvoice
//               INNER JOIN saleorderline
//               on saleorderinvoice.id == saleorderline.order_id
//               INNER join product
//               on saleorderline.product_id == product.product_id
//               INNER join poscategory
//               on poscategory.id == product.so_pos_categ_id
//               WHERE session_number = ${SharedPr.currentSaleSession?.id}
//               GROUP by product.so_pos_categ_id,move_type
//              ''');
//
//       var result4 = await DbHelper.db!.rawQuery('''
//               SELECT sum(saleorderinvoice.total_discount) as total_discount,
//               sum( saleorderinvoice.total_price_subtotal) as total_price_subtotal,
//               sum( saleorderinvoice.total_price) as total_price,
//               sum( saleorderinvoice.total_taxes) as total_taxes,
//               saleorderinvoice.move_type
//               from saleorderinvoice
//               WHERE session_number =  ${SharedPr.currentSaleSession?.id}
//               GROUP by move_type
//             ''');
//
//       var result5 = await DbHelper.db!.rawQuery('''
//               SELECT sum(total_price) as total, state from saleorderinvoice
//               WHERE session_number =  ${SharedPr.currentSaleSession?.id}
//               GROUP by state
//             ''');
//       // var results6 = await DbHelper.db!.rawQuery('''
//       //         SELECT product.product_name, product.product_id, sum(saleorderline.product_uom_qty) as total_qty ,  poscategory.id as category
//       //         from saleorderinvoice
//       //         INNER JOIN saleorderline
//       //         on saleorderinvoice.id == saleorderline.order_id
//       //         INNER join product
//       //         on saleorderline.product_id == product.product_id
//       //         INNER join poscategory
//       //         on poscategory.id == product.so_pos_categ_id
//       //         WHERE session_number = ${SharedPr.currentSaleSession?.id}
//
//       //         GROUP by product.product_name
//       //         ORDER by total_qty DESC
//       //         limit 10
//       //        ''');
//       var results6 = await DbHelper.db!.rawQuery('''
//               SELECT product.product_name, product.product_id, sum(saleorderline.product_uom_qty) as total_qty , product.so_pos_categ_id as category
//               from saleorderinvoice
//               INNER JOIN saleorderline
//               on saleorderinvoice.id == saleorderline.order_id
//               INNER join product
//               on saleorderline.product_id == product.product_id
//               WHERE session_number = ${SharedPr.currentSaleSession?.id}
//               GROUP by  product.so_pos_categ_id , product.product_name
//               ORDER by total_qty DESC
//               limit 10
//              ''');
//
//
// // var resultsss = await DbHelper.db!.rawQuery('''
// //   SELECT
// //       p.product_name,
// //       c.name,
// //       SUM(l.product_uom_qty) AS total_quantity_sold
// //   FROM
//
// //       saleorderline l
// //       INNER JOIN product p on l.product_id == p.product_id
// //       INNER JOIN saleorderinvoice s  ON l.order_id = s.id
//
// //   INNER JOIN poscategory c ON p.so_pos_categ_id = c.id
// //   GROUP BY c.name , p.product_name
// //   ORDER by c.name , total_quantity_sold DESC
// // ''');
//
//       var results7 = await DbHelper.db!.rawQuery('''
//               SELECT product.product_name, product.product_id, sum(saleorderline.product_uom_qty) as total_qty,  (sum(saleorderline.product_uom_qty) * product.unit_price) as total_price ,  product.unit_price
//               from saleorderinvoice
//               INNER JOIN saleorderline
//               on saleorderinvoice.id == saleorderline.order_id
//               INNER join product
//               on saleorderline.product_id == product.product_id
//               WHERE session_number = ${SharedPr.currentSaleSession?.id}
//               GROUP by product.product_name
//               ORDER by total_qty DESC
//               limit 10
//              ''');
//
//   Map<int, Map<String, dynamic>> maxQtyByCategory = {};
//
//   for (var product in results6) {
//     var category = product['category'] as int;
//     var totalQty = product['total_qty'] as int;
//
//     if (!maxQtyByCategory.containsKey(category) || totalQty > maxQtyByCategory[category]!['total_qty']) {
//       maxQtyByCategory[category] = {
//         'product_name': product['product_name'],
//         'product_id': product['product_id'],
//         'total_qty': totalQty,
//       };
//     }
//   }
//   List product_based_categories = maxQtyByCategory.values.map((value) => value).toList();
//
//
//
//
//       //  if (kDebugMode) {
//       // print("finalReportInfo results7 :: = $results7");
//       // print("finalReportInfo maxQtyByCategory :: = $maxQtyByCategory");
//       //   print("finalReportInfo results3 :: = $results3");
//       //   print("finalReportInfo result4 :: = $result4");
//       //   print("finalReportInfo result5 :: = $result5");
//       //   // print("finalReportInfo RESULT 2 newOne :: = $newOne");
//       // }
//       Map<String, dynamic> newOne = {};
//       newOne.addAll(results[0]);
//       newOne.addAll({'invoice_payment_options': results2});
//       newOne.addAll({'quantities_based_on_categories': results3});
//       newOne.addAll({'sale_order_summery': result4});
//       newOne.addAll({'amounts_based_state': result5});
//       // newOne.addAll({'product_based_categories': results6});
//       newOne.addAll({'product_based_categories': product_based_categories});
//       newOne.addAll({'based_selling_product': results7});
//       // print("newOne ${newOne}");
//       return FinalReportInfo.fromJson(newOne);
//     } catch (e) {
//       throw handleException(
//           exception: e, navigation: false, methodName: "finalReportInfo");
//     }
//   }

  String getDateFilter(String filter) {
    switch (filter) {
      case 'today':
        return "DATE('now')";
      case 'month':
        return "strftime('%Y-%m', DATE('now'))";
      case 'week':
        return "strftime('%Y-%W', DATE('now'))";
      case 'current_quarter':
        return '''
        CASE 
          WHEN CAST(strftime('%m', DATE('now')) AS INTEGER) BETWEEN 1 AND 3 THEN 1
          WHEN CAST(strftime('%m', DATE('now')) AS INTEGER) BETWEEN 4 AND 6 THEN 2
          WHEN CAST(strftime('%m', DATE('now')) AS INTEGER) BETWEEN 7 AND 9 THEN 3
          ELSE 4
        END
      ''';
      case 'current_year':
        return "strftime('%Y', DATE('now'))";
      case 'last_day':
        return "DATE('now', '-1 day')";
      case 'last_month':
        return "strftime('%Y-%m', DATE('now', '-1 month'))";
      case 'last_week':
        return "strftime('%Y-%W', DATE('now', '-1 week'))";
      case 'last_quarter':
        return '''
        CASE 
          WHEN CAST(strftime('%m', DATE('now', '-3 months')) AS INTEGER) BETWEEN 1 AND 3 THEN 1
          WHEN CAST(strftime('%m', DATE('now', '-3 months')) AS INTEGER) BETWEEN 4 AND 6 THEN 2
          WHEN CAST(strftime('%m', DATE('now', '-3 months')) AS INTEGER) BETWEEN 7 AND 9 THEN 3
          ELSE 4
        END
      ''';
      case 'last_year':
        return "strftime('%Y', DATE('now', '-1 year'))";
      default:
        return "1=1";
    }
  }

  String formattedDate({required String filterKey, required String dateField}) {
    switch (filterKey) {
      case 'today':
        return "DATE($dateField)";
      case 'month':
        return "strftime('%Y-%m', DATE($dateField))";
      case 'week':
        return "strftime('%Y-%W', DATE($dateField))";
      case 'current_quarter':
        return '''
        CASE 
          WHEN CAST(strftime('%m', DATE($dateField)) AS INTEGER) BETWEEN 1 AND 3 THEN 1
          WHEN CAST(strftime('%m', DATE($dateField)) AS INTEGER) BETWEEN 4 AND 6 THEN 2
          WHEN CAST(strftime('%m', DATE($dateField)) AS INTEGER) BETWEEN 7 AND 9 THEN 3
          ELSE 4
        END
      ''';
      case 'current_year':
        return "strftime('%Y', DATE($dateField))";
      case 'last_day':
        return "DATE($dateField)";
      case 'last_month':
        return "strftime('%Y-%m', DATE($dateField))";
      case 'last_week':
        return "strftime('%Y-%W', DATE($dateField))";
      case 'last_quarter':
        return '''
        CASE 
          WHEN CAST(strftime('%m', DATE($dateField)) AS INTEGER) BETWEEN 1 AND 3 THEN 1
          WHEN CAST(strftime('%m', DATE($dateField)) AS INTEGER) BETWEEN 4 AND 6 THEN 2
          WHEN CAST(strftime('%m', DATE($dateField)) AS INTEGER) BETWEEN 7 AND 9 THEN 3
          ELSE 4
        END
      ''';
      case 'last_year':
        return "strftime('%Y', DATE($dateField))";
      default:
        return "1=1";
    }
  }

  @override
  Future<dynamic> finalReportInfo(
      {String dateFilterKey = 'week',
      bool isSessionList = false,
      int? id}) async {
    try {
      var results10;
      var results2;
      // Retrieve the date filter SQL clause based on the selected key
      String dateFilter = getDateFilter(dateFilterKey);
      bool isSportJsonExtract = await DbHelper.testJsonExtract();
      if (kDebugMode) {
        print("isSportJsonExtract $isSportJsonExtract");
      }
      var results = await DbHelper.db!.rawQuery('''
        SELECT 
          SUM(CASE WHEN move_type = 'out_refund' THEN total_price ELSE 0.0 END) AS total_out_refund,
          SUM(CASE WHEN move_type = 'out_invoice' THEN total_price ELSE 0.0 END) AS total_out_invoice,
          possession.start_date, possession.end_date, possession.balance_opening, possession.last_balance_opening
        FROM saleorderinvoice 
        INNER JOIN possession 
          ON saleorderinvoice.session_number = possession.id
     WHERE saleorderinvoice.session_number =   ${isSessionList ? "$id" : "${SharedPr.currentSaleSession?.id}  AND ${formattedDate(filterKey: dateFilterKey, dateField: 'saleorderinvoice.create_date')} = $dateFilter"}        
      ''');
      if (!isSportJsonExtract) {
        results2 = await fetchInvoicePaymentOptions(
            id: id,
            dateFilterKey: dateFilterKey,
            isSessionList: isSessionList,
            dateFilter: dateFilter);
      } else {
        results2 = await DbHelper.db!.rawQuery('''
          SELECT 
            json_extract(json_data.value, '\$.id') AS id,
            SUM(CAST(json_extract(json_data.value, '\$.amount') AS REAL)) - 
            CASE WHEN aj.type = 'cash' THEN SUM(change) ELSE 0.0 END AS total_amount,
            aj.name AS account_journal_name,
            aj.type AS type,
            saleorderinvoice.move_type,
            COUNT(saleorderinvoice.id) AS invoice_count
          FROM 
            saleorderinvoice,
            json_each(invoice_chosen_payment) AS json_data
          JOIN 
            accountjournal aj 
            ON json_extract(json_data.value, '\$.id') = aj.id
          WHERE session_number = ?
            AND state IN (?, ?)
          ${isSessionList ? "" : " AND ${formattedDate(filterKey: dateFilterKey, dateField: 'saleorderinvoice.create_date')} = $dateFilter"}    
          GROUP BY json_extract(json_data.value, '\$.id'), aj.name, move_type;
        ''', [
          isSessionList ? id : SharedPr.currentSaleSession?.id,
          InvoiceState.posted.name,
          InvoiceState.saleOrder.name
        ]);
      }
      var results3 = await DbHelper.db!.rawQuery('''
          SELECT 
            poscategory.name, 
            product.so_pos_categ_id, 
            SUM(saleorderline.product_uom_qty) AS total_qty,
            saleorderinvoice.move_type 
          FROM saleorderinvoice
          INNER JOIN saleorderline 
            ON saleorderinvoice.id == saleorderline.order_id
          INNER JOIN product 
            ON saleorderline.product_id == product.product_id
          INNER JOIN poscategory 
            ON poscategory.id == product.so_pos_categ_id
          WHERE session_number = ${isSessionList ? "$id" : "${SharedPr.currentSaleSession?.id}  AND ${formattedDate(filterKey: dateFilterKey, dateField: 'saleorderinvoice.create_date')} = $dateFilter"} 
          GROUP BY product.so_pos_categ_id, move_type
        ''');

      var result4 = await DbHelper.db!.rawQuery('''
        SELECT 
          SUM(saleorderinvoice.total_discount) AS total_discount,
          SUM(saleorderinvoice.total_price_subtotal) AS total_price_subtotal,
          SUM(saleorderinvoice.total_price) AS total_price,
          SUM(saleorderinvoice.total_taxes) AS total_taxes,
          saleorderinvoice.move_type
        FROM saleorderinvoice
        WHERE session_number = ${isSessionList ? "$id" : "${SharedPr.currentSaleSession?.id}  AND ${formattedDate(filterKey: dateFilterKey, dateField: 'saleorderinvoice.create_date')} = $dateFilter"} 
        GROUP BY move_type;
      ''');

      var result5 = await DbHelper.db!.rawQuery('''
          SELECT 
            SUM(total_price) AS total, 
            state 
          FROM saleorderinvoice
          WHERE session_number = ${isSessionList ? "$id" : "${SharedPr.currentSaleSession?.id}  AND ${formattedDate(filterKey: dateFilterKey, dateField: 'saleorderinvoice.create_date')} = $dateFilter"} 
          GROUP BY state;
        ''');

      var results6 = await DbHelper.db!.rawQuery('''
          SELECT 
            product.product_name, 
            product.product_id, 
            SUM(saleorderline.product_uom_qty) AS total_qty, 
            product.so_pos_categ_id AS category
          FROM saleorderinvoice
          INNER JOIN saleorderline 
            ON saleorderinvoice.id == saleorderline.order_id
          INNER JOIN product 
            ON saleorderline.product_id == product.product_id
          WHERE session_number = ${isSessionList ? "$id" : "${SharedPr.currentSaleSession?.id}  AND ${formattedDate(filterKey: dateFilterKey, dateField: 'saleorderinvoice.create_date')} = $dateFilter"}  
          GROUP BY product.so_pos_categ_id, product.product_name
          ORDER BY total_qty DESC 
          LIMIT 10;
        ''');

      var results7 = await DbHelper.db!.rawQuery('''
          SELECT 
            product.product_name, 
            product.product_id, 
            SUM(saleorderline.product_uom_qty) AS total_qty,  
            (SUM(saleorderline.product_uom_qty) * product.unit_price) AS total_price,  
            product.unit_price 
          FROM saleorderinvoice
          INNER JOIN saleorderline 
            ON saleorderinvoice.id == saleorderline.order_id
          INNER JOIN product 
            ON saleorderline.product_id == product.product_id
          WHERE session_number = ${isSessionList ? "$id" : "${SharedPr.currentSaleSession?.id}  AND ${formattedDate(filterKey: dateFilterKey, dateField: 'saleorderinvoice.create_date')} = $dateFilter"} 
          GROUP BY product.product_name
          ORDER BY total_qty DESC 
          LIMIT 10;
        ''');

      var results8 = await DbHelper.db!.rawQuery('''
        SELECT *
        FROM possession 
        WHERE state = ? ${isSessionList ? "" : " AND ${formattedDate(filterKey: dateFilterKey, dateField: 'start_date')} = $dateFilter"}  
        ORDER BY total_sales DESC 
        LIMIT 3;
      ''', [SessionState.closedSession.text]);

      var results9 = await DbHelper.db!.rawQuery('''
        SELECT product_id , product_name , available_qty
        FROM Product 
        ORDER BY available_qty ASC 
        LIMIT 3;
      ''');

      if (!isSportJsonExtract) {
        results10 = await fetchUnlinkedPayment(
            id: id, isSessionList: isSessionList, dateFilterKey: dateFilterKey);
      } else {
        results10 = await DbHelper.db!.rawQuery('''
          SELECT 
            json_extract(json_data.value, '\$.id') AS id,
            SUM(CAST(json_extract(json_data.value, '\$.amount') AS REAL)) - 
            CASE WHEN aj.type = 'cash' THEN SUM(change) ELSE 0.0 END AS total_amount,
            aj.name AS account_journal_name,
            aj.type AS type,
            saleorderinvoice.move_type,
            saleorderinvoice.payment_ids,
            COUNT(saleorderinvoice.id) AS invoice_count
          FROM 
            saleorderinvoice,
            json_each(invoice_chosen_payment) AS json_data
          JOIN 
            accountjournal aj 
            ON json_extract(json_data.value, '\$.id') = aj.id
          WHERE session_number = ?
            AND state IN (?, ?)
          ${isSessionList ? "AND payment_ids != 'null'" : " AND ${formattedDate(filterKey: dateFilterKey, dateField: 'saleorderinvoice.create_date')} = $dateFilter"}    
          GROUP BY json_extract(json_data.value, '\$.id'), aj.name, move_type;
        ''', [
          isSessionList ? id : SharedPr.currentSaleSession?.id,
          InvoiceState.posted.name,
          InvoiceState.saleOrder.name,
        ]);
      }

      Map<int, Map<String, dynamic>> maxQtyByCategory = {};

      for (var product in results6) {
        var category = product['category'] as int;
        var totalQty = product['total_qty'] as int;

        if (!maxQtyByCategory.containsKey(category) ||
            totalQty > maxQtyByCategory[category]!['total_qty']) {
          maxQtyByCategory[category] = {
            'product_name': product['product_name'],
            'product_id': product['product_id'],
            'total_qty': totalQty,
          };
        }
      }

      List productBasedCategories =
          maxQtyByCategory.values.map((value) => value).toList();
      Map<String, dynamic> newOne = {};
      newOne.addAll(results[0]);
      newOne.addAll({'invoice_payment_options': results2});
      newOne.addAll({'quantities_based_on_categories': results3});
      newOne.addAll({'sale_order_summery': result4});
      newOne.addAll({'amounts_based_state': result5});
      newOne.addAll({'product_based_categories': productBasedCategories});
      newOne.addAll({'based_selling_product': results7});
      newOne.addAll({'top_session': results8});
      newOne.addAll({'Less_products_based_in_availableQty': results9});
      newOne.addAll({'unlinked_payment': results10});
      // if (kDebugMode) {
      //   print('final resultt :::: ${newOne["Less_products_based_in_availableQty"]}');
      // }
      return FinalReportInfo.fromJson(newOne);
    } catch (e) {
      print(" ==========catch finalReportInfo========= $e");
      throw handleException(
          exception: e, navigation: false, methodName: "finalReportInfo");
    }
  }

  Future<dynamic> getCountSessionDraftInvoicesNeedProcess(
      {int? ssessionID}) async {
    try {
      var result = await OdooProjectOwnerConnectionHelper.odooClient.callKw({
        'model': OdooModels.syncInvoiceTransit,
        'method': 'count_session_draft_invoices',
        'args': [ssessionID ?? SharedPr.currentSaleSession!.id],
        'kwargs': {},
      });
      return result;
    } catch (e) {
      return handleException(
          exception: e,
          navigation: true,
          methodName:
              "FinalReportService getCountSessionDraftInvoicesNeedProcess");
    }
  }

  Future fetchInvoicePaymentOptions(
      {String dateFilterKey = 'week',
      bool isSessionList = false,
      int? id,
      String? dateFilter}) async {
    print("fetchInvoicePaymentOptions##########");
    // Fetch raw data
    List<Map<String, dynamic>> rawInvoices = await DbHelper.db!.rawQuery(
      '''
    SELECT id, invoice_chosen_payment, state, session_number, move_type, create_date
    FROM saleorderinvoice
    WHERE session_number = ?
      AND state IN (?, ?)
      ${isSessionList ? "" : " AND ${formattedDate(filterKey: dateFilterKey, dateField: 'create_date')} = ?"}
  ''',
      isSessionList
          ? [
              id,
              InvoiceState.posted.name,
              InvoiceState.saleOrder.name,
            ]
          : [
              SharedPr.currentSaleSession?.id,
              InvoiceState.posted.name,
              InvoiceState.saleOrder.name,
              dateFilter,
            ],
    );
    var testss = await DbHelper.db!.rawQuery('''
  SELECT strftime('%Y-%W', DATE('now'))
''');
    print("testss $testss");
    List<Map<String, dynamic>> rawInvoices2 = await DbHelper.db!.rawQuery(
      '''
    SELECT id, invoice_chosen_payment, state, session_number, move_type, create_date
    FROM saleorderinvoice
    WHERE session_number = ?
      AND state IN (?, ?)
      ${isSessionList ? "" : " AND ${formattedDate(filterKey: dateFilterKey, dateField: 'create_date')} = ?"}
  ''',
      [
        isSessionList ? id : SharedPr.currentSaleSession?.id,
        InvoiceState.posted.name,
        InvoiceState.saleOrder.name,
        testss[0].values
      ],
    );
    List<Map<String, dynamic>> rawInvoices3 = await DbHelper.db!.rawQuery(
      '''
    SELECT id, invoice_chosen_payment, state, session_number, move_type, create_date
    FROM saleorderinvoice
    WHERE session_number = ?
      AND state IN (?, ?)
      ${isSessionList ? "" : " AND strftime('%Y-%W', REPLACE(create_date, 'T', ' ')) = ?"}
  ''',
    isSessionList?  [
        id ,
        InvoiceState.posted.name,
        InvoiceState.saleOrder.name,
      ] :[
         SharedPr.currentSaleSession?.id,
        InvoiceState.posted.name,
        InvoiceState.saleOrder.name,
        testss[0].values
      ],
    );
    print(
        "session_number ${isSessionList ? id : SharedPr.currentSaleSession?.id}");
    print("isSessionList $isSessionList");
    print("dateFilterKey $dateFilterKey");
    print(
        "dateFilterKey ${formattedDate(filterKey: dateFilterKey, dateField: '2025-02-18T12:16:58')}");
    print("dateFilter $dateFilter");
    print("rawInvoices $rawInvoices");
    print("rawInvoices2 $rawInvoices2");
    print("rawInvoices3 $rawInvoices3");
    // List<Map<String, dynamic>> processedResults = [];
    Map<int, Map<String, dynamic>> resultMap = {};

    for (var invoice in rawInvoices) {
      // Parse invoice_chosen_payment (which is stored as a JSON string)
      String jsonString = invoice['invoice_chosen_payment'] ?? '';
      List<dynamic> payments = [];
      if (jsonString != '') {
        payments = jsonDecode(jsonString);
      }
      print("payments $payments");
      for (var payment in payments) {
        int paymentId = payment['id'];
        double amount = double.tryParse(payment['amount'].toString()) ?? 0.0;

        // Fetch account journal info
        List<Map<String, dynamic>> journal = await DbHelper.db!.rawQuery('''
        SELECT name, type FROM accountjournal WHERE id = ?
      ''', [paymentId]);

        if (journal.isNotEmpty) {
          String journalName = journal.first['name'];
          String journalType = journal.first['type'];

          // Calculate total_amount
          double totalAmount = amount;
          if (journalType == 'cash') {
            totalAmount -= invoice['change'] ?? 0.0;
          }
          if (resultMap.containsKey(paymentId)) {
            resultMap[paymentId]!['total_amount'] += totalAmount;
            resultMap[paymentId]!['invoice_count'] += 1;
          } else {
            resultMap[paymentId] = {
              'id': paymentId,
              'total_amount': totalAmount,
              'account_journal_name': journalName,
              'type': journalType,
              'move_type': invoice['move_type'],
              'invoice_count': 1, // Start count
            };
          }
        }
      }
    }
    print("fetchInvoicePaymentOptions values ${resultMap.values.toList()}");
    return resultMap.values.toList();
  }

  Future fetchUnlinkedPayment(
      {String dateFilterKey = 'week',
      bool isSessionList = false,
      int? id}) async {
    // Fetch raw invoices
    List<Map<String, dynamic>> rawInvoices = await DbHelper.db!.rawQuery('''
    SELECT id, invoice_chosen_payment, state, session_number, move_type, create_date, payment_ids, change
    FROM saleorderinvoice
    WHERE session_number = ?
      AND state IN (?, ?)
      ${isSessionList ? "AND payment_ids != 'null'" : " AND ${formattedDate(filterKey: dateFilterKey, dateField: 'create_date')} = ?"}
  ''', [
      isSessionList ? id : SharedPr.currentSaleSession?.id,
      InvoiceState.posted.name,
      InvoiceState.saleOrder.name,
      dateFilterKey
    ]);

    // Map to store aggregated results by payment ID
    Map<int, Map<String, dynamic>> resultMap = {};

    for (var invoice in rawInvoices) {
      // Parse invoice_chosen_payment (stored as a JSON string)
      String jsonString = invoice['invoice_chosen_payment'] ?? '';
      List<dynamic> payments = [];

      if (jsonString != '') {
        payments = jsonDecode(jsonString);
      }

      for (var payment in payments) {
        int paymentId = payment['id'];
        double amount = double.tryParse(payment['amount'].toString()) ?? 0.0;

        // Fetch account journal info
        List<Map<String, dynamic>> journal = await DbHelper.db!.rawQuery('''
        SELECT name, type FROM accountjournal WHERE id = ?
      ''', [paymentId]);

        if (journal.isNotEmpty) {
          String journalName = journal.first['name'];
          String journalType = journal.first['type'];

          // Calculate total_amount
          double totalAmount = amount;
          if (journalType == 'cash') {
            totalAmount -= invoice['change'] ?? 0.0;
          }

          // Aggregate data by id
          if (resultMap.containsKey(paymentId)) {
            resultMap[paymentId]!['total_amount'] += totalAmount;
            resultMap[paymentId]!['invoice_count'] += 1;
          } else {
            resultMap[paymentId] = {
              'id': paymentId,
              'total_amount': totalAmount,
              'account_journal_name': journalName,
              'type': journalType,
              'move_type': invoice['move_type'],
              'payment_ids': invoice['payment_ids'],
              'invoice_count': 1, // Start count
            };
          }
        }
      }
    }

    return resultMap.values.toList();
  }
}
