import 'package:expenses_tracker/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/screens/settings/manage_categories_screen.dart';
import 'package:expenses_tracker/screens/settings/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final cubit = context.read<SettingsCubit>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const _SectionTitle('Profile'),
          _Card(children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Name'),
              subtitle: Text(settings.userName),
              trailing: const Icon(Icons.edit_outlined, size: 18),
              onTap: () => _editName(context, settings.userName),
            ),
          ]),
          const _SectionTitle('Preferences'),
          _Card(children: [
            ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: const Text('Currency'),
              subtitle: Text(
                SettingsCubit.currencies[settings.currencySymbol] ??
                    settings.currencySymbol,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickCurrency(context, settings.currencySymbol),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.brightness_6_outlined),
              title: const Text('Theme'),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                    ButtonSegment(value: ThemeMode.system, label: Text('System')),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (s) => cubit.setThemeMode(s.first),
                ),
              ),
            ),
          ]),
          const _SectionTitle('Data'),
          _Card(children: [
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('Manage categories'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageCategoriesScreen()),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.copy_all_outlined),
              title: const Text('Export transactions (CSV)'),
              subtitle: const Text('Copies a CSV to the clipboard'),
              onTap: () => _exportCsv(context),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red.shade400),
              title: Text(
                'Delete all transactions',
                style: TextStyle(color: Colors.red.shade400),
              ),
              onTap: () => _deleteAll(context),
            ),
          ]),
          const _SectionTitle('About'),
          const _Card(children: [
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Expense Tracker'),
              subtitle: Text('Version 1.0.0'),
            ),
          ]),
        ],
      ),
    );
  }

  Future<void> _editName(BuildContext context, String current) async {
    final controller = TextEditingController(text: current);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          maxLength: 30,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name != null && context.mounted) {
      context.read<SettingsCubit>().setUserName(name);
    }
  }

  Future<void> _pickCurrency(BuildContext context, String current) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final entry in SettingsCubit.currencies.entries)
              ListTile(
                title: Text(entry.value),
                trailing: entry.key == current
                    ? const Icon(Icons.check_circle)
                    : null,
                onTap: () => Navigator.pop(ctx, entry.key),
              ),
          ],
        ),
      ),
    );
    if (picked != null && context.mounted) {
      context.read<SettingsCubit>().setCurrency(picked);
    }
  }

  void _exportCsv(BuildContext context) {
    final state = context.read<GetExpensesBloc>().state;
    final messenger = ScaffoldMessenger.of(context);
    if (state is! GetExpensesSuccess || state.expenses.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('There are no transactions to export.')),
      );
      return;
    }

    String esc(String s) => '"${s.replaceAll('"', '""')}"';
    final df = DateFormat('yyyy-MM-dd');
    final rows = <String>['Date,Type,Category,Amount'];
    for (final e in state.expenses) {
      rows.add([
        df.format(e.date),
        e.isIncome ? 'Income' : 'Expense',
        esc(e.category.name),
        e.amount.toString(),
      ].join(','));
    }
    Clipboard.setData(ClipboardData(text: rows.join('\n')));
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Copied ${state.expenses.length} transactions. Paste them into a spreadsheet or note.',
        ),
      ),
    );
  }

  Future<void> _deleteAll(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete all transactions?'),
        content: const Text(
          'Every expense and income entry will be permanently removed. '
          'Your categories are kept. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<GetExpensesBloc>().add(DeleteAllExpenses());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All transactions deleted.')),
      );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
