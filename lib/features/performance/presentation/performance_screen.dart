import 'package:flutter/material.dart';
import 'package:hacela_rendir/core/design_system/app_spacing.dart';
import 'package:hacela_rendir/core/design_system/app_typography.dart';
import 'package:hacela_rendir/core/theme/app_theme.dart';
import 'package:hacela_rendir/features/performance/data/performance_repository.dart';
import 'package:hacela_rendir/features/performance/domain/drawdown_summary.dart';
import 'package:hacela_rendir/features/performance/domain/performance_analytics_summary.dart';
import 'package:hacela_rendir/features/performance/domain/performance_period.dart';
import 'package:hacela_rendir/features/performance/domain/performance_snapshot.dart';
import 'package:hacela_rendir/features/performance/domain/performance_summary.dart';
import 'package:hacela_rendir/features/performance/domain/yearly_return.dart';
import 'package:hacela_rendir/features/performance/presentation/widgets/drawdown_section.dart';
import 'package:hacela_rendir/features/performance/presentation/widgets/equity_history_chart.dart';
import 'package:hacela_rendir/features/performance/presentation/widgets/monthly_return_heatmap.dart';
import 'package:hacela_rendir/features/performance/presentation/widgets/performance_analytics_section.dart';
import 'package:hacela_rendir/features/performance/presentation/widgets/performance_metric_card.dart';
import 'package:hacela_rendir/features/performance/presentation/widgets/performance_period_selector.dart';
import 'package:hacela_rendir/features/performance/services/drawdown_calculator.dart';
import 'package:hacela_rendir/features/performance/services/performance_analytics_calculator.dart';
import 'package:hacela_rendir/features/performance/services/performance_calculator.dart';
import 'package:hacela_rendir/features/performance/services/periodic_return_calculator.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({
    super.key,
  });

  @override
  State<PerformanceScreen> createState() =>
      _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  final PerformanceRepository repository =
      PerformanceRepository();

  List<PerformanceSnapshot> allSnapshots = [];
  List<PerformanceSnapshot> filteredSnapshots = [];
  List<YearlyReturn> yearlyReturns = [];

  PerformanceSummary summary =
      PerformanceSummary.empty();

  PerformanceAnalyticsSummary analytics =
      PerformanceAnalyticsSummary.empty();

  DrawdownSummary drawdown =
      DrawdownSummary.empty();

  PerformancePeriod selectedPeriod =
      PerformancePeriod.all;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPerformance();
  }

  Future<void> loadPerformance() async {
    final snapshots =
        await repository.loadSnapshots();

    if (!mounted) {
      return;
    }

    allSnapshots = snapshots;
    isLoading = false;

    applyPeriod(
      selectedPeriod,
    );
  }

  void applyPeriod(
    PerformancePeriod period,
  ) {
    final filtered =
        PerformanceCalculator.filterByPeriod(
      snapshots: allSnapshots,
      period: period,
    );

    final calculatedSummary =
        PerformanceCalculator.calculate(
      filtered,
    );

    final calculatedAnalytics =
        PerformanceAnalyticsCalculator.calculate(
      snapshots: filtered,
    );

    final calculatedDrawdown =
        DrawdownCalculator.calculate(
      filtered,
    );

    final calculatedYearlyReturns =
        PeriodicReturnCalculator.calculateYearlyReturns(
      filtered,
    );

    setState(() {
      selectedPeriod = period;
      filteredSnapshots = filtered;
      summary = calculatedSummary;
      analytics = calculatedAnalytics;
      drawdown = calculatedDrawdown;
      yearlyReturns = calculatedYearlyReturns;
      isLoading = false;
    });
  }

  String formatSignedCurrency(
    double value,
  ) {
    return '${value >= 0 ? '+' : ''}'
        'USD ${value.toStringAsFixed(2)}';
  }

  String formatSignedPercent(
    double value,
  ) {
    return '${value >= 0 ? '+' : ''}'
        '${value.toStringAsFixed(2)}%';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final resultColor = summary.isPositive
        ? AppColors.primary
        : AppColors.danger;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Performance',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: loadPerformance,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadPerformance,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(
              AppSpacing.lg,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1100,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Análisis histórico',
                      style: AppTypography
                          .headlineLarge
                          .copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(
                      height: AppSpacing.xs,
                    ),
                    Text(
                      selectedPeriod.fullLabel,
                      style: AppTypography
                          .bodyLarge
                          .copyWith(
                        color:
                            AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(
                      height: AppSpacing.lg,
                    ),
                    PerformancePeriodSelector(
                      selectedPeriod:
                          selectedPeriod,
                      onChanged: applyPeriod,
                    ),
                    const SizedBox(
                      height: AppSpacing.lg,
                    ),
                    _PerformanceHeroCard(
                      summary: summary,
                      resultColor: resultColor,
                    ),
                    const SizedBox(
                      height: AppSpacing.lg,
                    ),
                    EquityHistoryChart(
                      snapshots:
                          filteredSnapshots,
                    ),
                    const SizedBox(
                      height: AppSpacing.xl,
                    ),
                    Text(
                      'Resumen del período',
                      style: AppTypography
                          .headlineMedium
                          .copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(
                      height: AppSpacing.md,
                    ),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      crossAxisSpacing:
                          AppSpacing.sm,
                      mainAxisSpacing:
                          AppSpacing.sm,
                      childAspectRatio: 1.65,
                      children: [
                        PerformanceMetricCard(
                          label:
                              'Performance absoluta',
                          value:
                              formatSignedCurrency(
                            summary
                                .absolutePerformance,
                          ),
                          icon:
                              Icons.trending_up_rounded,
                          valueColor: resultColor,
                        ),
                        PerformanceMetricCard(
                          label: 'Rentabilidad',
                          value:
                              formatSignedPercent(
                            summary.returnPercent,
                          ),
                          icon:
                              Icons.percent_rounded,
                          valueColor: resultColor,
                        ),
                        PerformanceMetricCard(
                          label: 'Pico patrimonial',
                          value:
                              'USD ${summary.peakEquity.toStringAsFixed(2)}',
                          icon:
                              Icons.landscape_outlined,
                        ),
                        PerformanceMetricCard(
                          label: 'Mínimo patrimonial',
                          value:
                              'USD ${summary.lowestEquity.toStringAsFixed(2)}',
                          icon:
                              Icons.low_priority_rounded,
                        ),
                        PerformanceMetricCard(
                          label: 'Mejor período',
                          value:
                              formatSignedPercent(
                            summary
                                .bestPeriodReturnPercent,
                          ),
                          icon:
                              Icons.arrow_upward_rounded,
                          valueColor:
                              AppColors.primary,
                        ),
                        PerformanceMetricCard(
                          label: 'Peor período',
                          value:
                              formatSignedPercent(
                            summary
                                .worstPeriodReturnPercent,
                          ),
                          icon:
                              Icons.arrow_downward_rounded,
                          valueColor:
                              summary.worstPeriodReturnPercent <
                                      0
                                  ? AppColors.danger
                                  : AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: AppSpacing.xl,
                    ),
                    PerformanceAnalyticsSection(
                      analytics: analytics,
                    ),
                    const SizedBox(
                      height: AppSpacing.xl,
                    ),
                    DrawdownSection(
                      summary: drawdown,
                    ),
                    const SizedBox(
                      height: AppSpacing.xl,
                    ),
                    MonthlyReturnHeatmap(
                      yearlyReturns:
                          yearlyReturns,
                    ),
                    const SizedBox(
                      height: AppSpacing.xl,
                    ),
                    _PerformanceDetailsCard(
                      summary: summary,
                    ),
                    const SizedBox(
                      height: AppSpacing.xxxl,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PerformanceHeroCard extends StatelessWidget {
  const _PerformanceHeroCard({
    required this.summary,
    required this.resultColor,
  });

  final PerformanceSummary summary;
  final Color resultColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color: resultColor.withValues(
            alpha: 0.35,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Patrimonio actual',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(
            height: AppSpacing.xs,
          ),
          Text(
            'USD ${summary.endEquity.toStringAsFixed(2)}',
            style:
                AppTypography.displayMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(
            height: AppSpacing.md,
          ),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              Text(
                '${summary.absolutePerformance >= 0 ? '+' : ''}'
                'USD ${summary.absolutePerformance.toStringAsFixed(2)}',
                style:
                    AppTypography.titleMedium.copyWith(
                  color: resultColor,
                ),
              ),
              Text(
                '${summary.returnPercent >= 0 ? '+' : ''}'
                '${summary.returnPercent.toStringAsFixed(2)}%',
                style:
                    AppTypography.titleMedium.copyWith(
                  color: resultColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PerformanceDetailsCard extends StatelessWidget {
  const _PerformanceDetailsCard({
    required this.summary,
  });

  final PerformanceSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          _PerformanceDetailRow(
            label: 'Patrimonio inicial',
            value:
                'USD ${summary.startEquity.toStringAsFixed(2)}',
          ),
          const Divider(
            color: AppColors.border,
          ),
          _PerformanceDetailRow(
            label: 'Patrimonio final',
            value:
                'USD ${summary.endEquity.toStringAsFixed(2)}',
          ),
          const Divider(
            color: AppColors.border,
          ),
          _PerformanceDetailRow(
            label: 'Aportes netos',
            value:
                'USD ${summary.netContributions.toStringAsFixed(2)}',
          ),
          const Divider(
            color: AppColors.border,
          ),
          _PerformanceDetailRow(
            label: 'Cantidad de registros',
            value:
                '${summary.observationsCount}',
          ),
        ],
      ),
    );
  }
}

class _PerformanceDetailRow extends StatelessWidget {
  const _PerformanceDetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(
            width: AppSpacing.md,
          ),
          Text(
            value,
            style:
                AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}