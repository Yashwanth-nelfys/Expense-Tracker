import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/expense_controller.dart';
import '../routes/app_routes.dart';
import '../utils/csv_exporter.dart';

class SummaryView extends StatelessWidget {
  final controller = Get.find<ExpenseController>();

  SummaryView({super.key});

  Map<String, double> getCategoryTotals() {
    final Map<String, double> data = {};
    for (var e in controller.expenses) {
      data[e.category] = (data[e.category] ?? 0) + e.amount;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Summary")),
      body: Obx(() {
        final data = getCategoryTotals();
        if (data.isEmpty) {
          return const Center(child: Text("No data to show yet."));
        }

        final total = data.values.fold(0.0, (a, b) => a + b);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text("Spending by Category",
                  style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              AspectRatio(
                aspectRatio: 1.3,
                child: PieChart(
                  PieChartData(
                    sections: data.entries.map((entry) {
                      final percent =
                          (entry.value / total * 100).toStringAsFixed(1);
                      return PieChartSectionData(
                        value: entry.value,
                        title: "${entry.key} ($percent%)",
                        radius: 60,
                        titleStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      );
                    }).toList(),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: controller.isPro.value
                    ? () async {
                        final path = await CsvExporter.exportExpenses(
                            controller.expenses);
                        // await SharePlus.instance.shareFiles(
                        //   [path],
                        //   text: "Here is my exported expense data.",
                        // );
                      }
                    : () => Get.toNamed(AppRoutes.proUpgrade),
                child: const Text("Export to CSV (Pro)"),
              ),
            ],
          ),
        );
      }),
    );
  }
}
