import 'package:hacela_rendir/features/performance/domain/drawdown_episode.dart';
import 'package:hacela_rendir/features/performance/domain/drawdown_summary.dart';
import 'package:hacela_rendir/features/performance/domain/performance_snapshot.dart';

abstract final class DrawdownCalculator {
  static DrawdownSummary calculate(
    List<PerformanceSnapshot> snapshots,
  ) {
    if (snapshots.isEmpty) {
      return DrawdownSummary.empty();
    }

    final orderedSnapshots =
        List<PerformanceSnapshot>.from(
      snapshots,
    )..sort(
            (first, second) =>
                first.recordedAt.compareTo(
              second.recordedAt,
            ),
          );

    var currentPeakEquity =
        orderedSnapshots.first.totalEquity;

    var currentPeakDate =
        orderedSnapshots.first.recordedAt;

    DateTime? activePeakDate;
    DateTime? activeTroughDate;

    var activePeakEquity = 0.0;
    var activeTroughEquity = 0.0;
    var activeDrawdownPercent = 0.0;

    final episodes = <DrawdownEpisode>[];

    for (var index = 1;
        index < orderedSnapshots.length;
        index++) {
      final snapshot = orderedSnapshots[index];

      if (snapshot.totalEquity >= currentPeakEquity) {
        if (activePeakDate != null &&
            activeTroughDate != null) {
          episodes.add(
            DrawdownEpisode(
              peakDate: activePeakDate,
              troughDate: activeTroughDate,
              recoveryDate: snapshot.recordedAt,
              peakEquity: activePeakEquity,
              troughEquity: activeTroughEquity,
              drawdownPercent:
                  activeDrawdownPercent,
              daysToTrough: activeTroughDate
                  .difference(activePeakDate)
                  .inDays,
              durationDays: snapshot.recordedAt
                  .difference(activePeakDate)
                  .inDays,
            ),
          );
        }

        currentPeakEquity =
            snapshot.totalEquity;

        currentPeakDate =
            snapshot.recordedAt;

        activePeakDate = null;
        activeTroughDate = null;
        activePeakEquity = 0;
        activeTroughEquity = 0;
        activeDrawdownPercent = 0;

        continue;
      }

      if (currentPeakEquity <= 0) {
        continue;
      }

      final drawdownPercent =
          (snapshot.totalEquity -
                  currentPeakEquity) /
              currentPeakEquity *
              100;

      if (activePeakDate == null) {
        activePeakDate = currentPeakDate;
        activeTroughDate =
            snapshot.recordedAt;
        activePeakEquity =
            currentPeakEquity;
        activeTroughEquity =
            snapshot.totalEquity;
        activeDrawdownPercent =
            drawdownPercent;

        continue;
      }

      if (drawdownPercent <
          activeDrawdownPercent) {
        activeTroughDate =
            snapshot.recordedAt;
        activeTroughEquity =
            snapshot.totalEquity;
        activeDrawdownPercent =
            drawdownPercent;
      }
    }

    final lastSnapshot =
        orderedSnapshots.last;

    if (activePeakDate != null &&
        activeTroughDate != null) {
      episodes.add(
        DrawdownEpisode(
          peakDate: activePeakDate,
          troughDate: activeTroughDate,
          recoveryDate: null,
          peakEquity: activePeakEquity,
          troughEquity: activeTroughEquity,
          drawdownPercent:
              activeDrawdownPercent,
          daysToTrough: activeTroughDate
              .difference(activePeakDate)
              .inDays,
          durationDays: lastSnapshot.recordedAt
              .difference(activePeakDate)
              .inDays,
        ),
      );
    }

    DrawdownEpisode? maximumDrawdown;

    for (final episode in episodes) {
      if (maximumDrawdown == null ||
          episode.drawdownPercent <
              maximumDrawdown.drawdownPercent) {
        maximumDrawdown = episode;
      }
    }

    final currentDrawdownPercent =
        currentPeakEquity <= 0
            ? 0.0
            : (lastSnapshot.totalEquity -
                        currentPeakEquity) /
                    currentPeakEquity *
                100;

    final currentDrawdownDurationDays =
        currentDrawdownPercent < 0
            ? lastSnapshot.recordedAt
                .difference(currentPeakDate)
                .inDays
            : 0;

    return DrawdownSummary(
      currentDrawdownPercent:
          currentDrawdownPercent,
      currentPeakEquity:
          currentPeakEquity,
      currentPeakDate:
          currentPeakDate,
      currentDrawdownDurationDays:
          currentDrawdownDurationDays,
      maximumDrawdown:
          maximumDrawdown,
      episodes:
          List<DrawdownEpisode>.unmodifiable(
        episodes,
      ),
    );
  }
}