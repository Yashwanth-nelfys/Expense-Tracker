import 'package:get/get.dart';

// ===== Controller =====
class SimpleInterestController extends GetxController {
  var principal = 50000.0.obs;
  var rate = 10.0.obs;
  var time = 2.0.obs;
  var touchedIndex = (-1).obs;

  double get simpleInterest =>
      (principal.value * rate.value * time.value) / 100;
  double get total => principal.value + simpleInterest;
}
