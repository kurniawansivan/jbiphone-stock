import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

import '../models/phone.dart';
import 'formatters.dart';

class PdfReportGenerator {
  static Future<File> generateSalesReport({
    required List<Phone> phones,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Create PDF document
    final pdf = pw.Document();

    // Try to load font - we'll use a fallback if not available
    pw.Font? font;
    try {
      final fontData =
          await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
      font = pw.Font.ttf(fontData);
    } catch (e) {
      print('Could not load custom font, using default: $e');
      // Will use default font
    }

    // Format phone data for table
    final tableData = phones.map((phone) {
      final basePrice = phone.purchasePrice;
      final servicePrice = phone.servicePrice ?? 0;
      final totalCost = phone.getTotalCost();
      final sellPrice = phone.salePrice ?? 0;
      final profit = phone.getProfit() ?? 0;

      return [
        phone.model,
        phone.imei,
        phone.buyerName ?? '-',
        Formatters.formatDate(phone.saleDate!),
        Formatters.formatCurrency(basePrice),
        Formatters.formatCurrency(servicePrice),
        Formatters.formatCurrency(totalCost),
        Formatters.formatCurrency(sellPrice),
        Formatters.formatCurrency(profit),
      ];
    }).toList();

    // Calculate totals
    double totalBasePrice = 0;
    double totalServicePrice = 0;
    double totalCost = 0;
    double totalSellPrice = 0;
    double totalProfit = 0;

    for (var phone in phones) {
      totalBasePrice += phone.purchasePrice;
      totalServicePrice += phone.servicePrice ?? 0;
      totalCost += phone.getTotalCost();
      totalSellPrice += phone.salePrice ?? 0;
      totalProfit += phone.getProfit() ?? 0;
    }

    // Define theme with font if available
    final theme = pw.ThemeData.withFont(
      base: font,
    );

    // Add pages to PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: font != null ? theme : null,
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(title,
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
                'Periode: ${Formatters.formatDate(startDate)} - ${Formatters.formatDate(endDate)}',
                style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 16),

            // Table
            pw.Table.fromTextArray(
              headers: [
                'Model',
                'IMEI',
                'Buyer',
                'Sale Date',
                'Base Price',
                'Service Price',
                'Total Cost',
                'Sell Price',
                'Profit',
              ],
              data: tableData,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.center,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
              },
              cellPadding: const pw.EdgeInsets.all(5),
            ),

            pw.SizedBox(height: 20),

            // Summary
            pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border.all(color: PdfColors.grey400),
              ),
              padding: const pw.EdgeInsets.all(10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Summary',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 16)),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Phones Sold: ${phones.length}'),
                      pw.Text(
                          'Total Base Price: ${Formatters.formatCurrency(totalBasePrice)}'),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                          'Total Service Price: ${Formatters.formatCurrency(totalServicePrice)}'),
                      pw.Text(
                          'Total Cost: ${Formatters.formatCurrency(totalCost)}'),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                          'Total Revenue: ${Formatters.formatCurrency(totalSellPrice)}'),
                      pw.Text(
                          'Total Profit: ${Formatters.formatCurrency(totalProfit)}',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: totalProfit >= 0
                                  ? PdfColors.green
                                  : PdfColors.red)),
                    ],
                  ),
                ],
              ),
            ),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 10),
            ),
          );
        },
      ),
    );

    // Save PDF to file
    final output = await getTemporaryDirectory();
    final String formattedDate =
        DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final String fileName = 'sales_report_$formattedDate.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static Future<void> openPdfFile(File file) async {
    final result = await OpenFile.open(file.path);
    if (result.type != ResultType.done) {
      throw Exception('Could not open the file: ${result.message}');
    }
  }

  static Future<void> sharePdfFile(File file) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Sales Report',
      subject: 'JBIphone Stock Sales Report',
    );
  }
}
