import 'package:flutter/material.dart';
import 'package:hacela_rendir/core/design_system/app_spacing.dart';
import 'package:hacela_rendir/core/design_system/app_typography.dart';
import 'package:hacela_rendir/core/finance/models/portfolio_distribution.dart';
import 'package:hacela_rendir/core/theme/app_theme.dart';

enum DistributionView {
  sector,
  country,
  currency,
  assetType,
}

class PortfolioDistributionSection extends StatefulWidget {
  const PortfolioDistributionSection({
    required this.distribution,
    super.key,
  });

  final PortfolioDistribution distribution;

  @override
  State<PortfolioDistributionSection> createState() =>
      _PortfolioDistributionSectionState();
}

class _PortfolioDistributionSectionState
    extends State<PortfolioDistributionSection> {
  DistributionView selectedView = DistributionView.sector;

  List<DistributionItem> get selectedItems {
    return switch (selectedView) {
      DistributionView.sector => widget.distribution.bySector,
      DistributionView.country => widget.distribution.byCountry,
      DistributionView.currency => widget.distribution.byCurrency,
      DistributionView.assetType => widget.distribution.byAssetType,
    };
  }

  String get selectedTitle {
    return switch (selectedView) {
      DistributionView.sector => 'Sectores',
      DistributionView.country => 'Países',
      DistributionView.currency => 'Monedas',
      DistributionView.assetType => 'Tipos de activo',
    };
  }

  @override
  Widget build(BuildContext context) {
    final items = selectedItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribución de cartera',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<DistributionView>(
            segments: const [
              ButtonSegment<DistributionView>(
                value: DistributionView.sector,
                label: Text('Sector'),
                icon: Icon(Icons.pie_chart_outline_rounded),
              ),
              ButtonSegment<DistributionView>(
                value: DistributionView.country,
                label: Text('País'),
                icon: Icon(Icons.public_rounded),
              ),
              ButtonSegment<DistributionView>(
                value: DistributionView.currency,
                label: Text('Moneda'),
                icon: Icon(Icons.currency_exchange_rounded),
              ),
              ButtonSegment<DistributionView>(
                value: DistributionView.assetType,
                label: Text('Tipo'),
                icon: Icon(Icons.category_outlined),
              ),
            ],
            selected: {
              selectedView,
            },
            showSelectedIcon: false,
            onSelectionChanged: (selection) {
              setState(() {
                selectedView = selection.first;
              });
            },
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
          child: items.isEmpty
              ? const _EmptyDistribution()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedTitle,
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    for (var index = 0;
                        index < items.length;
                        index++) ...[
                      _DistributionRow(
                        item: items[index],
                      ),
                      if (index < items.length - 1)
                        const SizedBox(height: AppSpacing.lg),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _DistributionRow extends StatelessWidget {
  const _DistributionRow({
    required this.item,
  });

  final DistributionItem item;

  @override
  Widget build(BuildContext context) {
    final normalizedProgress =
        (item.weightPercent / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              '${item.weightPercent.toStringAsFixed(2)}%',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: normalizedProgress,
            minHeight: 10,
            backgroundColor: AppColors.surfaceAlt,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'USD ${item.value.toStringAsFixed(2)}',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _EmptyDistribution extends StatelessWidget {
  const _EmptyDistribution();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.donut_large_outlined,
            size: 44,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No hay datos para distribuir',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Registrá compras para generar la composición de la cartera.',
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