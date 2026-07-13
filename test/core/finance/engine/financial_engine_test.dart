import 'package:flutter_test/flutter_test.dart';
import 'package:hacela_rendir/core/finance/engine/financial_engine.dart';
import 'package:hacela_rendir/features/transactions/domain/portfolio_transaction.dart';

void main() {
  group('FinancialEngine', () {
    test(
      'devuelve valores en cero cuando no existen movimientos',
      () {
        final snapshot = FinancialEngine.calculate(
          transactions: const [],
        );

        expect(snapshot.cashBalance, 0);
        expect(snapshot.investedCapital, 0);
        expect(snapshot.marketValue, 0);
        expect(snapshot.realizedProfit, 0);
        expect(snapshot.unrealizedProfit, 0);
        expect(snapshot.dividends, 0);
        expect(snapshot.fees, 0);
        expect(snapshot.totalResult, 0);
        expect(snapshot.returnPercent, 0);
        expect(snapshot.positionsCount, 0);
        expect(snapshot.totalEquity, 0);
      },
    );

    test(
      'calcula correctamente una cuenta con depósito y compra',
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
            type: TransactionType.buy,
            date: DateTime(2026, 1, 2),
            ticker: 'AAPL',
            assetName: 'Apple Inc.',
            quantity: 10,
            price: 100,
            fee: 5,
          ),
        ];

        final snapshot = FinancialEngine.calculate(
          transactions: transactions,
        );

        expect(snapshot.cashBalance, 3995);
        expect(snapshot.investedCapital, 1005);
        expect(snapshot.marketValue, 1000);
        expect(snapshot.unrealizedProfit, -5);
        expect(snapshot.realizedProfit, 0);
        expect(snapshot.fees, 5);
        expect(snapshot.totalResult, -5);
        expect(snapshot.positionsCount, 1);
        expect(snapshot.totalEquity, 4995);
      },
    );

    test(
      'consolida compra, venta, dividendo y efectivo',
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
            type: TransactionType.buy,
            date: DateTime(2026, 1, 2),
            ticker: 'AAPL',
            assetName: 'Apple Inc.',
            quantity: 10,
            price: 100,
            fee: 5,
          ),
          PortfolioTransaction(
            id: '3',
            type: TransactionType.sell,
            date: DateTime(2026, 1, 3),
            ticker: 'AAPL',
            assetName: 'Apple Inc.',
            quantity: 3,
            price: 140,
            fee: 2,
          ),
          PortfolioTransaction(
            id: '4',
            type: TransactionType.dividend,
            date: DateTime(2026, 1, 4),
            amount: 25,
          ),
        ];

        final snapshot = FinancialEngine.calculate(
          transactions: transactions,
        );

        expect(snapshot.cashBalance, 4438);
        expect(snapshot.positionsCount, 1);

        expect(
          snapshot.investedCapital,
          closeTo(703.5, 0.0001),
        );

        expect(
          snapshot.marketValue,
          closeTo(980, 0.0001),
        );

        expect(
          snapshot.realizedProfit,
          closeTo(116.5, 0.0001),
        );

        expect(
          snapshot.unrealizedProfit,
          closeTo(276.5, 0.0001),
        );

        expect(snapshot.dividends, 25);
        expect(snapshot.fees, 7);

        expect(
          snapshot.totalResult,
          closeTo(418, 0.0001),
        );

        expect(
          snapshot.returnPercent,
          closeTo(59.4172, 0.001),
        );

        expect(
          snapshot.totalEquity,
          closeTo(5418, 0.0001),
        );
      },
    );

    test(
      'los depósitos aumentan el efectivo pero no la rentabilidad',
      () {
        final transactions = [
          PortfolioTransaction(
            id: '1',
            type: TransactionType.deposit,
            date: DateTime(2026, 1, 1),
            amount: 2500,
          ),
        ];

        final snapshot = FinancialEngine.calculate(
          transactions: transactions,
        );

        expect(snapshot.cashBalance, 2500);
        expect(snapshot.totalEquity, 2500);
        expect(snapshot.totalResult, 0);
        expect(snapshot.returnPercent, 0);
        expect(snapshot.positionsCount, 0);
      },
    );

    test(
      'un retiro reduce el efectivo sin generar pérdida financiera',
      () {
        final transactions = [
          PortfolioTransaction(
            id: '1',
            type: TransactionType.deposit,
            date: DateTime(2026, 1, 1),
            amount: 3000,
          ),
          PortfolioTransaction(
            id: '2',
            type: TransactionType.withdrawal,
            date: DateTime(2026, 1, 2),
            amount: 750,
          ),
        ];

        final snapshot = FinancialEngine.calculate(
          transactions: transactions,
        );

        expect(snapshot.cashBalance, 2250);
        expect(snapshot.totalEquity, 2250);
        expect(snapshot.totalResult, 0);
        expect(snapshot.returnPercent, 0);
      },
    );
  });
}