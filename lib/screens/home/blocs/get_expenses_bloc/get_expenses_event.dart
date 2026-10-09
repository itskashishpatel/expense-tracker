part of 'get_expenses_bloc.dart';

sealed class GetExpensesEvent extends Equatable {
  const GetExpensesEvent();

  @override
  List<Object> get props => [];
}

/// Load (or reload) all transactions.
final class GetExpenses extends GetExpensesEvent {}

/// Delete one transaction and refresh the list.
final class DeleteExpense extends GetExpensesEvent {
  final String expenseId;

  const DeleteExpense(this.expenseId);

  @override
  List<Object> get props => [expenseId];
}

/// Delete every transaction.
final class DeleteAllExpenses extends GetExpensesEvent {}
