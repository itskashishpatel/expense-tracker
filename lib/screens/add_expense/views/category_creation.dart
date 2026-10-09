import 'package:expenses_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/create_category_bloc/create_category_bloc.dart';
import 'package:expenses_tracker/widgets/category_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:uuid/uuid.dart';

/// Opens the "Create a Category" dialog. Resolves to the new [Category], or
/// null if the user cancelled.
Future<Category?> getCategoryCreation(BuildContext context) {
  return showDialog<Category>(
    context: context,
    builder: (ctx) => BlocProvider.value(
      value: context.read<CreateCategoryBloc>(),
      child: const _CategoryCreationDialog(),
    ),
  );
}

const _swatches = <Color>[
  Color(0xFFE53935),
  Color(0xFFFB8C00),
  Color(0xFFFDD835),
  Color(0xFF43A047),
  Color(0xFF00ACC1),
  Color(0xFF1E88E5),
  Color(0xFF3949AB),
  Color(0xFF8E24AA),
  Color(0xFFD81B60),
  Color(0xFF6D4C41),
  Color(0xFF546E7A),
  Color(0xFF212121),
];

class _CategoryCreationDialog extends StatefulWidget {
  const _CategoryCreationDialog();

  @override
  State<_CategoryCreationDialog> createState() =>
      _CategoryCreationDialogState();
}

// All the dialog's state lives here (not inside the builder closure) so it
// survives rebuilds such as the keyboard opening and closing.
class _CategoryCreationDialogState extends State<_CategoryCreationDialog> {
  final _nameController = TextEditingController();
  final _scrollController = ScrollController();

  String _selectedIcon = 'other';
  Color _color = _swatches[5];
  String? _error;
  bool _isLoading = false;
  Category? _created;

  late final List<String> _icons = [
    ...kBuiltInCategoryIcons.keys,
    ...kLegacyAssetIcons,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter a name');
      return;
    }
    setState(() => _error = null);

    _created = Category(
      categoryId: const Uuid().v1(),
      name: name,
      totalExpenses: 0,
      icon: _selectedIcon,
      color: _color.toARGB32(),
    );
    context.read<CreateCategoryBloc>().add(CreateCategory(_created!));
  }

  Future<void> _pickCustomColor() async {
    Color temp = _color;
    final picked = await showDialog<Color>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        content: ColorPicker(
          pickerColor: _color,
          onColorChanged: (c) => temp = c,
          enableAlpha: false,
          labelTypes: const [],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, temp),
            child: const Text('Use color'),
          ),
        ],
      ),
    );
    if (picked != null) setState(() => _color = picked);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocListener<CreateCategoryBloc, CreateCategoryState>(
      listener: (context, state) {
        if (state is CreateCategorySuccess) {
          Navigator.pop(context, _created);
        } else if (state is CreateCategoryLoading) {
          setState(() => _isLoading = true);
        } else if (state is CreateCategoryFailure) {
          setState(() {
            _isLoading = false;
            _error = "Couldn't save the category. Check your connection.";
          });
        }
      },
      child: AlertDialog(
        title: const Text('Create a Category'),
        // `scrollable` makes the whole dialog scroll when the keyboard is up
        // or the screen is short.
        scrollable: true,
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live preview
              Center(
                child: CategoryAvatar(
                  icon: _selectedIcon,
                  colorValue: _color.toARGB32(),
                  radius: 30,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                maxLength: 24,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  hintText: 'Name',
                  counterText: '',
                  errorText: _error,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Icon', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              // The picker has its own scrolling and a visible scrollbar, so
              // every icon is reachable (before, only ~6 could be seen).
              Container(
                height: 210,
                decoration: BoxDecoration(
                  color: scheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 56,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _icons.length,
                    itemBuilder: (context, i) {
                      final key = _icons[i];
                      final selected = key == _selectedIcon;
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => _selectedIcon = key),
                        child: Container(
                          decoration: BoxDecoration(
                            color: selected ? _color : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? scheme.onSurface
                                  : scheme.outline.withValues(alpha: 0.4),
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: CategoryIcon(
                              icon: key,
                              size: 26,
                              color: selected ? onColor(_color) : scheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Color', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final c in _swatches)
                    GestureDetector(
                      onTap: () => setState(() => _color = c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _color.toARGB32() == c.toARGB32()
                                ? scheme.onSurface
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: _pickCustomColor,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: scheme.outline),
                      ),
                      child: const Icon(Icons.colorize, size: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    );
  }
}
