import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../controllers/expense_controller.dart';
import '../models/expense_model.dart';

Future<Uint8List?> _captureWidgetAsImage(Widget widget) async {
  final repaintBoundary = GlobalKey();

  final RenderRepaintBoundary boundary = await Navigator.of(Get.context!)
      .push(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) => Material(
        color: Colors.transparent,
        child: Center(
          child: RepaintBoundary(
            key: repaintBoundary,
            child: SizedBox(
              width: 400,
              height: 300,
              child: widget,
            ),
          ),
        ),
      ),
    ),
  )
      .then((_) {
    return repaintBoundary.currentContext!.findRenderObject()
        as RenderRepaintBoundary;
  });

  final image = await boundary.toImage(pixelRatio: 3.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData?.buffer.asUint8List();
}

class AdvancedAnalyticsPage extends StatelessWidget {
  AdvancedAnalyticsPage({super.key});

  final controller = Get.find<ExpenseController>();
  Future<void> _exportToPDF() async {
    final fontRegular = pw.Font.ttf(await rootBundle
        .load("assets/fonts/NotoSans-VariableFont_wdth,wght.ttf"));

    final pdf = pw.Document();
    final insight = generateInsight(controller.filteredExpenses);

    // 📸 Chart Images (Render as Images from Flutter)
    final pieImage = await _captureWidgetAsImage(
        _buildCategoryTrendChart(controller.filteredExpenses));
    final barImage = await _captureWidgetAsImage(
        _buildMonthlyBarChart(controller.filteredExpenses));

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text("💡 Monthly Insight",
              style: pw.TextStyle(
                  font: fontRegular,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text(insight,
              style: pw.TextStyle(font: fontRegular, fontSize: 14)),
          pw.SizedBox(height: 20),
          pw.Text("📅 Monthly Spending Overview",
              style: pw.TextStyle(font: fontRegular, fontSize: 16)),
          pw.SizedBox(height: 10),
          if (barImage != null) pw.Image(pw.MemoryImage(barImage), height: 200),
          pw.SizedBox(height: 20),
          pw.Text("🏷 Category Breakdown",
              style: pw.TextStyle(font: fontRegular, fontSize: 16)),
          pw.SizedBox(height: 10),
          if (pieImage != null) pw.Image(pw.MemoryImage(pieImage), height: 200),
        ],
      ),
    );

