import 'package:flutter/material.dart';
import 'package:hacela_rendir/features/performance/domain/performance_period.dart';

class PerformancePeriodSelector extends StatelessWidget {
  const PerformancePeriodSelector({
    required this.selectedPeriod,
    required this.onChanged,
    super.key,
  });

  final PerformancePeriod selectedPeriod;
  final ValueChanged<PerformancePeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<PerformancePeriod>(
        segments: PerformancePeriod.values
            .map(
              (period) => ButtonSegment<PerformancePeriod>(
                value: period,
                label: Text(
                  period.shortLabel,
                ),
              ),
            )
            .toList(),
        selected: {
          selectedPeriod,
        },
        showSelectedIcon: false,
        onSelectionChanged: (selection) {
          if (selection.isEmpty) {
            return;
          }

          onChanged(
            selection.first,
          );
        },
      ),
    );
  }
}