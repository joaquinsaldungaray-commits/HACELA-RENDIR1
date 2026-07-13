import 'package:flutter_test/flutter_test.dart';
import 'package:hacela_rendir/features/performance/domain/performance_snapshot.dart';
import 'package:hacela_rendir/features/performance/services/periodic_return_calculator.dart';

void main() {
  group('PeriodicReturnCalculator', () {
    test(
      'devuelve listas vacías con menos de dos snapshots',
      () {
        final monthly =
            PeriodicReturnCalculator.calculateMonthlyReturns(
          const [],
        );

        final yearly =
            PeriodicReturnCalculator.calculateYearlyReturns(
          const [],
        );

        expect(monthly, isEmpty);
        expect(yearly, isEmpty);
      },
    );

    test(
      'calcula el retorno mensual sin confundir depósitos con ganancias',
      () {
        final snapshots = [
          PerformanceSnapshot(
            id: '1',
            recordedAt: DateTime(2025, 12, 31),
            cashBalance: 1000,
            marketValue: 0,
            totalEquity: 1000,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 0,
          ),
          PerformanceSnapshot(
            id: '2',
            recordedAt: DateTime(2026, 1, 15),
            cashBalance: 1550,
            marketValue: 0,
            totalEquity: 1550,
            netContributions: 1500,
            investedCapital: 0,
            totalResult: 50,
          ),
          PerformanceSnapshot(
            id: '3',
            recordedAt: DateTime(2026, 1, 31),
            cashBalance: 1600,
            marketValue: 0,
            totalEquity: 1600,
            netContributions: 1500,
            investedCapital: 0,
            totalResult: 100,
          ),
        ];

        final monthly =
            PeriodicReturnCalculator.calculateMonthlyReturns(
          snapshots,
        );

        expect(monthly.length, 1);
        expect(monthly.first.year, 2026);
        expect(monthly.first.month, 1);
        expect(
          monthly.first.returnPercent,
          closeTo(10, 0.0001),
        );
      },
    );

    test(
      'calcula varios meses de rendimiento',
      () {
        final snapshots = [
          PerformanceSnapshot(
            id: '1',
            recordedAt: DateTime(2025, 12, 31),
            cashBalance: 1000,
            marketValue: 0,
            totalEquity: 1000,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 0,
          ),
          PerformanceSnapshot(
            id: '2',
            recordedAt: DateTime(2026, 1, 31),
            cashBalance: 1100,
            marketValue: 0,
            totalEquity: 1100,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 100,
          ),
          PerformanceSnapshot(
            id: '3',
            recordedAt: DateTime(2026, 2, 28),
            cashBalance: 1045,
            marketValue: 0,
            totalEquity: 1045,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 45,
          ),
          PerformanceSnapshot(
            id: '4',
            recordedAt: DateTime(2026, 3, 31),
            cashBalance: 1149.5,
            marketValue: 0,
            totalEquity: 1149.5,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 149.5,
          ),
        ];

        final monthly =
            PeriodicReturnCalculator.calculateMonthlyReturns(
          snapshots,
        );

        expect(monthly.length, 3);

        expect(
          monthly[0].returnPercent,
          closeTo(10, 0.0001),
        );

        expect(
          monthly[1].returnPercent,
          closeTo(-5, 0.0001),
        );

        expect(
          monthly[2].returnPercent,
          closeTo(10, 0.0001),
        );
      },
    );

    test(
      'encadena retornos mensuales para calcular el retorno anual',
      () {
        final snapshots = [
          PerformanceSnapshot(
            id: '1',
            recordedAt: DateTime(2025, 12, 31),
            cashBalance: 1000,
            marketValue: 0,
            totalEquity: 1000,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 0,
          ),
          PerformanceSnapshot(
            id: '2',
            recordedAt: DateTime(2026, 1, 31),
            cashBalance: 1100,
            marketValue: 0,
            totalEquity: 1100,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 100,
          ),
          PerformanceSnapshot(
            id: '3',
            recordedAt: DateTime(2026, 2, 28),
            cashBalance: 1045,
            marketValue: 0,
            totalEquity: 1045,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 45,
          ),
          PerformanceSnapshot(
            id: '4',
            recordedAt: DateTime(2026, 3, 31),
            cashBalance: 1149.5,
            marketValue: 0,
            totalEquity: 1149.5,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 149.5,
          ),
        ];

        final yearly =
            PeriodicReturnCalculator.calculateYearlyReturns(
          snapshots,
        );

        expect(yearly.length, 1);
        expect(yearly.first.year, 2026);
        expect(yearly.first.monthlyReturns.length, 3);

        expect(
          yearly.first.returnPercent,
          closeTo(14.95, 0.0001),
        );
      },
    );

    test(
      'genera años separados',
      () {
        final snapshots = [
          PerformanceSnapshot(
            id: '1',
            recordedAt: DateTime(2024, 12, 31),
            cashBalance: 1000,
            marketValue: 0,
            totalEquity: 1000,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 0,
          ),
          PerformanceSnapshot(
            id: '2',
            recordedAt: DateTime(2025, 1, 31),
            cashBalance: 1100,
            marketValue: 0,
            totalEquity: 1100,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 100,
          ),
          PerformanceSnapshot(
            id: '3',
            recordedAt: DateTime(2025, 12, 31),
            cashBalance: 1210,
            marketValue: 0,
            totalEquity: 1210,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 210,
          ),
          PerformanceSnapshot(
            id: '4',
            recordedAt: DateTime(2026, 1, 31),
            cashBalance: 1270.5,
            marketValue: 0,
            totalEquity: 1270.5,
            netContributions: 1000,
            investedCapital: 0,
            totalResult: 270.5,
          ),
        ];

        final yearly =
            PeriodicReturnCalculator.calculateYearlyReturns(
          snapshots,
        );

        expect(yearly.length, 2);
        expect(yearly[0].year, 2025);
        expect(yearly[1].year, 2026);
      },
    );
  });
}