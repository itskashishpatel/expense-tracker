import 'package:expenses_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/settings/settings_cubit.dart';
import 'package:expenses_tracker/screens/stats/chart.dart';
import 'package:expenses_tracker/utils/formatters.dart';
import 'package:expenses_tracker/widgets/category_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

enum _Period { week, month, year }

/// Statistics page. Everything on it is computed from the real transactions:
/// pick Expenses/Income, Week/Month/Year, and step back through time.
class StatsScreen extends StatefulWidget {
  final List<Expense> expenses;
  const StatsScreen(this.expenses, {super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  _Period _period = _Period.week;
  bool _showIncome = false;
  int _offset = 0; // 0 = current period, -1 = previous, ...

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  /// Builds the buckets (bars) and the label for the selected period.
  ({List<ChartBucket> buckets, String title, DateTime start, DateTime end})
      _window() {
    final today = _today;

    switch (_period) {
      case _Period.week:
        final end = today.add(Duration(days: 7 * _offset));
        final start = end.subtract(const Duration(days: 6));
        final buckets = List.generate(7, (i) {
          final d = start.add(Duration(days: i));
          return ChartBucket(
            label: DateFormat('E').format(d),
            tooltipLabel: DateFormat('EEE, dd MMM').format(d),
          );
        });
        return (
          buckets: buckets,
          title:
              '${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM').format(end)}',
          start: start,
          end: end,
        );

      case _Period.month:
        final first = DateTime(today.year, today.month + _offset, 1);
        final days = DateTime(first.year, first.month + 1, 0).day;
        final buckets = List.generate(days, (i) {
          final day = i + 1;
          return ChartBucket(
            label: (day == 1 || day % 5 == 0) ? '$day' : '',
            tooltipLabel: DateFormat('dd MMM')
                .format(DateTime(first.year, first.month, day)),
          );
        });
        return (
          buckets: buckets,
          title: DateFormat('MMMM yyyy').format(first),
          start: first,
          end: DateTime(first.year, first.month, days),
        );

      case _Period.year:
        final year = today.year + _offset;
        final buckets = List.generate(12, (i) {
          final m = DateTime(year, i + 1, 1);
          return ChartBucket(
            label: DateFormat('MMM').format(m).substring(0, 1),
            tooltipLabel: DateFormat('MMMM yyyy').format(m),
          );
        });
        return (
          buckets: buckets,
          title: '$year',
          start: DateTime(year, 1, 1),
          end: DateTime(year, 12, 31),
        );
    }
  }

  int _bucketIndex(DateTime d, DateTime start) {
    switch (_period) {
      case _Period.week:
        // UTC avoids a 23h/25h day (daylight-saving) shifting the index.
        return DateTime.utc(d.year, d.month, d.day)
            .difference(DateTime.utc(start.year, start.month, start.day))
            .inDays;
      case _Period.month:
        return d.day - 1;
      case _Period.year:
        return d.month - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final currency = context.watch<SettingsCubit>().state.currencySymbol;
    final cardColor = Theme.of(context).cardColor;

    final w = _window();
    final endOfRange = DateTime(w.end.year, w.end.month, w.end.day, 23, 59, 59);

    // Only transactions of the chosen type that fall inside the window.
    final inRange = widget.expenses.where((e) {
      return e.isIncome == _showIncome &&
          !e.date.isBefore(w.start) &&
          !e.date.isAfter(endOfRange);
    }).toList();

    for (final e in inRange) {
      final i = _bucketIndex(e.date, w.start);
      if (i >= 0 && i < w.buckets.length) w.buckets[i].total += e.amount;
    }
    final total = inRange.fold<double>(0, (s, e) => s + e.amount);

    // Per-category breakdown for the same window.
    final byCategory = <String, ({Category category, double total})>{};
    for (final e in inRange) {
      final key = e.category.categoryId;
      final prev = byCategory[key];
      byCategory[key] =
          (category: e.category, total: (prev?.total ?? 0) + e.amount);
    }
    final breakdown = byCategory.values.toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    final noun = _showIncome ? 'income' : 'spending';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
        children: [
          const Text(
            'Statistics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: false, label: Text('Expenses')),
              ButtonSegment(value: true, label: Text('Income')),
            ],
            selected: {_showIncome},
            onSelectionChanged: (s) => setState(() => _showIncome = s.first),
          ),
          const SizedBox(height: 10),
          SegmentedButton<_Period>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: _Period.week, label: Text('Week')),
              ButtonSegment(value: _Period.month, label: Text('Month')),
              ButtonSegment(value: _Period.year, label: Text('Year')),
            ],
            selected: {_period},
            onSelectionChanged: (s) => setState(() {
              _period = s.first;
              _offset = 0;
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: 'Previous',
                onPressed: () => setState(() => _offset--),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(w.title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              IconButton(
                tooltip: 'Next',
                onPressed: _offset >= 0 ? null : () => setState(() => _offset++),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          Text(
            formatMoney(total, currency),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text(
            'total $noun',
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.outline),
          ),
          const SizedBox(height: 16),
          Container(
            height: 280,
            padding: const EdgeInsets.fromLTRB(8, 20, 12, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: cardColor,
            ),
            child: Stack(
              children: [
                MyChart(buckets: w.buckets, currency: currency),
                if (inRange.isEmpty)
                  Center(
                    child: Text(
                      'No $noun in this period',
                      style: TextStyle(color: scheme.outline),
                    ),
                  ),
              ],
            ),
          ),
          if (breakdown.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'By category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (final item in breakdown)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CategoryAvatar(
                            icon: item.category.icon,
                            colorValue: item.category.color,
                            radius: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.category.name.isEmpty
                                  ? 'Uncategorised'
                                  : item.category.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${formatMoney(item.total, currency)}  '
                            '(${(item.total / total * 100).toStringAsFixed(0)}%)',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: item.total / total,
                          minHeight: 6,
                          color: Color(item.category.color),
                          backgroundColor:
                              scheme.outline.withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
