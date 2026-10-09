import 'package:expenses_repository/expense_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_view.dart';
import 'screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'screens/settings/settings_cubit.dart';

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    // Everything that must be reachable from *every* screen (including pushed
    // routes) lives above MaterialApp.
    return RepositoryProvider<ExpenseRepository>(
      create: (_) => FirebaseExpenseRepo(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SettingsCubit(prefs)),
          BlocProvider(
            create: (context) =>
                GetExpensesBloc(context.read<ExpenseRepository>())
                  ..add(GetExpenses()),
          ),
        ],
        child: const MyAppView(),
      ),
    );
  }
}
