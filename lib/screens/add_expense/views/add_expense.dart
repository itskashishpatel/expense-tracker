import 'package:expenses_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:expenses_tracker/screens/settings/settings_cubit.dart';
import 'package:expenses_tracker/widgets/category_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'category_creation.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();

  late Expense expense;
  bool isLoading = false;
  bool _categoryMissing = false;

  @override
  void initState() {
    super.initState();
    // A brand-new object each time (Expense.empty used to be shared, so the
    // previous entry's category/amount leaked into this screen).
    expense = Expense.empty..expenseId = const Uuid().v1();
    _dateController.text = DateFormat('dd/MM/yyyy').format(expense.date);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _save() {
    final formOk = _formKey.currentState!.validate();
    final hasCategory = !expense.category.isEmpty;
    setState(() => _categoryMissing = !hasCategory);
    if (!formOk || !hasCategory) return;

    expense.amount =
        double.parse(_amountController.text.trim().replaceAll(',', ''));
    context.read<CreateExpenseBloc>().add(CreateExpense(expense));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final currency = context.watch<SettingsCubit>().state.currencySymbol;
    final cardColor = Theme.of(context).cardColor;

    return BlocListener<CreateExpenseBloc, CreateExpenseState>(
      listener: (context, state) {
        if (state is CreateExpenseSuccess) {
          Navigator.pop(context);
        } else if (state is CreateExpenseLoading) {
          setState(() => isLoading = true);
        } else if (state is CreateExpenseFailure) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Couldn't save. Check your connection and retry."),
            ),
          );
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: scheme.surface,
          appBar: AppBar(
            backgroundColor: scheme.surface,
            title: Text(expense.isIncome ? 'Add Income' : 'Add Expense'),
            centerTitle: true,
          ),
          body: BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
            builder: (context, state) {
              if (state is GetCategoriesFailure) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Couldn't load categories"),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context
                            .read<GetCategoriesBloc>()
                            .add(GetCategories()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              if (state is! GetCategoriesSuccess) {
                return const Center(child: CircularProgressIndicator());
              }

              // Scrolls when the keyboard is open, so nothing overflows.
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<bool>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(value: false, label: Text('Expense')),
                          ButtonSegment(value: true, label: Text('Income')),
                        ],
                        selected: {expense.isIncome},
                        onSelectionChanged: (s) =>
                            setState(() => expense.isIncome = s.first),
                      ),
                      const SizedBox(height: 24),

                      // Amount
                      TextFormField(
                        controller: _amountController,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w600),
                        validator: (v) {
                          final n = double.tryParse((v ?? '').trim());
                          if (n == null || n <= 0) return 'Enter an amount';
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: cardColor,
                          hintText: '0',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 16, right: 4),
                            child: Center(
                              widthFactor: 1,
                              child: Text(
                                currency,
                                style: TextStyle(
                                    fontSize: 22, color: scheme.outline),
                              ),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Category header (shows the current selection)
                      TextFormField(
                        key: ValueKey(expense.category.categoryId),
                        initialValue: expense.category.name,
                        readOnly: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: expense.category.isEmpty
                              ? cardColor
                              : Color(expense.category.color),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: expense.category.isEmpty
                                ? const Icon(Icons.list,
                                    size: 20, color: Colors.grey)
                                : CategoryIcon(
                                    icon: expense.category.icon,
                                    size: 20,
                                    color: onColor(Color(expense.category.color)),
                                  ),
                          ),
                          suffixIcon: IconButton(
                            tooltip: 'New category',
                            onPressed: () async {
                              final newCategory =
                                  await getCategoryCreation(context);
                              // null = dialog dismissed (this used to crash)
                              if (newCategory != null) {
                                setState(() {
                                  state.categories.insert(0, newCategory);
                                  expense.category = newCategory;
                                  _categoryMissing = false;
                                });
                              }
                            },
                            icon: const Icon(Icons.add, size: 20),
                          ),
                          hintText: 'Category',
                          errorText:
                              _categoryMissing ? 'Pick a category' : null,
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(12)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(12)),
                        ),
                        child: state.categories.isEmpty
                            ? Center(
                                child: Text(
                                  'No categories yet.\nTap + to create one.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: scheme.outline),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: state.categories.length,
                                itemBuilder: (context, i) {
                                  final c = state.categories[i];
                                  final bg = Color(c.color);
                                  final fg = onColor(bg);
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: ListTile(
                                      dense: true,
                                      onTap: () => setState(() {
                                        expense.category = c;
                                        _categoryMissing = false;
                                      }),
                                      leading: CategoryIcon(
                                          icon: c.icon, color: fg, size: 24),
                                      title: Text(
                                        c.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: fg,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      trailing:
                                          c.categoryId == expense.category.categoryId
                                              ? Icon(Icons.check_circle, color: fg)
                                              : null,
                                      tileColor: bg,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      const SizedBox(height: 16),

                      // Date
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: () async {
                          final today = DateTime.now();
                          final newDate = await showDatePicker(
                            context: context,
                            initialDate: expense.date,
                            // Past dates are allowed now (they weren't), so
                            // you can log yesterday's spending.
                            firstDate: DateTime(today.year - 5),
                            lastDate: today,
                          );
                          if (newDate != null) {
                            setState(() {
                              _dateController.text =
                                  DateFormat('dd/MM/yyyy').format(newDate);
                              expense.date = newDate;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: cardColor,
                          prefixIcon: const Icon(Icons.calendar_today,
                              size: 18, color: Colors.grey),
                          hintText: 'Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        height: kToolbarHeight,
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : TextButton(
                                onPressed: _save,
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Save',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 22),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
