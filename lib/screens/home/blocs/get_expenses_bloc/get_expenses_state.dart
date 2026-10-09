part of 'get_expenses_bloc.dart';

sealed class GetExpensesState extends Equatable {
  const GetExpensesState();

  @override
  List<Object> get props => [];
}

final class GetExpensesInitial extends GetExpensesState {}

final class GetExpensesLoading extends GetExpensesState {}

final class GetExpensesFailure extends GetExpensesState {}

final class GetExpensesSuccess extends GetExpensesState {
  final List<Expense> expenses;

  const GetExpensesSuccess(this.expenses);

  /// Money received.
  double get totalIncome =>
      expenses.where((e) => e.isIncome).fold(0.0, (s, e) => s + e.amount);

  /// Money spent.
  double get totalExpenses =>
      expenses.where((e) => !e.isIncome).fold(0.0, (s, e) => s + e.amount);

  double get balance => totalIncome - totalExpenses;

  @override
  List<Object> get props => [expenses];
}
