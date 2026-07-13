import 'package:flutter_test/flutter_test.dart';
import 'package:hacela_rendir/core/finance/calculators/portfolio_distribution_calculator.dart';
import 'package:hacela_rendir/features/assets/domain/asset_type.dart';
import 'package:hacela_rendir/features/portfolio/domain/portfolio_position.dart';

void main() {
  group('PortfolioDistributionCalculator', () {
    test(
      'calcula distribución por sector',
      () {
        final positions = [
          const PortfolioPosition(
            ticker: 'AAPL',
            name: 'Apple Inc.',
            quantity: 10,
            averagePrice: 100,
            currentPrice: 200,
            assetType: AssetType.stock,
            exchange: 'NASDAQ',
            country: 'Estados Unidos',
            currency: 'USD',
            sector: 'Tecnología',
            industry: 'Electrónica de consumo',
          ),
          const PortfolioPosition(
            ticker: 'MSFT',
            name: 'Microsoft Corporation',
            quantity: 5,
            averagePrice: 100,
            currentPrice: 200,
            assetType: AssetType.stock,
            exchange: 'NASDAQ',
            country: 'Estados Unidos',
            currency: 'USD',
            sector: 'Tecnología',
            industry: 'Software',
          ),
          const PortfolioPosition(
            ticker: 'GGAL',
            name: 'Grupo Financiero Galicia',
            quantity: 10,
            averagePrice: 50,
            currentPrice: 100,
            assetType: AssetType.stock,
            exchange: 'BYMA',
            country: 'Argentina',
            currency: 'ARS',
            sector: 'Finanzas',
            industry: 'Bancos',
          ),
        ];

        final distribution =
            PortfolioDistributionCalculator.calculate(
          positions,
        );

        expect(distribution.bySector.length, 2);

        expect(
          distribution.bySector.first.label,
          'Tecnología',
        );

        expect(
          distribution.bySector.first.value,
          3000,
        );

        expect(
          distribution.bySector.first.weightPercent,
          closeTo(75, 0.0001),
        );

        expect(
          distribution.bySector.last.label,
          'Finanzas',
        );

        expect(
          distribution.bySector.last.weightPercent,
          closeTo(25, 0.0001),
        );
      },
    );

    test(
      'calcula distribución por país, moneda y tipo',
      () {
        final positions = [
          const PortfolioPosition(
            ticker: 'SPY',
            name: 'SPDR S&P 500 ETF Trust',
            quantity: 2,
            averagePrice: 400,
            currentPrice: 500,
            assetType: AssetType.etf,
            exchange: 'NYSE Arca',
            country: 'Estados Unidos',
            currency: 'USD',
            sector: 'Diversificado',
            industry: 'ETF de índice',
          ),
          const PortfolioPosition(
            ticker: 'BTC',
            name: 'Bitcoin',
            quantity: 0.02,
            averagePrice: 50000,
            currentPrice: 50000,
            assetType: AssetType.crypto,
            exchange: 'Crypto',
            country: 'Global',
            currency: 'USD',
            sector: 'Activos digitales',
            industry: 'Criptomoneda',
          ),
        ];

        final distribution =
            PortfolioDistributionCalculator.calculate(
          positions,
        );

        expect(distribution.byCountry.length, 2);
        expect(distribution.byCurrency.length, 1);
        expect(distribution.byCurrency.first.label, 'USD');
        expect(distribution.byCurrency.first.weightPercent, 100);

        expect(distribution.byAssetType.length, 2);
        expect(
          distribution.byAssetType.first.weightPercent,
          50,
        );
        expect(
          distribution.byAssetType.last.weightPercent,
          50,
        );
      },
    );

    test(
      'devuelve listas vacías sin posiciones',
      () {
        final distribution =
            PortfolioDistributionCalculator.calculate(
          const [],
        );

        expect(distribution.bySector, isEmpty);
        expect(distribution.byCountry, isEmpty);
        expect(distribution.byCurrency, isEmpty);
        expect(distribution.byAssetType, isEmpty);
      },
    );
  });
}