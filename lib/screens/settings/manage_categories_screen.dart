import 'package:expenses_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/widgets/category_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Lists every category and lets the user delete the ones they don't want
/// (e.g. one created by mistake). Its transactions are deleted with it.
class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  late final ExpenseRepository _repo = context.read<ExpenseRepository>();
  List<Category>? _categories;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final list = await _repo.getCategories();
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      if (mounted) setState(() => _categories = list);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _delete(Category c) async {
    // How many transactions use this category (they are deleted with it).
    final expensesState = context.read<GetExpensesBloc>().state;
    final count = expensesState is GetExpensesSuccess
        ? expensesState.expenses
            .where((e) => e.category.categoryId == c.categoryId)
            .length
        : 0;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${c.name}"?'),
        content: Text(
          count == 0
              ? 'No transactions use this category.'
              : 'This will also permanently delete $count '
                  '${count == 1 ? 'transaction' : 'transactions'} in this '
                  'category. This cannot be undone.',
        ),
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
    if (ok != true) return;
    try {
      // Transactions first, so a failure never leaves orphans on the home screen.
      await _repo.deleteExpensesByCategory(c.categoryId);
      await _repo.deleteCategory(c.categoryId);
      if (!mounted) return;
      setState(() => _categories!.remove(c));
      // Refresh the home screen: list, balance, income, expenses and chart.
      context.read<GetExpensesBloc>().add(GetExpenses());
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't delete. Try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget body;
    if (_failed) {
      body = Center(
        child: FilledButton(onPressed: _load, child: const Text('Retry')),
      );
    } else if (_categories == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_categories!.isEmpty) {
      body = Center(
        child: Text('No categories yet', style: TextStyle(color: scheme.outline)),
      );
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: _categories!.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final c = _categories![i];
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: CategoryAvatar(icon: c.icon, colorValue: c.color, radius: 20),
              title: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                tooltip: 'Delete',
                icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                onPressed: () => _delete(c),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        title: const Text('Categories'),
      ),
      body: body,
    );
  }
}
