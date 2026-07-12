import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hacela_rendir/app/router/app_routes.dart';
import 'package:hacela_rendir/core/design_system/app_spacing.dart';
import 'package:hacela_rendir/core/design_system/app_typography.dart';
import 'package:hacela_rendir/core/finance/calculations/portfolio_calculator.dart';
import 'package:hacela_rendir/core/theme/app_theme.dart';
import 'package:hacela_rendir/features/portfolio/data/demo_portfolio_data.dart';
import 'package:hacela_rendir/features/portfolio/presentation/widgets/position_card.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = PortfolioCalculator.calculate(
      demoPortfolioPositions,
    );

    final resultColor = metrics.isPositive
        ? AppColors.primary
        : AppColors.danger;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver al dashboard',
          onPressed: () {
            context.go(AppRoutes.dashboard);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),
        title: const Text(
          'Mi cartera',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 900,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen',
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.border,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Valor de mercado',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'USD ${metrics.marketValue.toStringAsFixed(2)}',
                          style: AppTypography.displayMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: AppSpacing.sm,
                          children: [
                            Text(
                              '${metrics.profitLoss >= 0 ? '+' : ''}'
                              'USD ${metrics.profitLoss.toStringAsFixed(2)}',
                              style: AppTypography.titleMedium.copyWith(
                                color: resultColor,
                              ),
                            ),
                            Text(
                              '${metrics.returnPercent >= 0 ? '+' : ''}'
                              '${metrics.returnPercent.toStringAsFixed(2)}%',
                              style: AppTypography.titleMedium.copyWith(
                                color: resultColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryMetric(
                                label: 'Capital invertido',
                                value:
                                    'USD ${metrics.investedValue.toStringAsFixed(2)}',
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _SummaryMetric(
                                label: 'Posiciones',
                                value: '${metrics.positionsCount}',
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _SummaryMetric(
                                label: 'Mayor concentración',
                                value:
                                    '${metrics.largestPositionWeight.toStringAsFixed(2)}%',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Posiciones',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final position in demoPortfolioPositions) ...[
                    PositionCard(
                      position: position,
                      portfolioTotal: metrics.marketValue,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}