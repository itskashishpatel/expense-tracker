import 'package:expenses_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/screens/settings/settings_cubit.dart';
import 'package:expenses_tracker/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/transaction_tile.dart';

enum _Filter { all, expenses, income }

/// Full history, grouped by day. Swipe a row left to delete it.
class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  _Filter _filter = _Filter.all;

  // Rows swiped away are hidden immediately; the bloc refresh arrives a moment
  // later (a Dismissible must leave the tree in the same frame).
  final Set<String> _hidden = {};

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsCubit>().state.currencySymbol;
    final state = context.watch<GetExpensesBloc>().state;
    final scheme = Theme.of(context).colorScheme;

    final all = state is GetExpensesSuccess
        ? state.expenses.where((e) => !_hidden.contains(e.expenseId)).toList()
        : <Expense>[];
    final shown = all.where((e) {
      switch (_filter) {
        case _Filter.all:
          return true;
        case _Filter.expenses:
          return !e.isIncome;
        case _Filter.income:
          return e.isIncome;
      }
    }).toList();

    // Flatten into [header, tile, tile, header, tile...]
    final rows = <Object>[];
    String? lastDay;
    for (final e in shown) {
      final day = friendlyDay(e.date);
      if (day != lastDay) {
        rows.add(day);
        lastDay = day;
      }
      rows.add(e);
    }

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        title: const Text('All Transactions'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<_Filter>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: _Filter.all, label: Text('All')),
                  ButtonSegment(value: _Filter.expenses, label: Text('Expenses')),
                  ButtonSegment(value: _Filter.income, label: Text('Income')),
                ],
                selected: {_filter},
                onSelectionChanged: (s) => setState(() => _filter = s.first),
              ),
            ),
          ),
          Expanded(
            child: rows.isEmpty
                ? Center(
                    child: Text(
                      'Nothing here yet',
                      style: TextStyle(color: scheme.outline),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    itemCount: rows.length,
                    itemBuilder: (context, i) {
                      final row = rows[i];
                      if (row is String) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          child: Text(
                            row,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: scheme.outline,
                            ),
                          ),
                        );
                      }
                      final e = row as Expense;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Dismissible(
                          key: ValueKey(e.expenseId),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) => _confirmDelete(context),
                          onDismissed: (_) {
                            setState(() => _hidden.add(e.expenseId));
                            context
                                .read<GetExpensesBloc>()
                                .add(DeleteExpense(e.expenseId));
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: TransactionTile(expense: e, currency: currency),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }
}
