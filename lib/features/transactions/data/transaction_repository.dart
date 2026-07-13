import 'dart:convert';

import 'package:hacela_rendir/features/transactions/domain/portfolio_transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionRepository {
  static const String _storageKey = 'portfolio_transactions';

  Future<List<PortfolioTransaction>> loadTransactions() async {
    final preferences = await SharedPreferences.getInstance();
    final rawData = preferences.getString(_storageKey);

    if (rawData == null || rawData.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(rawData) as List<dynamic>;

    final transactions = decoded
        .map(
          (item) => PortfolioTransaction.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();

    transactions.sort(
      (a, b) => b.date.compareTo(a.date),
    );

    return transactions;
  }

  Future<void> saveTransactions(
    List<PortfolioTransaction> transactions,
  ) async {
    final preferences = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      transactions
          .map(
            (transaction) => transaction.toJson(),
          )
          .toList(),
    );

    await preferences.setString(
      _storageKey,
      encoded,
    );
  }

  Future<void> clearTransactions() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_storageKey);
  }
}