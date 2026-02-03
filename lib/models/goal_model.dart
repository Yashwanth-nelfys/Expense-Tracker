class Goal {
  String name;
  double target;
  double saved;
  DateTime? dueDate;
  String? category;
  String? imageAsset;

  Goal({
    required this.name,
    required this.target,
    this.saved = 0,
    this.dueDate,
    this.category,
    this.imageAsset,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'target': target,
        'saved': saved,
        'dueDate': dueDate?.toIso8601String(),
        'category': category,
        'imageAsset': imageAsset,
      };

  factory Goal.fromMap(Map<String, dynamic> map) => Goal(
        name: map['name'],
        target: map['target'],
        saved: map['saved'],
        dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
        category: map['category'],
        imageAsset: map['imageAsset'],
      );
}
