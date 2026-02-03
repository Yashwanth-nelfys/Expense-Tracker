import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';

import '../models/expense_model.dart';

class ExpenseController extends GetxController {
  // UI state
  var touchedIndex = (-1).obs;

  // storage & data
  final storage = GetStorage();
  final expenses = <ExpenseModel>[].obs;
  final isPro = false.obs;

  // Filters: month/year + nullable selectedDate. If selectedDate == null OR showAllDates == true => show whole month
  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;
  final selectedDate =
      Rxn<DateTime>(); // null means "All" if showAllDates true as well
  final showAllDates = true.obs; // true => show entire month

  @override
  void onInit() {
    super.onInit();
    loadExpenses();
    loadProStatus();

    // default to today selected (single day view)
    final now = DateTime.now();
    selectedMonth.value = now.month;
    selectedYear.value = now.year;
    selectedDate.value = now;
    showAllDates.value = false;
  }

  void loadExpenses() {
    final data = storage.read<List>('expenses') ?? [];
    expenses.assignAll(
      data.map((e) => ExpenseModel.fromJson(Map<String, dynamic>.from(e))),
    );
  }

  void saveExpenses() {
    storage.write('expenses', expenses.map((e) => e.toJson()).toList());
  }

  void addExpense(String category, double amount, DateTime date, String note) {
    final newExpense = ExpenseModel(
      id: const Uuid().v4(),
      category: category,
      amount: amount,
      date: date,
      note: note,
    );
    expenses.add(newExpense);
    saveExpenses();
  }

  void updateExpense(ExpenseModel updated) {
    final index = expenses.indexWhere((e) => e.id == updated.id);
    if (index != -1) {
      expenses[index] = updated;
      expenses.refresh();
      saveExpenses();
    }
  }

  void deleteExpense(String id) {
    expenses.removeWhere((e) => e.id == id);
    expenses.refresh();
    saveExpenses();
  }

  // Filtered expenses (month + either whole-month or specific day)
  List<ExpenseModel> get filteredExpenses {
    return expenses.where((e) {
      final inSameMonth = e.date.year == selectedYear.value &&
          e.date.month == selectedMonth.value;

      if (!inSameMonth) return false;

      if (showAllDates.value || selectedDate.value == null) {
        return true; // whole month
      }

      final sel = selectedDate.value!;
      return e.date.year == sel.year &&
          e.date.month == sel.month &&
          e.date.day == sel.day;
    }).toList();
  }

// ------------------ Viewer (List Page) ------------------
  List<ExpenseModel> get viewerFilteredExpenses {
    return expenses.where((e) {
      // Example: Viewer always shows full month by default
      final inSameMonth = e.date.year == selectedYear.value &&
          e.date.month == selectedMonth.value;
      return inSameMonth;
    }).toList();
  }

// ------------------ Analysis (Pie Chart Page) ------------------
  List<ExpenseModel> get analysisFilteredExpenses {
    return expenses.where((e) {
      final inSameMonth = e.date.year == selectedYear.value &&
          e.date.month == selectedMonth.value;

      if (!inSameMonth) return false;

      if (showAllDates.value || selectedDate.value == null) {
        return true; // whole month
      }

      final sel = selectedDate.value!;
      return e.date.year == sel.year &&
          e.date.month == sel.month &&
          e.date.day == sel.day;
    }).toList();
  }

  void selectDate(DateTime date) {
    selectedDate.value = DateTime(date.year, date.month, date.day);
    showAllDates.value = false;
  }

  void selectAllDates() {
    showAllDates.value = true;
    selectedDate.value = null;
  }

  List<ExpenseModel> expensesForYear(int year) {
    return expenses.where((e) => e.date.year == year).toList();
  }

  double get totalSpent =>
      filteredExpenses.fold(0.0, (sum, e) => sum + e.amount);

  // Pro
  void loadProStatus() => isPro.value = storage.read('isPro') ?? false;
  void unlockPro() {
    storage.write('isPro', true);
    isPro.value = true;
  }
}
