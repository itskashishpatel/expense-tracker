import 'package:expenses_repository/expense_repository.dart';
import 'package:expenses_tracker/utils/formatters.dart';
import 'package:expenses_tracker/widgets/category_icon.dart';
import 'package:flutter/material.dart';

/// One row in a transaction list. Adapts to any screen width: the category
/// name shrinks with an ellipsis instead of overflowing, and the icon is a
/// fixed-size avatar no matter what image the category uses.
class TransactionTile extends StatelessWidget {
  final Expense expense;
  final String currency;

  const TransactionTile({
    super.key,
    required this.expense,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final amountText = formatMoney(expense.amount, currency);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CategoryAvatar(
            icon: expense.category.icon,
            colorValue: expense.category.color,
            radius: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              expense.category.name.isEmpty
                  ? 'Uncategorised'
                  : expense.category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${expense.isIncome ? '+' : '-'} $amountText',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: expense.isIncome
                      ? Colors.green.shade600
                      : scheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatDate(expense.date),
                style: TextStyle(fontSize: 12, color: scheme.outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
