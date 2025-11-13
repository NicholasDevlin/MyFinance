enum CategoryType {
  income('income', 'Income'),
  expense('expense', 'Expense');

  const CategoryType(this.value, this.displayName);
  
  final String value;
  final String displayName;
  
  static CategoryType fromValue(String value) {
    return CategoryType.values.firstWhere((type) => type.value == value);
  }
}

class Category {
  final int id;
  final String name;
  final CategoryType type;
  final String? description;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      type: CategoryType.fromValue(json['type']),
      description: json['description'],
      color: json['color'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.value,
      'description': description,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}