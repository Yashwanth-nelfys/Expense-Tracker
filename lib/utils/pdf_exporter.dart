import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../controllers/expense_controller.dart';

Future<void> exportToPdf(
  GlobalKey chartKey,
  ExpenseController controller,
  Map<String, Color> categoryColors,
) async {
  try {
    // ---- Capture Pie Chart as Image ----
    final boundary =
        chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    final fontRegular = pw.Font.ttf(await rootBundle
        .load("assets/fonts/NotoSans-VariableFont_wdth,wght.ttf"));

    final pdf = pw.Document();
    final chartImage = pw.MemoryImage(pngBytes);

    // ---- Load Logo ----
    final logoBytes = await rootBundle.load('assets/full-logo.png');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    // ---- Determine selected period label ----
    String periodLabel;
    if (controller.showAllDates.value ||
        controller.selectedDate.value == null) {
      final monthName = DateFormat('MMMM yyyy').format(
        DateTime(controller.selectedYear.value, controller.selectedMonth.value),
      );
      periodLabel = "Report for $monthName";
    } else {
      final date = controller.selectedDate.value!;
      periodLabel = "Report for ${DateFormat('d MMM yyyy').format(date)}";
    }

    // ---- Calculate percentages for legend ----
    final total = controller.totalSpent;

    final grouped = groupBy(controller.filteredExpenses, (e) => e.category);

    final legendData = <String, Map<String, double>>{};
    grouped.forEach((category, expenses) {
      final sum = expenses.fold(0.0, (s, e) => s + e.amount);
      final percent = total > 0 ? (sum / total * 100) : 0.0;
      legendData[category] = {"amount": sum, "percent": percent};
    });

    // ---- Add Page ----
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ---------- HEADER with Logo + Branding ----------
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Image(logo, width: 48, height: 48),
                  pw.SizedBox(width: 12),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Spendric",
                          style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold)),
                      pw.Text("Smart Expense Manager",
                          style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: 12,
                              color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // ---------- Report Title ----------
              pw.Text(
                "Expense Analysis Report",
                style: pw.TextStyle(
                    font: fontRegular,
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 6),
              pw.Text(periodLabel,
                  style: pw.TextStyle(
                      font: fontRegular,
                      fontSize: 14,
                      color: PdfColors.grey700)),
              pw.SizedBox(height: 20),

              // ---------- Pie Chart ----------
              pw.Center(
                child: pw.Image(chartImage, width: 300, height: 300),
              ),
              pw.SizedBox(height: 20),

              // ---------- Legend ----------
              pw.Text("Legend",
                  style: pw.TextStyle(
                      font: fontRegular,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Wrap(
                spacing: 12,
                runSpacing: 8,
                children: legendData.entries.map((entry) {
                  final category = entry.key;
                  final data = entry.value;
                  final percent = data["percent"] ?? 0;
                  final amount = data["amount"] ?? 0;

                  final flutterColor = categoryColors[category] ?? Colors.grey;
                  final pdfColor = PdfColor.fromInt(flutterColor.value);

                  return pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Container(width: 12, height: 12, color: pdfColor),
                      pw.SizedBox(width: 6),
                      pw.Text(
                        "$category: ₹${amount.toStringAsFixed(2)} "
                        "(${percent.toStringAsFixed(1)}%)",
                        style: pw.TextStyle(font: fontRegular, fontSize: 12),
                      ),
                    ],
                  );
                }).toList(),
              ),

              pw.SizedBox(height: 20),
              pw.Divider(),

              // ---------- Summary ----------
              pw.Text("Summary",
                  style: pw.TextStyle(
                      font: fontRegular,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              ...controller.filteredExpenses.map((e) {
                return pw.Text(
                    "• ${e.category} - ₹${e.amount.toStringAsFixed(2)}",
                    style: pw.TextStyle(font: fontRegular, fontSize: 12));
              }),

              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.Text(
                "Total: ₹${controller.totalSpent.toStringAsFixed(2)}",
                style: pw.TextStyle(
                    font: fontRegular,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold),
              ),

              pw.Spacer(),

              // ---------- Footer ----------
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  "Generated by Spendric • ${DateFormat('d MMM yyyy, hh:mm a').format(DateTime.now())}",
                  style: pw.TextStyle(
                      font: fontRegular,
                      fontSize: 10,
                      color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
        bytes: await pdf.save(), filename: "Spendric_Expense_Report.pdf");
  } catch (e) {
    print("Error generating PDF: $e");
  }
}

Map<String, List<T>> groupBy<T>(Iterable<T> list, String Function(T) keyFn) {
  final map = <String, List<T>>{};
  for (var element in list) {
    final key = keyFn(element);
    map.putIfAbsent(key, () => []).add(element);
  }
  return map;
}
