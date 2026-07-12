import 'package:flutter/material.dart';
import 'package:hacela_rendir/core/design_system/app_spacing.dart';
import 'package:hacela_rendir/core/design_system/app_typography.dart';
import 'package:hacela_rendir/core/theme/app_theme.dart';
import 'package:hacela_rendir/features/portfolio/domain/portfolio_position.dart';

class PositionDetailScreen extends StatelessWidget {
  const PositionDetailScreen({
    required this.position,
    super.key,
  });

  final PortfolioPosition position;

  @override
  Widget build(BuildContext context) {
    final isPositive = position.profit >= 0;

    final resultColor =
        isPositive ? AppColors.primary : AppColors.danger;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          position.ticker,
          style: const TextStyle(
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
                  _PositionHeader(
                    position: position,
                    resultColor: resultColor,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _PositionResultCard(
                    position: position,
                    resultColor: resultColor,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Información de la posición',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1.7,
                    children: [
                      _DetailMetric(
                        label: 'Cantidad',
                        value: position.quantity.toString(),
                        icon: Icons.layers_outlined,
                      ),
                      _DetailMetric(
                        label: 'Precio promedio',
                        value:
                            'USD ${position.averagePrice.toStringAsFixed(2)}',
                        icon: Icons.price_check_outlined,
                      ),
                      _DetailMetric(
                        label: 'Precio actual',
                        value:
                            'USD ${position.currentPrice.toStringAsFixed(2)}',
                        icon: Icons.show_chart_rounded,
                      ),
                      _DetailMetric(
                        label: 'Capital invertido',
                        value:
                            'USD ${position.invested.toStringAsFixed(2)}',
                        icon: Icons.savings_outlined,
                      ),
                      _DetailMetric(
                        label: 'Valor de mercado',
                        value:
                            'USD ${position.currentValue.toStringAsFixed(2)}',
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                      _DetailMetric(
                        label: 'Rentabilidad',
                        value:
                            '${isPositive ? '+' : ''}'
                            '${position.profitability.toStringAsFixed(2)}%',
                        icon: isPositive
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        valueColor: resultColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Gráfico de evolución',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _ChartPlaceholder(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PositionHeader extends StatelessWidget {
  const _PositionHeader({
    required this.position,
    required this.resultColor,
  });

  final PortfolioPosition position;
  final Color resultColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            position.ticker.substring(
              0,
              position.ticker.length > 2
                  ? 2
                  : position.ticker.length,
            ),
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                position.ticker,
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                position.name,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${position.profit >= 0 ? '+' : ''}'
          '${position.profitability.toStringAsFixed(2)}%',
          style: AppTypography.titleLarge.copyWith(
            color: resultColor,
          ),
        ),
      ],
    );
  }
}

class _PositionResultCard extends StatelessWidget {
  const _PositionResultCard({
    required this.position,
    required this.resultColor,
  });

  final PortfolioPosition position;
  final Color resultColor;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Resultado no realizado',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${position.profit >= 0 ? '+' : ''}'
            'USD ${position.profit.toStringAsFixed(2)}',
            style: AppTypography.displayMedium.copyWith(
              color: resultColor,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Valor actual: '
            'USD ${position.currentValue.toStringAsFixed(2)}',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: valueColor ?? AppColors.primary,
          ),
          const Spacer(),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.area_chart_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'El gráfico histórico se incorporará\ncon los datos de mercado.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}