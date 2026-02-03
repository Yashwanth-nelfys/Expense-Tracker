import 'package:expense_tracker/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class FinanceToolsPage extends StatelessWidget {
  const FinanceToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finance Tools"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCalculatorCard(
              context,
              title: "EMI Calculator",
              description: "Plan your monthly loan repayments",
              icon: "assets/calculator.svg",
              color: Colors.blueAccent,
              onTap: () => Get.toNamed(AppRoutes.emi),
            ),
            const SizedBox(height: 16),
            _buildCalculatorCard(
              context,
              title: "Interest Calculator",
              description: "Calculate simple interest easily",
              icon: "assets/calculator.svg",
              color: Colors.redAccent,
              onTap: () => Get.toNamed(AppRoutes.interest),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorCard(
    BuildContext context, {
    required String title,
    required String description,
    required String icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 12,
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 200,
          child: Row(
            children: [
              // Left side: Title + Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      icon.toString(),
                      width: 100,
                      height: 100,
                    ),
                    Text(title,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        )),
                    Text(description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        )),
                  ],
                ),
              ),

              // Right side: Big Icon
            ],
          ),
        ),
      ),
    );
  }
}
