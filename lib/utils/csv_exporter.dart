import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

import '../models/expense_model.dart';

class CsvExporter {
  static Future<String> exportExpenses(List<ExpenseModel> expenses) async {
    final rows = <List<String>>[];

    // Header
    rows.add(['Date', 'Category', 'Amount', 'Note']);

    // Data
    for (var e in expenses) {
      rows.add([
        e.date.toIso8601String(),
        e.category,
        e.amount.toStringAsFixed(2),
        e.note,
      ]);
    }

    // Convert to CSV string
    String csvData = const ListToCsvConverter().convert(rows);

    // Get storage directory
    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/expenses_${DateTime.now().millisecondsSinceEpoch}.csv';

    // Save to file
    final file = File(path);
    await file.writeAsString(csvData);

    return path;
  }
}
