import 'package:uuid/uuid.dart';

class ExpenseModel {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String note;

  ExpenseModel({
    String? id,
    required this.category,
    required this.amount,
    required this.date,
    this.note = '',
  }) : id = id ?? const Uuid().v4();

  // Create a copy with optional new values
  ExpenseModel copyWith({
    String? id,
    String? category,
    double? amount,
    DateTime? date,
    String? note,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  // Convert from JSON (GetStorage / persistence)
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String? ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }
}
