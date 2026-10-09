import 'package:expenses_repository/expense_repository.dart';

abstract class ExpenseRepository {
  Future<void> createCategory(Category category);

  Future<List<Category>> getCategories();

  Future<void> deleteCategory(String categoryId);

  Future<void> createExpense(Expense expense);

  Future<List<Expense>> getExpense();

  Future<void> deleteExpense(String expenseId);

  /// Removes every transaction that belongs to the given category.
  Future<void> deleteExpensesByCategory(String categoryId);

  /// Removes every transaction (categories are kept).
  Future<void> deleteAllExpenses();
}
