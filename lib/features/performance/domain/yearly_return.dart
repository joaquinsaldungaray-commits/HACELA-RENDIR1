import 'package:hacela_rendir/features/performance/domain/monthly_return.dart';

class YearlyReturn {
  const YearlyReturn({
    required this.year,
    required this.returnPercent,
    required this.monthlyReturns,
    required this.startEquity,
    required this.endEquity,
    required this.netContributionChange,
  });

  final int year;

  final double returnPercent;
  final List<MonthlyReturn> monthlyReturns;

  final double startEquity;
  final double endEquity;
  final double netContributionChange;

  bool get isPositive => returnPercent >= 0;

  MonthlyReturn? month(
    int monthNumber,
  ) {
    for (final monthlyReturn in monthlyReturns) {
      if (monthlyReturn.month == monthNumber) {
        return monthlyReturn;
      }
    }

    return null;
  }
}