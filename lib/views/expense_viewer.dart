import 'package:boxicons/boxicons.dart';
import 'package:expense_tracker/widgets/show_expense_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/expense_controller.dart';
import '../models/expense_model.dart';
import '../widgets/drawer.dart';

class ExpenseViewer extends StatefulWidget {
  const ExpenseViewer({super.key});

  @override
  State<ExpenseViewer> createState() => _ExpenseViewerState();
}

class _ExpenseViewerState extends State<ExpenseViewer> {
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
      key: _sKey,
      extendBodyBehindAppBar: true,
      drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton(
        // onPressed: () => Get.toNamed(AppRoutes.interest),
        onPressed: () => showExpenseBottomSheet(),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Sticky Header (Card with date)
            SliverAppBar(
              pinned: true,
              // forceElevated: true,
              // backgroundColor: Colors.white,
              // shadowColor: Colors.blue,
              // elevation: 10,
              automaticallyImplyLeading: false,
              toolbarHeight: 70,
              flexibleSpace: Card(
                elevation: 10,
                shadowColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue
                    : null,
                margin: EdgeInsets.zero,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => _sKey.currentState?.openDrawer(),
                        icon: const Icon(Boxicons.bx_menu, size: 30),
                      ),
                      Obx(() {
                        final monthNames = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec'
                        ];
                        final month = controller.selectedMonth.value;
                        final year = controller.selectedYear.value;
                        return Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: () {
                                if (month == 1) {
                                  controller.selectedMonth.value = 12;
                                  controller.selectedYear.value = year - 1;
                                } else {
                                  controller.selectedMonth.value = month - 1;
                                }
                                controller.selectedDate.value = null;
                              },
                            ),
                            Text(
                              "${monthNames[month - 1]} $year",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () {
                                if (month == 12) {
                                  controller.selectedMonth.value = 1;
                                  controller.selectedYear.value = year + 1;
                                } else {
                                  controller.selectedMonth.value = month + 1;
                                }
                                controller.selectedDate.value = null;
                              },
                            ),
                          ],
                        );
                      }),

                      // const Text(
                      //   "September 2025",
                      // ),

                      IconButton(
                        // onPressed: () => Get.toNamed(AppRoutes.emi),
                        onPressed: () {},
                        icon: const Icon(Boxicons.bx_slider),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Horizontal date selector
            // SliverToBoxAdapter(
            //   child: buildDateSelector(controller),
            // ),
            // // Pie chart and empty state
            // SliverToBoxAdapter(
            //   child: SizedBox(
            //     height: 500,
            //     child: Obx(() {
            //       if (controller.filteredExpenses.isEmpty) {
            //         return const Column(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [
            //             Icon(Boxicons.bx_receipt,
            //                 size: 120, color: Colors.grey),
            //             SizedBox(height: 16),
            //             Text(
            //               "ADD Expenses by clicking On Add button",
            //               textAlign: TextAlign.center,
            //               style: TextStyle(fontSize: 18, color: Colors.grey),
            //             ),
            //           ],
            //         );
            //       }
            //       return ExpensePieChart();
            //     }),
            //   ),
            // ),

            // Expense list
            // SliverPadding(
            //   padding: const EdgeInsets.only(bottom: 80),
            //   sliver: Obx(() {
            //     final list = controller.filteredExpenses;
            //     return SliverList(
            //       delegate: SliverChildBuilderDelegate(
            //         (context, index) {
            //           final e = list[index];
            //           return Slidable(
            //             key: ValueKey(e.id),
            //             endActionPane: ActionPane(
            //               motion: const ScrollMotion(),
            //               children: [
            //                 SlidableAction(
            //                   onPressed: (_) {
            //                     showExpenseBottomSheet(expense: e);
            //                   },
            //                   icon: Icons.edit,
            //                   backgroundColor: Colors.blue,
            //                 ),
            //                 SlidableAction(
            //                   onPressed: (_) {
            //                     controller.deleteExpense(e.id);
            //                   },
            //                   icon: Icons.delete,
            //                   backgroundColor: Colors.red,
            //                 ),
            //               ],
            //             ),
            //             child: ListTile(
            //               title: Text(e.category),
            //               subtitle: Text(
            //                 DateFormat('dd MMM yyyy, hh:mm a').format(e.date),
            //               ),
            //               trailing: Text(
            //                 '₹${e.amount.toStringAsFixed(2)}',
            //                 style: const TextStyle(
            //                   fontSize: 18,
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //               ),
            //               onTap: () => showExpenseBottomSheet(expense: e),
            //             ),
            //           );
            //         },
            //         childCount: list.length,
            //       ),
            //     );
            //   }),
            // ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 80),
              sliver: Obx(() {
                final list = controller.viewerFilteredExpenses;
                if (list.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 100,
                        ),
                        Image.asset(
                          'assets/expense-alt.png',
                          height: 300.0,
                          width: 300.0,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "ADD Expenses by clicking On Add button",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // ---- Group expenses by day ----
                final grouped = <String, List<ExpenseModel>>{};
                for (var e in list) {
                  final key =
                      DateFormat('yyyy-MM-dd').format(e.date); // grouping key
                  grouped.putIfAbsent(key, () => []).add(e);
                }

                // Sort days descending (latest first)
                final sortedKeys = grouped.keys.toList()
                  ..sort((a, b) => b.compareTo(a));

                // ---- Monthly total ----
                final monthlyTotal =
                    list.fold<double>(0.0, (sum, e) => sum + e.amount);

                // Build items list with monthly summary + headers
                final items = <Widget>[];

                // ✅ Monthly summary card
                items.add(
                  Card(
                    margin: const EdgeInsets.all(12),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMMM yyyy').format(
                              DateTime(controller.selectedYear.value,
                                  controller.selectedMonth.value),
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "₹${monthlyTotal.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );

                // ✅ Daily sections
                for (final key in sortedKeys) {
                  final date = DateTime.parse(key);
                  final expensesForDay = grouped[key]!;

                  // ---- Daily total ----
                  final dailyTotal = expensesForDay.fold<double>(
                    0.0,
                    (sum, e) => sum + e.amount,
                  );

                  // Day header
                  items.add(
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      color: Colors.grey[200],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${DateFormat('E').format(date)} ${DateFormat('d - MMM').format(date)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "₹${dailyTotal.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  // Day's expenses
                  for (final e in expensesForDay) {
                    items.add(
                      Slidable(
                        key: ValueKey(e.id),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            // SlidableAction(
                            //   onPressed: (_) =>
                            //       showExpenseBottomSheet(expense: e),
                            //   icon: Icons.edit,
                            //   backgroundColor: Colors.blue,
                            // ),
                            SlidableAction(
                              onPressed: (_) => controller.deleteExpense(e.id),
                              icon: Icons.delete,
                              // backgroundColor: Colors.red,
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(e.category),
                          subtitle: Text(DateFormat('hh:mm a').format(e.date)),
                          trailing: Text(
                            '₹${e.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () => showExpenseBottomSheet(expense: e),
                        ),
                      ),
                    );
                  }
                }

                return SliverList(
                  delegate: SliverChildListDelegate(items),
                );
              }),
            )
          ],
        ),
      ),
    );
  }
}

