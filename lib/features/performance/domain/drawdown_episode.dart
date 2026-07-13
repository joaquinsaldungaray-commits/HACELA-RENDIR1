class DrawdownEpisode {
  const DrawdownEpisode({
    required this.peakDate,
    required this.troughDate,
    required this.recoveryDate,
    required this.peakEquity,
    required this.troughEquity,
    required this.drawdownPercent,
    required this.daysToTrough,
    required this.durationDays,
  });

  final DateTime peakDate;
  final DateTime troughDate;
  final DateTime? recoveryDate;

  final double peakEquity;
  final double troughEquity;
  final double drawdownPercent;

  final int daysToTrough;
  final int durationDays;

  bool get isRecovered => recoveryDate != null;

  bool get isActive => recoveryDate == null;

  double get lossAmount => troughEquity - peakEquity;
}