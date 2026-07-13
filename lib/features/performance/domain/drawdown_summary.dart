import 'package:hacela_rendir/features/performance/domain/drawdown_episode.dart';

class DrawdownSummary {
  const DrawdownSummary({
    required this.currentDrawdownPercent,
    required this.currentPeakEquity,
    required this.currentPeakDate,
    required this.currentDrawdownDurationDays,
    required this.maximumDrawdown,
    required this.episodes,
  });

  final double currentDrawdownPercent;
  final double currentPeakEquity;
  final DateTime? currentPeakDate;
  final int currentDrawdownDurationDays;

  final DrawdownEpisode? maximumDrawdown;
  final List<DrawdownEpisode> episodes;

  bool get isInDrawdown => currentDrawdownPercent < 0;

  double get maximumDrawdownPercent {
    return maximumDrawdown?.drawdownPercent ?? 0;
  }

  int get episodesCount => episodes.length;

  int get recoveredEpisodesCount {
    return episodes
        .where(
          (episode) => episode.isRecovered,
        )
        .length;
  }

  int get activeEpisodesCount {
    return episodes
        .where(
          (episode) => episode.isActive,
        )
        .length;
  }

  factory DrawdownSummary.empty() {
    return const DrawdownSummary(
      currentDrawdownPercent: 0,
      currentPeakEquity: 0,
      currentPeakDate: null,
      currentDrawdownDurationDays: 0,
      maximumDrawdown: null,
      episodes: [],
    );
  }
}