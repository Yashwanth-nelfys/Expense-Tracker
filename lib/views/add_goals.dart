import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/goal_controller.dart';
import '../models/goal_model.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedCategory;

  final GoalController controller = Get.find<GoalController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Goal")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Goal Name"),
                validator: (val) => val!.isEmpty ? "Enter name" : null,
              ),
              TextFormField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Target Amount"),
                validator: (val) => val!.isEmpty ? "Enter target" : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: "Category"),
                items: controller.categoryIcons.keys.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _selectedCategory != null) {
                    final newGoal = Goal(
                      name: _nameController.text,
                      target: double.parse(_targetController.text),
                      saved: 0,
                      dueDate: _selectedDate,
                      category: _selectedCategory,
                      imageAsset:
                          controller.categoryIcons[_selectedCategory], // auto
                    );
                    Navigator.pop(context, newGoal);
                  }
                },
                child: const Text("Save Goal"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
