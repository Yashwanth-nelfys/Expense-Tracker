import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/interest_controller.dart';

var formatter = NumberFormat('#,##,000');

class SimpleInterestCalculatorPage extends StatelessWidget {
  final controller = Get.put(SimpleInterestController());

  SimpleInterestCalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Interest Calculator"),
        // backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input sliders
            _buildSlider(
                "Principal", controller.principal, 1000, 1000000, 5000),
            _buildSlider("Rate %", controller.rate, 1, 30, 1),
            _buildSlider("Time (Years)", controller.time, 1, 30, 1),

            const SizedBox(height: 20),

            // Results
            Obx(() => Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildResultRow(
                            "Principal", controller.principal.value),
                        _buildResultRow("Interest", controller.simpleInterest),
                        _buildResultRow("Total Payment", controller.total),
                      ],
                    ),
                  ),
                )),

            const SizedBox(height: 20),

            // Pie Chart
            Obx(() {
              final principal = controller.principal.value;
              final interest = controller.simpleInterest;
              final total = controller.total;

              final principalPercent =
                  (principal / total * 100).toStringAsFixed(1);
              final interestPercent =
                  (interest / total * 100).toStringAsFixed(1);

              final sections = [
                PieChartSectionData(
                  color: Colors.blue,
                  value: principal,
                  title: "$principalPercent%",
                  radius: controller.touchedIndex.value == 0 ? 70 : 60,
                  titleStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: controller.touchedIndex.value == 0 ? 18 : 14,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.redAccent,
                  value: interest,
                  title: "$interestPercent%",
                  radius: controller.touchedIndex.value == 1 ? 70 : 60,
                  titleStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: controller.touchedIndex.value == 1 ? 18 : 14,
                  ),
                ),
              ];

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        "Breakdown",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      AspectRatio(
                        aspectRatio: 1.3,
                        child: PieChart(
                          PieChartData(
                            sections: sections,
                            borderData: FlBorderData(show: false),
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                            pieTouchData: PieTouchData(
                              touchCallback: (event, response) {
                                if (!event.isInterestedForInteractions ||
                                    response == null ||
                                    response.touchedSection == null) {
                                  controller.touchedIndex.value = -1;
                                  return;
                                }
                                controller.touchedIndex.value = response
                                    .touchedSection!.touchedSectionIndex;
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegend(Colors.blue, "Principal"),
                          const SizedBox(width: 20),
                          _buildLegend(Colors.redAccent, "Interest"),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ===== Slider Builder =====
  Widget _buildSlider(
      String label, RxDouble value, double min, double max, double step) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$label: ${value.value.toStringAsFixed(0)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: value.value,
              min: min,
              max: max,
              divisions: ((max - min) / step).round(),
              label: value.value.toStringAsFixed(0),
              onChanged: (v) => value.value = v,
              activeColor: Colors.blueGrey,
            ),
          ],
        ));
  }

  // ===== Result Row =====
  Widget _buildResultRow(String title, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Text(formatter.format(value),
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ===== Legend Builder =====
  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
