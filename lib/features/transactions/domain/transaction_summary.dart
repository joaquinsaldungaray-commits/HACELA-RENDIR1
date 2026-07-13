class TransactionSummary {
  const TransactionSummary({
    required this.totalPurchases,
    required this.totalSales,
    required this.totalDividends,
    required this.totalFees,
    required this.totalDeposits,
    required this.totalWithdrawals,
    required this.netCashFlow,
    required this.transactionCount,
  });

  final double totalPurchases;
  final double totalSales;
  final double totalDividends;
  final double totalFees;
  final double totalDeposits;
  final double totalWithdrawals;
  final double netCashFlow;
  final int transactionCount;
}