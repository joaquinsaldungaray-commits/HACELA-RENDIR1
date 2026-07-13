import 'package:flutter_test/flutter_test.dart';
import 'package:hacela_rendir/features/portfolio/services/position_builder.dart';
import 'package:hacela_rendir/features/transactions/domain/portfolio_transaction.dart';
import 'package:hacela_rendir/features/transactions/services/investment_result_calculator.dart';

void main() {
  group('InvestmentResultCalculator', () {
    test(
      'calcula una ganancia realizada por una venta parcial',
      () {
        final transactions = [
          PortfolioTransaction(
            id: '1',
            type: TransactionType.buy,
            date: DateTime(2026, 1, 1),
            ticker: 'AAPL',
            assetName: 'Apple Inc.',
            quantity: 10,
            price: 100,
          ),
          PortfolioTransaction(
            id: '2',
            type: TransactionType.sell,
            date: DateTime(2026, 1, 2),
            ticker: 'AAPL',
            assetName: 'Apple Inc.',
            quantity: 3,
            price: 140,
            fee: 2,
          ),
        ];

        final positions =
            PositionBuilder.buildFromTransactions(transactions);

        final result = InvestmentResultCalculator.calculate(
          transactions: transactions,
          openPositions: positions,
        );

        expect(result.realizedProfit, 118);
        expect(result.unrealizedProfit, 280);
        expect(result.fees, 2);
        expect(result.totalResult, 398);
      },
    );

    test(
      'incluye dividendos en el resultado total',
      () {
        final transactions = [
          PortfolioTransaction(
            id: '1',
            type: TransactionType.buy,
            date: DateTime(2026, 1, 1),
            ticker: 'MSFT',
            assetName: 'Microsoft Corporation',
            quantity: 2,
            price: 300,
          ),
          PortfolioTransaction(
            id: '2',
            type: TransactionType.dividend,
            date: DateTime(2026, 1, 2),
            amount: 25,
          ),
        ];

        final positions =
            PositionBuilder.buildFromTransactions(transactions);

        final result = InvestmentResultCalculator.calculate(
          transactions: transactions,
          openPositions: positions,
        );

        expect(result.dividends, 25);
        expect(result.realizedProfit, 0);
        expect(result.totalResult, 25);
      },
    );

    test(
      'descuenta comisiones independientes',
      () {
        final transactions = [
          PortfolioTransaction(
            id: '1',
            type: TransactionType.fee,
            date: DateTime(2026, 1, 1),
            amount: 15,
          ),
        ];

        final result = InvestmentResultCalculator.calculate(
          transactions: transactions,
          openPositions: const [],
        );

        expect(result.fees, 15);
        expect(result.totalResult, -15);
      },
    );

    test(
      'calcula múltiples compras con costo promedio',
      () {
        final transactions = [
          PortfolioTransaction(
            id: '1',
            type: TransactionType.buy,
            date: DateTime(2026, 1, 1),
            ticker: 'AAPL',
            assetName: 'Apple Inc.',
            quantity: 10,
            price: 100,
          ),
          PortfolioTransaction(
            id: '2',
            type: TransactionType.buy,
            date: DateTime(2026, 1, 2),
            ticker: 'AAPL',
            assetName: 'Apple Inc.',
            quantity: 10,
            price: 120,
          ),
          PortfolioTransaction(
            id: '3',
            type: TransactionType.sell,
            date: DateTime(2026, 1, 3),
            ticker: 'AAPL',
            assetName: 'Apple Inc.',
            quantity: 5,
            price: 150,
          ),
        ];

        final positions =
            PositionBuilder.buildFromTransactions(transactions);

        final result = InvestmentResultCalculator.calculate(
          transactions: transactions,
          openPositions: positions,
        );

        expect(result.realizedProfit, 200);
        expect(result.unrealizedProfit, 600);
        expect(result.totalResult, 800);
      },
    );

    test(
      'depósitos y retiros no modifican el resultado',
      () {
        final transactions = [
          PortfolioTransaction(
            id: '1',
            type: TransactionType.deposit,
            date: DateTime(2026, 1, 1),
            amount: 5000,
          ),
          PortfolioTransaction(
            id: '2',
            type: TransactionType.withdrawal,
            date: DateTime(2026, 1, 2),
            amount: 1000,
          ),
        ];

        final result = InvestmentResultCalculator.calculate(
          transactions: transactions,
          openPositions: const [],
        );

        expect(result.realizedProfit, 0);
        expect(result.unrealizedProfit, 0);
        expect(result.dividends, 0);
        expect(result.fees, 0);
        expect(result.totalResult, 0);
      },
    );
  });
}