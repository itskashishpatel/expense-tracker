import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expenses_repository/expense_repository.dart';

part 'get_expenses_event.dart';
part 'get_expenses_state.dart';

class GetExpensesBloc extends Bloc<GetExpensesEvent, GetExpensesState> {
  final ExpenseRepository expenseRepository;

  GetExpensesBloc(this.expenseRepository) : super(GetExpensesInitial()) {
    on<GetExpenses>((event, emit) => _load(emit));

    on<DeleteExpense>((event, emit) async {
      try {
        await expenseRepository.deleteExpense(event.expenseId);
      } catch (_) {
        // fall through: reloading shows the real state of the database
      }
      await _load(emit);
    });

    on<DeleteAllExpenses>((event, emit) async {
      try {
        await expenseRepository.deleteAllExpenses();
      } catch (_) {}
      await _load(emit);
    });
  }

  Future<void> _load(Emitter<GetExpensesState> emit) async {
    // Only show the full-screen spinner on the very first load; later
    // refreshes update the numbers in place without flicker.
    if (state is! GetExpensesSuccess) emit(GetExpensesLoading());

    try {
      final expenses = await expenseRepository.getExpense();
      // Newest first, so the home screen always shows the latest transactions.
      expenses.sort((a, b) => b.date.compareTo(a.date));
      emit(GetExpensesSuccess(expenses));
    } catch (e) {
      emit(GetExpensesFailure());
    }
  }
}
