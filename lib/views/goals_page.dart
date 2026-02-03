import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../controllers/goal_controller.dart';
import 'add_goals.dart';

class GoalsPage extends StatelessWidget {
  final GoalController controller = Get.put(GoalController());

  GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Goals")),
      body: Obx(() {
        if (controller.goals.isEmpty) {
          return const Center(child: Text("No goals yet. Add one!"));
        }
        return ListView.builder(
          itemCount: controller.goals.length,
          itemBuilder: (context, index) {
            final goal = controller.goals[index];
            final progress =
                (goal.saved / goal.target).clamp(0.0, 1.0); // % complete

            return Card(
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: goal.imageAsset != null
                          ? SvgPicture.asset(
                              goal.imageAsset!,
                              width: 40,
                              height: 40,
                            )
                          : const Icon(Icons.flag),
                      title: Text(goal.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text(
                        "Target: ₹${goal.target.toStringAsFixed(2)}\n"
                        "Saved: ₹${goal.saved.toStringAsFixed(2)}",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => controller.deleteGoal(index),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Progress bar
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade300,
                      color: progress >= 1.0 ? Colors.green : Colors.blue,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${(progress * 100).toStringAsFixed(1)}% completed",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newGoal = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddGoalPage()),
          );
          if (newGoal != null) {
            controller.addGoal(newGoal);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
