import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/expense_controller.dart';
import '../models/expense_model.dart';

void showExpenseBottomSheet({ExpenseModel? expense}) {
  final controller = Get.find<ExpenseController>();
  final formKey = GlobalKey<FormState>();
  final amountController =
      TextEditingController(text: expense?.amount.toString() ?? '');
  final noteController = TextEditingController(text: expense?.note ?? '');
  DateTime selectedDate = expense?.date ?? DateTime.now();

  // Predefined categories
  final List<String> categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Others'
  ];
  String selectedCategory = expense?.category ?? categories[0];

  Get.bottomSheet(
    SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                expense == null ? "Add Expense" : "Edit Expense",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: "Category"),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) selectedCategory = val;
                },
              ),
              const SizedBox(height: 8),

              // Amount
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Enter amount" : null,
              ),
              const SizedBox(height: 8),

              // Note
              TextFormField(
                controller: noteController,
                decoration: const InputDecoration(labelText: "Note"),
              ),
              const SizedBox(height: 8),

              // Date picker
              Row(
                children: [
                  const Text("Date: ", style: TextStyle(fontSize: 16)),
                  Text("${selectedDate.toLocal()}".split(' ')[0],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: Get.context!,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) selectedDate = picked;
                    },
                    child: const Text("Change"),
                  )
                ],
              ),
              const SizedBox(height: 16),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    if (expense == null) {
                      controller.addExpense(
                        selectedCategory,
                        double.parse(amountController.text),
                        selectedDate,
                        noteController.text,
                      );
                    } else {
                      final updated = expense.copyWith(
                        category: selectedCategory,
                        amount: double.parse(amountController.text),
                        note: noteController.text,
                        date: selectedDate,
                      );
                      controller.updateExpense(updated);
                    }
                    Get.back();
                  }
                },
                child: Text(expense == null ? "Add" : "Save Changes"),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
    isScrollControlled: true,
  );
}
