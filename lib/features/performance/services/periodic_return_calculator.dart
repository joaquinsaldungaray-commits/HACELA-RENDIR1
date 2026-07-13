import 'package:hacela_rendir/features/performance/domain/monthly_return.dart';
import 'package:hacela_rendir/features/performance/domain/performance_snapshot.dart';
import 'package:hacela_rendir/features/performance/domain/yearly_return.dart';

abstract final class PeriodicReturnCalculator {
  static List<MonthlyReturn> calculateMonthlyReturns(
    List<PerformanceSnapshot> snapshots,
  ) {
    if (snapshots.length < 2) {
      return [];
    }

    final orderedSnapshots =
        List<PerformanceSnapshot>.from(snapshots)
          ..sort(
            (first, second) =>
                first.recordedAt.compareTo(
              second.recordedAt,
            ),
          );

    final snapshotsByMonth =
        <String, List<PerformanceSnapshot>>{};

    for (final snapshot in orderedSnapshots) {
      final monthKey =
          '${snapshot.recordedAt.year}-'
          '${snapshot.recordedAt.month.toString().padLeft(2, '0')}';

      snapshotsByMonth.putIfAbsent(
        monthKey,
        () => [],
      );

      snapshotsByMonth[monthKey]!.add(
        snapshot,
      );
    }

    final monthlyReturns = <MonthlyReturn>[];

    for (var index = 1;
    index < orderedSnapshots.length;
    index++) {

  final current =
      orderedSnapshots[index];

      final currentMonthKey =
          '${current.recordedAt.year}-'
          '${current.recordedAt.month.toString().padLeft(2, '0')}';

      final monthSnapshots =
          snapshotsByMonth[currentMonthKey];

      if (monthSnapshots == null ||
          monthSnapshots.isEmpty) {
        continue;
      }

      final monthFirst =
          monthSnapshots.first;

      if (current != monthSnapshots.last) {
        continue;
      }

      final startReference =
          _findPreviousSnapshot(
        snapshots: orderedSnapshots,
        target: monthFirst,
      );

      if (startReference == null ||
          startReference.totalEquity == 0) {
        continue;
      }

      final contributionChange =
          current.netContributions -
              startReference.netContributions;

      final investmentResult =
          current.totalEquity -
              startReference.totalEquity -
              contributionChange;

      final returnPercent =
          investmentResult /
              startReference.totalEquity *
              100;

      monthlyReturns.add(
        MonthlyReturn(
          year: current.recordedAt.year,
          month: current.recordedAt.month,
          returnPercent: returnPercent,
          startEquity:
              startReference.totalEquity,
          endEquity: current.totalEquity,
          netContributionChange:
              contributionChange,
        ),
      );
    }

    monthlyReturns.sort(
      (first, second) {
        final firstDate = DateTime(
          first.year,
          first.month,
        );

        final secondDate = DateTime(
          second.year,
          second.month,
        );

        return firstDate.compareTo(
          secondDate,
        );
      },
    );

    return monthlyReturns;
  }

  static List<YearlyReturn> calculateYearlyReturns(
    List<PerformanceSnapshot> snapshots,
  ) {
    final monthlyReturns =
        calculateMonthlyReturns(
      snapshots,
    );

    if (monthlyReturns.isEmpty) {
      return [];
    }

    final monthlyByYear =
        <int, List<MonthlyReturn>>{};

    for (final monthlyReturn in monthlyReturns) {
      monthlyByYear.putIfAbsent(
        monthlyReturn.year,
        () => [],
      );

      monthlyByYear[monthlyReturn.year]!.add(
        monthlyReturn,
      );
    }

    final yearlyReturns = <YearlyReturn>[];

    for (final entry in monthlyByYear.entries) {
      final year = entry.key;

      final months = List<MonthlyReturn>.from(
        entry.value,
      )..sort(
          (first, second) =>
              first.month.compareTo(
            second.month,
          ),
        );

      var growthFactor = 1.0;

      for (final monthlyReturn in months) {
        growthFactor *=
            1 +
                monthlyReturn.returnPercent /
                    100;
      }

      final firstMonth = months.first;
      final lastMonth = months.last;

      yearlyReturns.add(
        YearlyReturn(
          year: year,
          returnPercent:
              (growthFactor - 1) * 100,
          monthlyReturns:
              List<MonthlyReturn>.unmodifiable(
            months,
          ),
          startEquity:
              firstMonth.startEquity,
          endEquity:
              lastMonth.endEquity,
          netContributionChange:
              months.fold<double>(
            0,
            (
              total,
              monthlyReturn,
            ) =>
                total +
                monthlyReturn
                    .netContributionChange,
          ),
        ),
      );
    }

    yearlyReturns.sort(
      (first, second) =>
          first.year.compareTo(
        second.year,
      ),
    );

    return yearlyReturns;
  }

  static PerformanceSnapshot?
      _findPreviousSnapshot({
    required List<PerformanceSnapshot> snapshots,
    required PerformanceSnapshot target,
  }) {
    PerformanceSnapshot? previous;

    for (final snapshot in snapshots) {
      if (snapshot.recordedAt.isBefore(
        target.recordedAt,
      )) {
        previous = snapshot;
        continue;
      }

      break;
    }

    return previous;
  }
}