import 'dart:math';

import 'package:get/get.dart';

class EmiController extends GetxController {
  var loanAmount = 100000.0.obs;
  var interestRate = 10.0.obs; // annual %
  var tenureMonths = 12.obs;

  var touchedIndex = (-1).obs;

  double get monthlyRate => interestRate.value / 12 / 100;

  double get emi {
    final p = loanAmount.value;
    final r = monthlyRate;
    final n = tenureMonths.value;
    return (p * r * (pow(1 + r, n))) / (pow(1 + r, n) - 1);
  }

  double get totalPayment => emi * tenureMonths.value;

  double get totalInterest => totalPayment - loanAmount.value;
}
