class CategoryEntity {
  String categoryId;
  String name;
  int totalExpenses;
  String icon;
  int color;

  CategoryEntity({
    required this.categoryId,
    required this.name,
    required this.totalExpenses,
    required this.icon,
    required this.color,
  });

  Map<String, Object?> toDocument() {
    return {
      'categoryId': categoryId,
      'name': name,
      'totalExpenses': totalExpenses,
      'icon': icon,
      'color': color,
    };
  }

  static CategoryEntity fromDocument(Map<String, dynamic> doc) {
    return CategoryEntity(
      categoryId: doc['categoryId'] ?? '',
      name: doc['name'] ?? '',
      totalExpenses: (doc['totalExpenses'] as num?)?.toInt() ?? 0,
      icon: doc['icon'] ?? '',
      color: (doc['color'] as num?)?.toInt() ?? 0xFF9E9E9E,
    );
  }
}
