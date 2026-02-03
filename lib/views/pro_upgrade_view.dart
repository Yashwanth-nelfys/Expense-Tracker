import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/expense_controller.dart';

class ProUpgradeView extends StatelessWidget {
  final controller = Get.find<ExpenseController>();

  ProUpgradeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upgrade to Pro")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Unlock Pro Features",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.download),
              title: Text("Export to CSV"),
            ),
            const ListTile(
              leading: Icon(Icons.category),
              title: Text("Custom Categories"),
            ),
            const ListTile(
              leading: Icon(Icons.notifications),
              title: Text("Budget Alerts"),
            ),
            const SizedBox(height: 30),
            Obx(() => controller.isPro.value
                ? const Text("You already have Pro access! ✅")
                : ElevatedButton(
                    onPressed: () {
                      // Simulate purchase
                      controller.unlockPro();
                      Get.snackbar("Success", "Pro features unlocked!");
                    },
                    child: const Text("Upgrade for ₹99"),
                  )),
          ],
        ),
      ),
    );
  }
}
