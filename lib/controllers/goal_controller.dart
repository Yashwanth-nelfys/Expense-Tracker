import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/goal_model.dart';

class GoalController extends GetxController {
  var goals = <Goal>[].obs;
  final _storage = GetStorage();
  final _key = "goals";

  final Map<String, String> categoryIcons = {
    'House': 'assets/goals/savingforhouse.svg',
    'Travel': 'assets/goals/savingforcar.svg',
    'Education': 'assets/goals/savingforhouse.svg',
    'Gadgets': 'assets/goals/savingforhouse.svg',
    'Emergency': 'assets/goals/savingforhouse.svg',
  };

  @override
  void onInit() {
    super.onInit();
    List? storedGoals = _storage.read<List>(_key);
    if (storedGoals != null) {
      goals.value = storedGoals.map((e) => Goal.fromMap(e)).toList();
    }
  }

  void addGoal(Goal goal) {
    goals.add(goal);
    _saveToStorage();
  }

  void updateGoal(int index, Goal updated) {
    goals[index] = updated;
    _saveToStorage();
  }

  void deleteGoal(int index) {
    goals.removeAt(index);
    _saveToStorage();
  }

  void _saveToStorage() {
    _storage.write(_key, goals.map((g) => g.toMap()).toList());
  }
}
