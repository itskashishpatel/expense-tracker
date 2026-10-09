import 'package:expenses_repository/expense_repository.dart';

/// A single transaction. When [isIncome] is true the amount is money coming
/// in (salary, refund...), otherwise it is money going out.
class Expense {
  String expenseId;
  Category category;
  DateTime date;
  double amount;
  bool isIncome;

  Expense({
    required this.expenseId,
    required this.category,
    required this.date,
    required this.amount,
    this.isIncome = false,
  });

  /// A fresh, independent empty transaction every time it is read.
  /// (It used to be one shared object, so the previous expense's category and
  /// amount leaked into the next "Add Expense" screen.)
  static Expense get empty => Expense(
        expenseId: '',
        category: Category.empty,
        date: DateTime.now(),
        amount: 0,
      );

  ExpenseEntity toEntity() {
    return ExpenseEntity(
      expenseId: expenseId,
      category: category,
      date: date,
      amount: amount,
      isIncome: isIncome,
    );
  }

  static Expense fromEntity(ExpenseEntity entity) {
    return Expense(
      expenseId: entity.expenseId,
      category: entity.category,
      date: entity.date,
      amount: entity.amount,
      isIncome: entity.isIncome,
    );
  }
}
