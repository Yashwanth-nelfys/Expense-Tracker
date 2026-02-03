import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/expense_controller.dart';
import '../utils/csv_exporter.dart';
import '../utils/pdf_exporter.dart';
import '../views/advance_analytics.dart';

class ExpensePieChart extends StatelessWidget {
  ExpensePieChart({super.key});

  final controller = Get.find<ExpenseController>();
  final GlobalKey chartKey = GlobalKey(); // For PDF export

  /// Collect category totals
  Map<String, double> getCategoryTotals() {
    final Map<String, double> data = {};
    for (var e in controller.filteredExpenses) {
      data[e.category] = (data[e.category] ?? 0) + e.amount;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = getCategoryTotals();
      if (data.isEmpty) {
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 120, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "ADD Expenses by clicking On Add button",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        );
      }

      final total = data.values.fold(0.0, (a, b) => a + b);
      final entries = data.entries.toList();
      final colors = List.generate(
        entries.length,
        (i) => Colors.primaries[i % Colors.primaries.length],
      );

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Spending by Category",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            /// PIE CHART + CENTER LABEL
            AspectRatio(
              aspectRatio: 1.3,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  RepaintBoundary(
                    key: chartKey,
                    child: Obx(() {
                      return PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              if (!event.isInterestedForInteractions ||
                                  response == null ||
                                  response.touchedSection == null) {
                                controller.touchedIndex.value = -1;
                                return;
                              }
                              controller.touchedIndex.value =
                                  response.touchedSection!.touchedSectionIndex;
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 2,
                          centerSpaceRadius: 60,
                          sections: List.generate(entries.length, (i) {
                            final entry = entries[i];
                            final percent = (entry.value / total * 100);
                            final isTouched =
                                i == controller.touchedIndex.value;

                            return PieChartSectionData(
                              color: colors[i],
                              value: entry.value,
                              title: isTouched
                                  ? "${percent.toStringAsFixed(1)}%"
                                  : "",
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              radius: isTouched ? 70 : 60,
                            );
                          }),
                        ),
                        swapAnimationDuration:
                            const Duration(milliseconds: 300),
                        swapAnimationCurve: Curves.easeOut,
                      );
                    }),
                  ),

                  /// CENTER LABEL (changes on tap)
                  Obx(() {
                    final touchedIndex = controller.touchedIndex.value;
                    final label = touchedIndex == -1
                        ? "Total"
                        : entries[touchedIndex].key;
                    final value = touchedIndex == -1
                        ? total
                        : entries[touchedIndex].value;

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        key: ValueKey("$label-$value"),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            "₹${value.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 10),

            /// LEGEND
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: List.generate(entries.length, (i) {
                final entry = entries[i];
                final isTouched = i == controller.touchedIndex.value;
                return CategoryIndicator(
                  color: colors[i],
                  text: entry.key,
                  isBold: isTouched,
                );
              }),
            ),

            const SizedBox(height: 20),

            /// EXPORT BUTTONS
            SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: controller.expenses.isEmpty
                        ? null
                        : () async {
                            final path = await CsvExporter.exportExpenses(
                                controller.expenses);
                            await Share.shareXFiles([XFile(path)],
                                text: "Here is my exported expense data.");
                          },
                    child: const Text("Export to CSV"),
                  ),
                  ElevatedButton(
                    onPressed: controller.expenses.isEmpty
                        ? null
                        : () async {
                            final categoryColors = <String, Color>{};
                            for (var i = 0; i < entries.length; i++) {
                              categoryColors[entries[i].key] = colors[i];
                            }
                            await exportToPdf(
                                chartKey, controller, categoryColors);
                            // await Share.shareXFiles([XFile(path)],
                            //     text: "Expense Report (PDF)");
                          },
                    child: const Text("Export to PDF"),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => Get.to(() => AdvancedAnalyticsPage()),
                    child: const Text("Advanced Analytics"),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class CategoryIndicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isBold;

  const CategoryIndicator({
    super.key,
    required this.color,
    required this.text,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
