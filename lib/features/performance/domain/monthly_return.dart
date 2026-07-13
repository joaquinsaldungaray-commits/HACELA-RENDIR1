class MonthlyReturn {
  const MonthlyReturn({
    required this.year,
    required this.month,
    required this.returnPercent,
    required this.startEquity,
    required this.endEquity,
    required this.netContributionChange,
  });

  final int year;
  final int month;

  final double returnPercent;
  final double startEquity;
  final double endEquity;
  final double netContributionChange;

  String get id {
    return '$year-${month.toString().padLeft(2, '0')}';
  }

  String get monthShortLabel {
    return switch (month) {
      1 => 'ENE',
      2 => 'FEB',
      3 => 'MAR',
      4 => 'ABR',
      5 => 'MAY',
      6 => 'JUN',
      7 => 'JUL',
      8 => 'AGO',
      9 => 'SEP',
      10 => 'OCT',
      11 => 'NOV',
      12 => 'DIC',
      _ => 'N/D',
    };
  }

  bool get isPositive => returnPercent >= 0;
}