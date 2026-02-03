import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaywallController extends GetxController {
  var selectedPlan = "monthly".obs;

  void selectPlan(String plan) {
    selectedPlan.value = plan;
  }

  void startTrial() {
    // TODO: integrate in_app_purchase
    Get.snackbar("Success", "Trial started for ${selectedPlan.value} plan");
  }
}

class PaywallScreen extends StatelessWidget {
  final controller = Get.put(PaywallController());

  PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            /// Header Logo + Title
            Column(
              children: [
                Image.asset("assets/full-logo.png", height: 70),
                const SizedBox(height: 12),
                const Text(
                  "Spendric Premium",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Unlock Smart Insights • Export Reports • Go Ad-free",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// Features List
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  FeatureTile("Advanced Analytics & Trends"),
                  FeatureTile("Export PDF with Branding"),
                  FeatureTile("CSV Export with Charts"),
                  FeatureTile("Unlimited Reports"),
                  FeatureTile("Ad-free Experience"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// Plan Options
            Expanded(
              child: Obx(
                () => ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    PlanCard(
                      title: "Weekly",
                      subtitle: "₹49 / week",
                      value: "weekly",
                      controller: controller,
                    ),
                    PlanCard(
                      title: "Monthly",
                      subtitle: "₹99 / month",
                      value: "monthly",
                      controller: controller,
                    ),
                    PlanCard(
                      title: "Yearly",
                      subtitle: "₹999 / year (Save 15%)",
                      value: "yearly",
                      controller: controller,
                      isBestValue: true,
                    ),
                  ],
                ),
              ),
            ),

            /// CTA Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.startTrial,
                  child: const Text(
                    "Start 3-Day Free Trial",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            /// Trust Footer
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Text(
                    "Cancel anytime. Secure payments via Google Play",
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Trusted by 10,000+ users",
                    style: TextStyle(color: Colors.black45, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 Feature List Tile
class FeatureTile extends StatelessWidget {
  final String text;
  const FeatureTile(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.check_circle, color: Colors.green),
      title: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}

/// 🔹 Plan Card
class PlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final PaywallController controller;
  final bool isBestValue;

  const PlanCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.controller,
    this.isBestValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedPlan.value == value;
      return GestureDetector(
        onTap: () => controller.selectPlan(value),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? Colors.blue : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          elevation: isSelected ? 4 : 1,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.blue : Colors.black,
                            ),
                          ),
                          if (isBestValue)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "BEST VALUE",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: Colors.blue),
              ],
            ),
          ),
        ),
      );
    });
  }
}