    // await Printing.layoutPdf(onLayout: (format) => pdf.save());
    await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: "Spendric_Expense_Analytical_Report.pdf");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Advanced Analytics"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export to PDF',
            onPressed: () => _exportToPDF(),
          ),
        ],
      ),
      body: Obx(() {
        final List<ExpenseModel> expenses = controller.filteredExpenses;

        if (expenses.isEmpty) {
          return const Center(child: Text("No expenses to analyze yet."));
        }

        final insight = generateInsight(expenses);
        final trendData = _getWeeklyTrend(expenses);
        final categoryData = _getCategoryBreakdown(expenses);

        return SingleChildScrollView(
          padding: const EdgeInsets.only(
            bottom: 50,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    insight,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "📊 Spending Trends (Mon–Sun)",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 250,
                child: trendData.every((spot) => spot.y == 0)
                    ? const Center(child: Text("No trend data available."))
                    : LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: 6,
                          minY: 0,
                          lineBarsData: [
                            LineChartBarData(
                              spots: trendData,
                              isCurved: true,
                              barWidth: 3,
                              color: Colors.blue,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const days = [
                                    "Mon",
                                    "Tue",
                                    "Wed",
                                    "Thu",
                                    "Fri",
                                    "Sat",
                                    "Sun"
                                  ];
                                  if (value >= 0 && value <= 6) {
                                    return Text(days[value.toInt()]);
                                  }
                                  return const Text("");
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true, reservedSize: 30),
                            ),
                          ),
                          gridData: const FlGridData(show: true),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              const Text(
                "🏷 Category Breakdown",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 250,
                child: categoryData.isEmpty
                    ? const Center(child: Text("No category data available."))
                    : PieChart(
                        PieChartData(
                          sections: categoryData,
                          centerSpaceRadius: 40,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              const Text(
                "📅 Monthly Spending Overview",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _buildMonthlyBarChart(expenses),
              const SizedBox(height: 20),
              const Text(
                "📈 Category Spending Trends",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _buildCategoryTrendChart(expenses),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMonthlyBarChart(List<ExpenseModel> expenses) {
    final monthlyTotals = List<double>.filled(12, 0);

    for (var e in expenses) {
      if (e.date.year == DateTime.now().year) {
        monthlyTotals[e.date.month - 1] += e.amount;
      }
    }

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: List.generate(12, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: monthlyTotals[index],
                  color: Colors.deepPurple,
                  width: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  const months = [
                    'J',
                    'F',
                    'M',
                    'A',
                    'M',
                    'J',
                    'J',
                    'A',
                    'S',
                    'O',
                    'N',
                    'D'
                  ];
                  return Text(months[value.toInt()]);
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 32),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true),
        ),
      ),
    );
  }

  Widget _buildCategoryTrendChart(List<ExpenseModel> expenses) {
    final now = DateTime.now();
    final thisYear = now.year;

    // Map<category, Map<month, total>>
    final Map<String, Map<int, double>> categoryMonthMap = {};

    for (var e in expenses) {
      if (e.date.year == thisYear) {
        categoryMonthMap[e.category] ??= {};
        categoryMonthMap[e.category]![e.date.month] =
            (categoryMonthMap[e.category]![e.date.month] ?? 0) + e.amount;
      }
    }

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
    ];

    int colorIndex = 0;

    List<LineChartBarData> lineBars = categoryMonthMap.entries.map((entry) {
      final category = entry.key;
      final monthlyData = entry.value;

      final List<FlSpot> spots = List.generate(12, (i) {
        final month = i + 1;
        final value = monthlyData[month] ?? 0;
        return FlSpot(i.toDouble(), value);
      });

      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: 2,
        dotData: const FlDotData(show: false),
      );
    }).toList();

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          lineBarsData: lineBars,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  const months = [
                    'J',
                    'F',
                    'M',
                    'A',
                    'M',
                    'J',
                    'J',
                    'A',
                    'S',
                    'O',
                    'N',
                    'D'
                  ];
                  if (value.toInt() >= 0 && value.toInt() < 12) {
                    return Text(months[value.toInt()]);
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 32),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true),
        ),
      ),
    );
  }

  /// Weekly trend
  List<FlSpot> _getWeeklyTrend(List<ExpenseModel> expenses) {
    final totals = List<double>.filled(7, 0);

    for (var e in expenses) {
      final weekdayIndex = e.date.weekday - 1; // Monday = 0
      if (weekdayIndex >= 0 && weekdayIndex < 7) {
        totals[weekdayIndex] += e.amount;
      }
    }

    return List.generate(
      7,
      (i) => FlSpot(i.toDouble(), totals[i]),
    );
  }

  /// Category pie chart
  List<PieChartSectionData> _getCategoryBreakdown(List<ExpenseModel> expenses) {
    final totals = <String, double>{};

    for (var e in expenses) {
      final category = e.category ?? 'Uncategorized';
      totals[category] = (totals[category] ?? 0) + e.amount;
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.brown,
      Colors.cyan,
      Colors.indigo,
    ];

    int i = 0;
    return totals.entries.map((entry) {
      final color = colors[i % colors.length];
      i++;

      return PieChartSectionData(
        value: entry.value,
        title: entry.key,
        radius: 80,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        color: color,
      );
    }).toList();
  }

  /// Monthly insight
  String generateInsight(List<ExpenseModel> expenses) {
    double thisMonth = 0, lastMonth = 0;
    final now = DateTime.now();

    for (var e in expenses) {
      if (e.date.month == now.month && e.date.year == now.year) {
        thisMonth += e.amount;
      } else if (e.date.month == now.month - 1 && e.date.year == now.year) {
        lastMonth += e.amount;
      }
    }

    if (lastMonth == 0) {
      return "📌 This is your first month of tracking!";
    }

    final diff = ((thisMonth - lastMonth) / lastMonth) * 100;
    if (diff > 0) {
      return "⚠️ Your spending increased by ${diff.toStringAsFixed(1)}% this month.";
    } else {
      return "✅ Great! Your spending decreased by ${diff.abs().toStringAsFixed(1)}% this month.";
    }
  }
}
