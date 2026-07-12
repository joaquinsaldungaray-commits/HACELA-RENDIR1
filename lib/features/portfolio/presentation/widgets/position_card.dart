import 'package:flutter/material.dart';
import 'package:hacela_rendir/core/design_system/app_spacing.dart';
import 'package:hacela_rendir/core/design_system/app_typography.dart';
import 'package:hacela_rendir/core/theme/app_theme.dart';
import 'package:hacela_rendir/features/portfolio/domain/portfolio_position.dart';

class PositionCard extends StatelessWidget {
  const PositionCard({
    required this.position,
    required this.portfolioTotal,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final PortfolioPosition position;
  final double portfolioTotal;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isPositive = position.profit >= 0;

    final resultColor =
        isPositive ? AppColors.primary : AppColors.danger;

    final weight = portfolioTotal == 0
        ? 0.0
        : position.currentValue / portfolioTotal * 100;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      position.ticker.substring(
                        0,
                        position.ticker.length > 2
                            ? 2
                            : position.ticker.length,
                      ),
                      style: AppTypography.labelLarge.copyWith(
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
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          position.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'USD ${position.currentValue.toStringAsFixed(2)}',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        '${isPositive ? '+' : ''}'
                        '${position.profitability.toStringAsFixed(2)}%',
                        style: AppTypography.labelLarge.copyWith(
                          color: resultColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  PopupMenuButton<String>(
                    tooltip: 'Acciones',
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: AppColors.textSecondary,
                    ),
                    color: AppColors.surfaceAlt,
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      }

                      if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              color: AppColors.textPrimary,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text('Editar posición'),
                          ],
                        ),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.danger,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text(
                              'Eliminar posición',
                              style: TextStyle(
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(
                color: AppColors.border,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _PositionDetail(
                      label: 'Cantidad',
                      value: position.quantity.toString(),
                    ),
                  ),
                  Expanded(
                    child: _PositionDetail(
                      label: 'Precio promedio',
                      value:
                          'USD ${position.averagePrice.toStringAsFixed(2)}',
                    ),
                  ),
                  Expanded(
                    child: _PositionDetail(
                      label: 'Precio actual',
                      value:
                          'USD ${position.currentPrice.toStringAsFixed(2)}',
                    ),
                  ),
                  Expanded(
                    child: _PositionDetail(
                      label: 'Peso',
                      value: '${weight.toStringAsFixed(2)}%',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PositionDetail extends StatelessWidget {
  const _PositionDetail({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}