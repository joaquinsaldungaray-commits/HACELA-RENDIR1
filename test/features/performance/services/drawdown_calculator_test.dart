import 'package:flutter_test/flutter_test.dart';
import 'package:hacela_rendir/features/performance/domain/performance_snapshot.dart';
import 'package:hacela_rendir/features/performance/services/drawdown_calculator.dart';

void main() {
  group('DrawdownCalculator', () {
    test(
      'devuelve un resumen vacío sin snapshots',
      () {
        final result =
            DrawdownCalculator.calculate(
          const [],
        );

        expect(
          result.currentDrawdownPercent,
          0,
        );

        expect(
          result.maximumDrawdown,
          isNull,
        );

        expect(
          result.episodes,
          isEmpty,
        );

        expect(
          result.isInDrawdown,
          isFalse,
        );
      },
    );

    test(
      'no genera drawdown cuando el patrimonio siempre crece',
      () {
        final snapshots = [
          _snapshot(
            id: '1',
            date: DateTime(2026, 1, 1),
            equity: 1000,
          ),
          _snapshot(
            id: '2',
            date: DateTime(2026, 1, 2),
            equity: 1100,
          ),
          _snapshot(
            id: '3',
            date: DateTime(2026, 1, 3),
            equity: 1200,
          ),
        ];

        final result =
            DrawdownCalculator.calculate(
          snapshots,
        );

        expect(
          result.currentDrawdownPercent,
          0,
        );

        expect(
          result.maximumDrawdown,
          isNull,
        );

        expect(
          result.episodes,
          isEmpty,
        );

        expect(
          result.currentPeakEquity,
          1200,
        );
      },
    );

    test(
      'calcula un episodio recuperado',
      () {
        final snapshots = [
          _snapshot(
            id: '1',
            date: DateTime(2026, 1, 1),
            equity: 1000,
          ),
          _snapshot(
            id: '2',
            date: DateTime(2026, 1, 5),
            equity: 1200,
          ),
          _snapshot(
            id: '3',
            date: DateTime(2026, 1, 10),
            equity: 1080,
          ),
          _snapshot(
            id: '4',
            date: DateTime(2026, 1, 15),
            equity: 900,
          ),
          _snapshot(
            id: '5',
            date: DateTime(2026, 1, 25),
            equity: 1200,
          ),
        ];

        final result =
            DrawdownCalculator.calculate(
          snapshots,
        );

        expect(
          result.episodes.length,
          1,
        );

        final episode =
            result.episodes.first;

        expect(
          episode.peakEquity,
          1200,
        );

        expect(
          episode.troughEquity,
          900,
        );

        expect(
          episode.drawdownPercent,
          closeTo(-25, 0.0001),
        );

        expect(
          episode.daysToTrough,
          10,
        );

        expect(
          episode.durationDays,
          20,
        );

        expect(
          episode.recoveryDate,
          DateTime(2026, 1, 25),
        );

        expect(
          episode.isRecovered,
          isTrue,
        );

        expect(
          result.currentDrawdownPercent,
          0,
        );
      },
    );

    test(
      'calcula un drawdown activo no recuperado',
      () {
        final snapshots = [
          _snapshot(
            id: '1',
            date: DateTime(2026, 2, 1),
            equity: 1000,
          ),
          _snapshot(
            id: '2',
            date: DateTime(2026, 2, 5),
            equity: 1300,
          ),
          _snapshot(
            id: '3',
            date: DateTime(2026, 2, 10),
            equity: 1170,
          ),
          _snapshot(
            id: '4',
            date: DateTime(2026, 2, 20),
            equity: 1040,
          ),
        ];

        final result =
            DrawdownCalculator.calculate(
          snapshots,
        );

        expect(
          result.isInDrawdown,
          isTrue,
        );

        expect(
          result.currentDrawdownPercent,
          closeTo(-20, 0.0001),
        );

        expect(
          result.currentDrawdownDurationDays,
          15,
        );

        expect(
          result.episodes.length,
          1,
        );

        final episode =
            result.episodes.first;

        expect(
          episode.isActive,
          isTrue,
        );

        expect(
          episode.recoveryDate,
          isNull,
        );

        expect(
          episode.drawdownPercent,
          closeTo(-20, 0.0001),
        );
      },
    );

    test(
      'identifica el mayor entre varios drawdowns',
      () {
        final snapshots = [
          _snapshot(
            id: '1',
            date: DateTime(2026, 1, 1),
            equity: 1000,
          ),
          _snapshot(
            id: '2',
            date: DateTime(2026, 1, 5),
            equity: 1200,
          ),
          _snapshot(
            id: '3',
            date: DateTime(2026, 1, 10),
            equity: 1080,
          ),
          _snapshot(
            id: '4',
            date: DateTime(2026, 1, 15),
            equity: 1200,
          ),
          _snapshot(
            id: '5',
            date: DateTime(2026, 1, 20),
            equity: 1500,
          ),
          _snapshot(
            id: '6',
            date: DateTime(2026, 1, 25),
            equity: 1050,
          ),
          _snapshot(
            id: '7',
            date: DateTime(2026, 2, 5),
            equity: 1500,
          ),
        ];

        final result =
            DrawdownCalculator.calculate(
          snapshots,
        );

        expect(
          result.episodes.length,
          2,
        );

        expect(
          result.maximumDrawdown,
          isNotNull,
        );

        expect(
          result.maximumDrawdownPercent,
          closeTo(-30, 0.0001),
        );

        expect(
          result.maximumDrawdown!
              .peakEquity,
          1500,
        );

        expect(
          result.maximumDrawdown!
              .troughEquity,
          1050,
        );

        expect(
          result.recoveredEpisodesCount,
          2,
        );
      },
    );

    test(
      'conserva el primer pico mientras no haya recuperación',
      () {
        final snapshots = [
          _snapshot(
            id: '1',
            date: DateTime(2026, 3, 1),
            equity: 1000,
          ),
          _snapshot(
            id: '2',
            date: DateTime(2026, 3, 2),
            equity: 1200,
          ),
          _snapshot(
            id: '3',
            date: DateTime(2026, 3, 3),
            equity: 1100,
          ),
          _snapshot(
            id: '4',
            date: DateTime(2026, 3, 4),
            equity: 1150,
          ),
          _snapshot(
            id: '5',
            date: DateTime(2026, 3, 5),
            equity: 1000,
          ),
        ];

        final result =
            DrawdownCalculator.calculate(
          snapshots,
        );

        final episode =
            result.episodes.first;

        expect(
          episode.peakDate,
          DateTime(2026, 3, 2),
        );

        expect(
          episode.troughDate,
          DateTime(2026, 3, 5),
        );

        expect(
          episode.drawdownPercent,
          closeTo(
            -16.6666667,
            0.0001,
          ),
        );

        expect(
          episode.isActive,
          isTrue,
        );
      },
    );
  });
}

PerformanceSnapshot _snapshot({
  required String id,
  required DateTime date,
  required double equity,
}) {
  return PerformanceSnapshot(
    id: id,
    recordedAt: date,
    cashBalance: equity,
    marketValue: 0,
    totalEquity: equity,
    netContributions: 0,
    investedCapital: 0,
    totalResult: 0,
  );
}