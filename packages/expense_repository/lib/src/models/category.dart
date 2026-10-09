import 'package:expenses_repository/src/entities/entities.dart';

class Category {
  String categoryId;
  String name;
  int totalExpenses;
  String icon;
  int color;

  Category({
    required this.categoryId,
    required this.name,
    required this.totalExpenses,
    required this.icon,
    required this.color,
  });

  /// A brand-new, empty category.
  ///
  /// This is a getter (not a shared `static final`) on purpose: the old shared
  /// instance was mutated by the UI, which silently corrupted every later use
  /// of `Category.empty`.
  static Category get empty => Category(
        categoryId: '',
        name: '',
        totalExpenses: 0,
        icon: '',
        color: 0,
      );

  bool get isEmpty => categoryId.isEmpty;

  CategoryEntity toEntity() {
    return CategoryEntity(
      categoryId: categoryId,
      name: name,
      totalExpenses: totalExpenses,
      icon: icon,
      color: color,
    );
  }

  static Category fromEntity(CategoryEntity entity) {
    return Category(
      categoryId: entity.categoryId,
      name: entity.name,
      totalExpenses: entity.totalExpenses,
      icon: entity.icon,
      color: entity.color,
    );
  }
}
