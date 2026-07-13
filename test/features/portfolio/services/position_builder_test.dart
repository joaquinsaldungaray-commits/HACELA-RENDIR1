import 'package:flutter_test/flutter_test.dart';
import 'package:hacela_rendir/features/portfolio/services/position_builder.dart';
import 'package:hacela_rendir/features/transactions/domain/portfolio_transaction.dart';

void main() {
  group('PositionBuilder', () {
    test(
      'crea una posición a partir de una compra',
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
            fee: 5,
          ),
        ];

        final positions =
            PositionBuilder.buildFromTransactions(transactions);

        expect(positions.length, 1);

        final position = positions.first;

        expect(position.ticker, 'AAPL');
        expect(position.name, 'Apple Inc.');
        expect(position.quantity, 10);
        expect(position.averagePrice, 100.5);
        expect(position.currentPrice, 100);
      },
    );

    test(
      'calcula el costo promedio ponderado de varias compras',
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
            fee: 5,
          ),
          PortfolioTransaction(
            id: '2',
            type: TransactionType.buy,
            date: DateTime(2026, 1, 2),
            ticker: 'AAPL',
            assetName: 'Apple Inc.',
            quantity: 5,
            price: 120,
          ),
        ];

        final positions =
            PositionBuilder.buildFromTransactions(transactions);

        final position = positions.first;

        expect(position.quantity, 15);
        expect(position.averagePrice, 107);
        expect(position.currentPrice, 120);
      },
    );

    test(
      'una venta reduce la cantidad sin modificar el costo promedio',
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
            quantity: 5,
            price: 120,
          ),
          PortfolioTransaction(
            id: '3',
            type: TransactionType.sell,
            date: DateTime(2026, 1, 3),
            ticker: 'AAPL',
            assetName: 'Apple Inc.',
            quantity: 3,
            price: 140,
          ),
        ];

        final positions =
            PositionBuilder.buildFromTransactions(transactions);

        final position = positions.first;

        expect(position.quantity, 12);
        expect(
          position.averagePrice,
          closeTo(106.6666667, 0.0001),
        );
        expect(position.currentPrice, 140);
      },
    );

    test(
      'elimina la posición cuando se vende toda la cantidad',
      () {
        final transactions = [
          PortfolioTransaction(
            id: '1',
            type: TransactionType.buy,
            date: DateTime(2026, 1, 1),
            ticker: 'MSFT',
            assetName: 'Microsoft Corporation',
            quantity: 4,
            price: 300,
          ),
          PortfolioTransaction(
            id: '2',
            type: TransactionType.sell,
            date: DateTime(2026, 1, 2),
            ticker: 'MSFT',
            assetName: 'Microsoft Corporation',
            quantity: 4,
            price: 340,
          ),
        ];

        final positions =
            PositionBuilder.buildFromTransactions(transactions);

        expect(positions, isEmpty);
      },
    );

    test(
      'admite cantidades fraccionarias',
      () {
        final transactions = [
          PortfolioTransaction(
            id: '1',
            type: TransactionType.buy,
            date: DateTime(2026, 1, 1),
            ticker: 'BTC',
            assetName: 'Bitcoin',
            quantity: 0.025,
            price: 60000,
          ),
        ];

        final positions =
            PositionBuilder.buildFromTransactions(transactions);

        final position = positions.first;

        expect(position.quantity, 0.025);
        expect(position.currentValue, 1500);
      },
    );

    test(
      'ignora dividendos, depósitos y otros movimientos sin posición',
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
            type: TransactionType.dividend,
            date: DateTime(2026, 1, 2),
            amount: 25,
          ),
          PortfolioTransaction(
            id: '3',
            type: TransactionType.fee,
            date: DateTime(2026, 1, 3),
            amount: 10,
          ),
        ];

        final positions =
            PositionBuilder.buildFromTransactions(transactions);

        expect(positions, isEmpty);
      },
    );
  });
}