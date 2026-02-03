import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/expense_controller.dart';
import '../widgets/expense_pie_chart.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  final controller = Get.find<ExpenseController>();
  final GlobalKey<ScaffoldState> _sKey = GlobalKey();
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
      body: ListView(
        children: [
          SizedBox(
            height: 100,
            child: buildMonthDaySelector(controller),
          ),
          // Pie chart and empty state
          SizedBox(
            height: 550,
            child: Obx(() {
              if (controller.filteredExpenses.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon(Boxicons.bx_receipt, size: 120, color: Colors.grey),
                    SvgPicture.asset(
                      'assets/investing.svg',
                      height: 300.0,
                      width: 300.0,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No Expenses Added to view Analytics",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                );
              }
              return ExpensePieChart();
            }),
          ),
        ],
      ),
    );
  }
}

Widget buildMonthDaySelector(ExpenseController controller) {
  return Obx(() {
    final now = DateTime.now();
    final monthName = DateFormat('MMM yyyy').format(DateTime(
        controller.selectedYear.value, controller.selectedMonth.value));

    String dayLabel;
    bool isToday = false;

    if (controller.showAllDates.value ||
        controller.selectedDate.value == null) {
      dayLabel = "All";
    } else {
      final date = controller.selectedDate.value!;
      dayLabel = "${date.day} ${DateFormat('E').format(date)}";

      isToday = date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ---------- Month Selector ----------
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                if (controller.selectedMonth.value == 1) {
                  controller.selectedMonth.value = 12;
                  controller.selectedYear.value -= 1;
                } else {
                  controller.selectedMonth.value -= 1;
                }
                controller.showAllDates.value = true;
                controller.selectedDate.value = null;
              },
            ),

            /// 👇 Tappable Month-Year Label
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: Get.context!, // requires GetMaterialApp
                  initialDate: DateTime(controller.selectedYear.value,
                      controller.selectedMonth.value),
                  firstDate: DateTime(2000, 1),
                  lastDate: DateTime(2100, 12),
                  initialEntryMode:
                      DatePickerEntryMode.calendar, // calendar mode
                );

                if (picked != null) {
                  controller.selectedYear.value = picked.year;
                  controller.selectedMonth.value = picked.month;
                  controller.showAllDates.value = false; // single day view
                  controller.selectedDate.value = picked; // 👈 keep picked day
                }
              },
              child: Text(
                monthName,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                if (controller.selectedMonth.value == 12) {
                  controller.selectedMonth.value = 1;
                  controller.selectedYear.value += 1;
                } else {
                  controller.selectedMonth.value += 1;
                }
                controller.showAllDates.value = true;
                controller.selectedDate.value = null;
              },
            ),
          ],
        ),

        // ---------- Day Selector ----------
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                if (controller.showAllDates.value ||
                    controller.selectedDate.value == null) {
                  final lastDay = DateTime(controller.selectedYear.value,
                      controller.selectedMonth.value + 1, 0);
                  controller.selectDate(lastDay);
                } else {
                  final prevDate = controller.selectedDate.value!
                      .subtract(const Duration(days: 1));
                  if (prevDate.month == controller.selectedMonth.value) {
                    controller.selectDate(prevDate);
                  }
                }
              },
            ),
            GestureDetector(
              onTap: () {
                if (controller.showAllDates.value ||
                    controller.selectedDate.value == null) {
                  if (now.month == controller.selectedMonth.value &&
                      now.year == controller.selectedYear.value) {
                    controller.selectDate(now);
                  } else {
                    final firstDay = DateTime(controller.selectedYear.value,
                        controller.selectedMonth.value, 1);
                    controller.selectDate(firstDay);
                  }
                } else {
                  controller.showAllDates.value = true;
                  controller.selectedDate.value = null;
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dayLabel,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: controller.showAllDates.value
                          ? Colors.black
                          : isToday
                              ? Colors.blue
                              : Colors.black,
                    ),
                  ),
                  if (isToday && !controller.showAllDates.value)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                if (controller.showAllDates.value ||
                    controller.selectedDate.value == null) {
                  final firstDay = DateTime(controller.selectedYear.value,
                      controller.selectedMonth.value, 1);
                  controller.selectDate(firstDay);
                } else {
                  final nextDate = controller.selectedDate.value!
                      .add(const Duration(days: 1));
                  if (nextDate.month == controller.selectedMonth.value) {
                    controller.selectDate(nextDate);
                  }
                }
              },
            ),
          ],
        ),
      ],
    );
  });
}