extension DateTimeHelpers on DateTime {
  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
}

Widget buildDateSelector(ExpenseController controller) {
  return Obx(() {
    final days = DateTimeHelpers.daysInMonth(
      controller.selectedYear.value,
      controller.selectedMonth.value,
    );

    return SizedBox(
      height: 64,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: days + 1, // +1 for "All"
        itemBuilder: (context, index) {
          // ---------- "All" tile ----------
          if (index == 0) {
            final isSelected = controller.showAllDates.value ||
                controller.selectedDate.value == null;

            return GestureDetector(
              onTap: () {
                controller.showAllDates.value = true;
                controller.selectedDate.value = null;
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: CircleAvatar(
                  backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
                  radius: 24,
                  child: Text(
                    'All',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }

          // ---------- Day tiles (1..days) ----------
          final day = index; // since 0 is All
          final date = DateTime(
            controller.selectedYear.value,
            controller.selectedMonth.value,
            day,
          );

          final isSelected = !controller.showAllDates.value &&
              controller.selectedDate.value != null &&
              controller.selectedDate.value!.year == date.year &&
              controller.selectedDate.value!.month == date.month &&
              controller.selectedDate.value!.day == date.day;

          return GestureDetector(
            onTap: () {
              controller.showAllDates.value = false;
              controller.selectedDate.value = date;
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: CircleAvatar(
                backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
                radius: 24,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('E').format(date),
                      style: TextStyle(
                        color: isSelected ? Colors.white70 : Colors.black54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  });
}
