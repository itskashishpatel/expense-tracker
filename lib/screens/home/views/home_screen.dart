import 'dart:math';

import 'package:expenses_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/create_category_bloc/create_category_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../add_expense/blocs/create_expense_bloc/create_expense_bloc.dart';
import '../../add_expense/blocs/get_categories_bloc/get_categories_bloc.dart';
import '../../add_expense/views/add_expense.dart';
import '../../stats/stats.dart';
import '../blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  Future<void> _openAddExpense(BuildContext context) async {
    final repo = context.read<ExpenseRepository>();
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => CreateCategoryBloc(repo)),
            BlocProvider(
              create: (_) => GetCategoriesBloc(repo)..add(GetCategories()),
            ),
            BlocProvider(create: (_) => CreateExpenseBloc(repo)),
          ],
          child: const AddExpense(),
        ),
      ),
    );
    // Reload so the balance, income, expenses, list and chart all reflect the
    // transaction that was just saved. (Previously nothing was reloaded, so the
    // numbers only updated after restarting the app.)
    if (context.mounted) {
      context.read<GetExpensesBloc>().add(GetExpenses());
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<GetExpensesBloc, GetExpensesState>(
      builder: (context, state) {
        if (state is GetExpensesFailure) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.wifi_slash, size: 48, color: scheme.outline),
                    const SizedBox(height: 12),
                    const Text(
                      "Couldn't load your transactions",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Check your internet connection and try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.outline),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () =>
                          context.read<GetExpensesBloc>().add(GetExpenses()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is! GetExpensesSuccess) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          bottomNavigationBar: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: BottomNavigationBar(
              currentIndex: index,
              backgroundColor: Theme.of(context).cardColor,
              selectedItemColor: scheme.primary,
              unselectedItemColor: Colors.grey,
              onTap: (value) => setState(() => index = value),
              showSelectedLabels: false,
              showUnselectedLabels: false,
              elevation: 3,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.graph_square_fill),
                  label: 'Stats',
                ),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openAddExpense(context),
            shape: const CircleBorder(),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [scheme.tertiary, scheme.secondary, scheme.primary],
                  transform: const GradientRotation(pi / 4),
                ),
              ),
              child: const Icon(CupertinoIcons.add, color: Colors.white),
            ),
          ),
          body: index == 0 ? MainScreen(state) : StatsScreen(state.expenses),
        );
      },
    );
  }
}
