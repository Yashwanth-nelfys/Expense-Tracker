import 'package:expense_tracker/views/emi_calculator.dart';
import 'package:expense_tracker/views/expense_viewer.dart';
import 'package:expense_tracker/views/homepage.dart';
import 'package:expense_tracker/views/interest_calculator.dart';
import 'package:get/get.dart';

import '../views/pro_upgrade_view.dart';
import '../views/summary_view.dart';

class AppRoutes {
  static const home = '/';
  static const expense = '/expense';
  static const summary = '/summary';
  static const interest = '/interest';
  static const emi = '/emi';
  static const proUpgrade = '/pro-upgrade';

  static final routes = [
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: expense, page: () => const ExpenseViewer()),
    GetPage(name: summary, page: () => SummaryView()),
    GetPage(name: emi, page: () => EmiCalculatorPage()),
    GetPage(name: interest, page: () => SimpleInterestCalculatorPage()),
    GetPage(name: proUpgrade, page: () => ProUpgradeView()), // 👈 Add this
  ];
}
