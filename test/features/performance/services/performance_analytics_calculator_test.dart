import 'package:flutter_test/flutter_test.dart';
import 'package:hacela_rendir/features/performance/domain/performance_snapshot.dart';
import 'package:hacela_rendir/features/performance/services/performance_analytics_calculator.dart';

void main() {
  group('PerformanceAnalyticsCalculator', () {
    test(
      'devuelve métricas vacías sin observaciones',
      () {
        final result =
            PerformanceAnalyticsCalculator.calculate(
          snapshots: const [],
        );

        expect(result.twrPercent, 0);
        expect(result.cagrPercent, 0);
        expect(
          result.annualizedVolatilityPercent,
          0,
        );
        expect(result.sharpeRatio, 0);
        expect(result.sortinoRatio, 0);
        expect(result.periodsCount, 0);
        expect(result.observationsCount, 0);
      },
    );

    test(
      'calcula un retorno del diez por ciento en un año',
      () {
        final snapshots = [
          PerformanceSnapshot(
            id: '1',
            recordedAt: DateTime(2025, 1, 1),
            cashBalance: 1000,
            marketValue: 0,
            totalEquity: 1000,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 0,
          ),
          PerformanceSnapshot(
            id: '2',
            recordedAt: DateTime(2026, 1, 1),
            cashBalance: 1100,
            marketValue: 0,
            totalEquity: 1100,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 100,
          ),
        ];

        final result =
            PerformanceAnalyticsCalculator.calculate(
          snapshots: snapshots,
        );

        expect(
          result.twrPercent,
          closeTo(10, 0.0001),
        );

        expect(
          result.cagrPercent,
          closeTo(10, 0.05),
        );

        expect(result.periodsCount, 1);
        expect(result.positivePeriods, 1);
        expect(result.negativePeriods, 0);
        expect(
          result.bestPeriodReturnPercent,
          closeTo(10, 0.0001),
        );
      },
    );

    test(
      'descuenta depósitos al calcular el retorno',
      () {
        final snapshots = [
          PerformanceSnapshot(
            id: '1',
            recordedAt: DateTime(2025, 1, 1),
            cashBalance: 1000,
            marketValue: 0,
            totalEquity: 1000,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 0,
          ),
          PerformanceSnapshot(
            id: '2',
            recordedAt: DateTime(2026, 1, 1),
            cashBalance: 1600,
            marketValue: 0,
            totalEquity: 1600,
            netContributions: 1500,
            investedCapital: 0,
            totalResult: 100,
          ),
        ];

        final result =
            PerformanceAnalyticsCalculator.calculate(
          snapshots: snapshots,
        );

        expect(
          result.twrPercent,
          closeTo(10, 0.0001),
        );

        expect(
          result.cagrPercent,
          closeTo(10, 0.05),
        );
      },
    );

    test(
      'encadena correctamente rendimientos positivos y negativos',
      () {
        final snapshots = [
          PerformanceSnapshot(
            id: '1',
            recordedAt: DateTime(2026, 1, 1),
            cashBalance: 1000,
            marketValue: 0,
            totalEquity: 1000,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 0,
          ),
          PerformanceSnapshot(
            id: '2',
            recordedAt: DateTime(2026, 1, 2),
            cashBalance: 1100,
            marketValue: 0,
            totalEquity: 1100,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 100,
          ),
          PerformanceSnapshot(
            id: '3',
            recordedAt: DateTime(2026, 1, 3),
            cashBalance: 1045,
            marketValue: 0,
            totalEquity: 1045,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 45,
          ),
        ];

        final result =
            PerformanceAnalyticsCalculator.calculate(
          snapshots: snapshots,
        );

        expect(
          result.twrPercent,
          closeTo(4.5, 0.0001),
        );

        expect(
          result.averagePeriodReturnPercent,
          closeTo(2.5, 0.0001),
        );

        expect(
          result.bestPeriodReturnPercent,
          closeTo(10, 0.0001),
        );

        expect(
          result.worstPeriodReturnPercent,
          closeTo(-5, 0.0001),
        );

        expect(result.positivePeriods, 1);
        expect(result.negativePeriods, 1);
        expect(result.periodsCount, 2);

        expect(
          result.annualizedVolatilityPercent,
          greaterThan(0),
        );
      },
    );

    test(
      'no interpreta un retiro como una pérdida de inversión',
      () {
        final snapshots = [
          PerformanceSnapshot(
            id: '1',
            recordedAt: DateTime(2025, 1, 1),
            cashBalance: 1000,
            marketValue: 0,
            totalEquity: 1000,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 0,
          ),
          PerformanceSnapshot(
            id: '2',
            recordedAt: DateTime(2026, 1, 1),
            cashBalance: 900,
            marketValue: 0,
            totalEquity: 900,
            netContributions: 800,
            investedCapital: 0,
            totalResult: 100,
          ),
        ];

        final result =
            PerformanceAnalyticsCalculator.calculate(
          snapshots: snapshots,
        );

        expect(
          result.twrPercent,
          closeTo(10, 0.0001),
        );
      },
    );

    test(
      'calcula Sharpe y Sortino con varios períodos',
      () {
        final snapshots = [
          PerformanceSnapshot(
            id: '1',
            recordedAt: DateTime(2026, 1, 1),
            cashBalance: 1000,
            marketValue: 0,
            totalEquity: 1000,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 0,
          ),
          PerformanceSnapshot(
            id: '2',
            recordedAt: DateTime(2026, 1, 2),
            cashBalance: 1020,
            marketValue: 0,
            totalEquity: 1020,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 20,
          ),
          PerformanceSnapshot(
            id: '3',
            recordedAt: DateTime(2026, 1, 3),
            cashBalance: 1009.8,
            marketValue: 0,
            totalEquity: 1009.8,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 9.8,
          ),
          PerformanceSnapshot(
            id: '4',
            recordedAt: DateTime(2026, 1, 4),
            cashBalance: 1030,
            marketValue: 0,
            totalEquity: 1030,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 30,
          ),
        ];

        final result =
            PerformanceAnalyticsCalculator.calculate(
          snapshots: snapshots,
          annualRiskFreeRatePercent: 0,
        );

        expect(
          result.annualizedVolatilityPercent,
          greaterThan(0),
        );

        expect(
          result.sharpeRatio.isFinite,
          isTrue,
        );

        expect(
          result.sortinoRatio.isFinite,
          isTrue,
        );

        expect(result.periodsCount, 3);
      },
    );
  });
}