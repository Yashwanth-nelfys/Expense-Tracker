import 'package:expense_tracker/widgets/expense_pie_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/emi_controller.dart';

class EmiCalculatorPage extends StatelessWidget {
  final controller = Get.put(EmiController());

  EmiCalculatorPage({super.key});

  final currency = NumberFormat.currency(locale: 'en_IN', symbol: "₹");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EMI Calculator"),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ==== Pie Chart ====
              Obx(() {
                final principal = controller.loanAmount.value;
                final interest = controller.totalInterest;
                final total = principal + interest;
                final principalPercent =
                    (principal / total * 100).toStringAsFixed(1);
                final interestPercent =
                    (interest / total * 100).toStringAsFixed(1);
                final sections = [
                  PieChartSectionData(
                    color: Colors.indigo,
                    value: controller.loanAmount.value,
                    title: principalPercent,
                    radius: controller.touchedIndex.value == 0 ? 70 : 60,
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: controller.touchedIndex.value == 0 ? 16 : 14,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.deepOrangeAccent,
                    value: controller.totalInterest,
                    title: interestPercent,
                    radius: controller.touchedIndex.value == 1 ? 70 : 60,
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: controller.touchedIndex.value == 1 ? 16 : 14,
                    ),
                  ),
                ];

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          "EMI Breakdown",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
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
                        const Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              CategoryIndicator(
                                  color: Colors.indigo, text: "Principal"),
                              CategoryIndicator(
                                  color: Colors.deepOrangeAccent,
                                  text: "Interest"),
                            ]),
                      ],
                    ),
                  ),
                );
              }), // ==== Results ====

              const SizedBox(height: 10),
              Obx(() => SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              "Monthly EMI: ${currency.format(controller.emi)}",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Total Interest: ${currency.format(controller.totalInterest)}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              "Total Payment: ${currency.format(controller.totalPayment)}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 20),

              // ==== Loan Amount ====
              _buildInputCard(
                "Loan Amount",
                Obx(() => Text(
                      currency.format(controller.loanAmount.value),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    )),
                Obx(() => Slider(
                      value: controller.loanAmount.value,
                      min: 10000,
                      max: 2000000,
                      divisions: 200,
                      label: controller.loanAmount.value.round().toString(),
                      onChanged: (v) => controller.loanAmount.value = v,
                    )),
              ),

              // ==== Interest Rate ====
              _buildInputCard(
                "Interest Rate (p.a.)",
                Obx(() => Text(
                      "${controller.interestRate.value.toStringAsFixed(1)}%",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    )),
                Obx(() => Slider(
                      value: controller.interestRate.value,
                      min: 1,
                      max: 30,
                      divisions: 290,
                      label: controller.interestRate.value.toStringAsFixed(1),
                      onChanged: (v) => controller.interestRate.value = v,
                    )),
              ),

              // ==== Tenure (Months) ====
              _buildInputCard(
                "Tenure (Months)",
                Obx(() => Text(
                      "${controller.tenureMonths.value} months \n${((controller.tenureMonths.value) / 12).toStringAsFixed(1)} years",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    )),
                Obx(() => Slider(
                      value: controller.tenureMonths.value.toDouble(), // ✅ fix
                      min: 1,
                      max: 360,
                      divisions: 359,
                      label: controller.tenureMonths.value.toString(),
                      onChanged: (v) =>
                          controller.tenureMonths.value = v.round(), // ✅ fix
                    )),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(String title, Widget value, Widget slider) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            value,
            slider,
          ],
        ),
      ),
    );
  }
}
