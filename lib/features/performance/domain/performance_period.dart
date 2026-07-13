enum PerformancePeriod {
  oneMonth,
  threeMonths,
  sixMonths,
  yearToDate,
  oneYear,
  all,
}

extension PerformancePeriodLabel on PerformancePeriod {
  String get shortLabel {
    return switch (this) {
      PerformancePeriod.oneMonth => '1M',
      PerformancePeriod.threeMonths => '3M',
      PerformancePeriod.sixMonths => '6M',
      PerformancePeriod.yearToDate => 'YTD',
      PerformancePeriod.oneYear => '1A',
      PerformancePeriod.all => 'Todo',
    };
  }

  String get fullLabel {
    return switch (this) {
      PerformancePeriod.oneMonth => 'Último mes',
      PerformancePeriod.threeMonths => 'Últimos 3 meses',
      PerformancePeriod.sixMonths => 'Últimos 6 meses',
      PerformancePeriod.yearToDate => 'Año en curso',
      PerformancePeriod.oneYear => 'Último año',
      PerformancePeriod.all => 'Todo el historial',
    };
  }

  DateTime? startDate({
    required DateTime now,
  }) {
    return switch (this) {
      PerformancePeriod.oneMonth => DateTime(
          now.year,
          now.month - 1,
          now.day,
        ),
      PerformancePeriod.threeMonths => DateTime(
          now.year,
          now.month - 3,
          now.day,
        ),
      PerformancePeriod.sixMonths => DateTime(
          now.year,
          now.month - 6,
          now.day,
        ),
      PerformancePeriod.yearToDate => DateTime(
          now.year,
        ),
      PerformancePeriod.oneYear => DateTime(
          now.year - 1,
          now.month,
          now.day,
        ),
      PerformancePeriod.all => null,
    };
  }
}