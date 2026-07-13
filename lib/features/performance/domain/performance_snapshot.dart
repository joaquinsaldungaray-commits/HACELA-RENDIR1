class PerformanceSnapshot {
  const PerformanceSnapshot({
    required this.id,
    required this.recordedAt,
    required this.cashBalance,
    required this.marketValue,
    required this.totalEquity,
    required this.netContributions,
    required this.investedCapital,
    required this.totalResult,
  });

  final String id;
  final DateTime recordedAt;

  final double cashBalance;
  final double marketValue;
  final double totalEquity;
  final double netContributions;
  final double investedCapital;
  final double totalResult;

  double get profitOverContributions {
    return totalEquity - netContributions;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recordedAt': recordedAt.toIso8601String(),
      'cashBalance': cashBalance,
      'marketValue': marketValue,
      'totalEquity': totalEquity,
      'netContributions': netContributions,
      'investedCapital': investedCapital,
      'totalResult': totalResult,
    };
  }

  factory PerformanceSnapshot.fromJson(
    Map<String, dynamic> json,
  ) {
    return PerformanceSnapshot(
      id: json['id'] as String,
      recordedAt: DateTime.parse(
        json['recordedAt'] as String,
      ),
      cashBalance:
          (json['cashBalance'] as num?)?.toDouble() ?? 0,
      marketValue:
          (json['marketValue'] as num?)?.toDouble() ?? 0,
      totalEquity:
          (json['totalEquity'] as num?)?.toDouble() ?? 0,
      netContributions:
          (json['netContributions'] as num?)?.toDouble() ?? 0,
      investedCapital:
          (json['investedCapital'] as num?)?.toDouble() ?? 0,
      totalResult:
          (json['totalResult'] as num?)?.toDouble() ?? 0,
    );
  }
}