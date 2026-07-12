import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hacela_rendir/app/router/app_routes.dart';
import 'package:hacela_rendir/core/design_system/app_spacing.dart';
import 'package:hacela_rendir/core/design_system/app_typography.dart';
import 'package:hacela_rendir/core/finance/calculations/portfolio_calculator.dart';
import 'package:hacela_rendir/core/theme/app_theme.dart';
import 'package:hacela_rendir/features/portfolio/data/demo_portfolio_data.dart';
import 'package:hacela_rendir/features/portfolio/data/portfolio_repository.dart';
import 'package:hacela_rendir/features/portfolio/domain/portfolio_position.dart';
import 'package:hacela_rendir/features/portfolio/presentation/widgets/add_position_dialog.dart';
import 'package:hacela_rendir/features/portfolio/presentation/widgets/edit_position_dialog.dart';
import 'package:hacela_rendir/features/portfolio/presentation/widgets/position_card.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final PortfolioRepository repository = PortfolioRepository();

  List<PortfolioPosition> positions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPositions();
  }

  Future<void> loadPositions() async {
    final savedPositions = await repository.loadPositions();

    if (!mounted) {
      return;
    }

    setState(() {
      positions = savedPositions.isEmpty
          ? List<PortfolioPosition>.from(demoPortfolioPositions)
          : savedPositions;

      isLoading = false;
    });
  }

  Future<void> addPosition() async {
    final newPosition = await showDialog<PortfolioPosition>(
      context: context,
      builder: (dialogContext) {
        return const AddPositionDialog();
      },
    );

    if (newPosition == null || !mounted) {
      return;
    }

    setState(() {
      positions.add(newPosition);
    });

    await repository.savePositions(positions);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${newPosition.ticker} fue agregado a la cartera.',
        ),
      ),
    );
  }

  Future<void> editPosition(
    PortfolioPosition position,
  ) async {
    final updatedPosition = await showDialog<PortfolioPosition>(
      context: context,
      builder: (dialogContext) {
        return EditPositionDialog(
          position: position,
        );
      },
    );

    if (updatedPosition == null || !mounted) {
      return;
    }

    final positionIndex = positions.indexOf(position);

    if (positionIndex == -1) {
      return;
    }

    setState(() {
      positions[positionIndex] = updatedPosition;
    });

    await repository.savePositions(positions);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${updatedPosition.ticker} fue actualizado.',
        ),
      ),
    );
  }

  Future<void> deletePosition(
    PortfolioPosition position,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Eliminar posición',
          ),
          content: Text(
            '¿Querés eliminar ${position.ticker} de tu cartera?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Cancelar',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Eliminar',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      positions.remove(position);
    });

    await repository.savePositions(positions);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${position.ticker} fue eliminado de la cartera.',
        ),
      ),
    );
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

    final metrics = PortfolioCalculator.calculate(
      positions,
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
        actions: [
          IconButton(
            tooltip: 'Agregar posición',
            onPressed: addPosition,
            icon: const Icon(
              Icons.add_rounded,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addPosition,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Agregar posición',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            AppSpacing.lg,
          ),
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
                  const SizedBox(
                    height: AppSpacing.md,
                  ),
                  Container(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Valor de mercado',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(
                          height: AppSpacing.xs,
                        ),
                        Text(
                          'USD ${metrics.marketValue.toStringAsFixed(2)}',
                          style: AppTypography.displayMedium.copyWith(
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
                        const SizedBox(
                          height: AppSpacing.lg,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryMetric(
                                label: 'Capital invertido',
                                value:
                                    'USD ${metrics.investedValue.toStringAsFixed(2)}',
                              ),
                            ),
                            const SizedBox(
                              width: AppSpacing.sm,
                            ),
                            Expanded(
                              child: _SummaryMetric(
                                label: 'Posiciones',
                                value: '${metrics.positionsCount}',
                              ),
                            ),
                            const SizedBox(
                              width: AppSpacing.sm,
                            ),
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
                  const SizedBox(
                    height: AppSpacing.xl,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Posiciones',
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${positions.length} activos',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: AppSpacing.md,
                  ),
                  if (positions.isEmpty)
                    const _EmptyPortfolio()
                  else
                    for (final position in positions) ...[
                      PositionCard(
                        position: position,
                        portfolioTotal: metrics.marketValue,
                        onEdit: () {
                          editPosition(position);
                        },
                        onDelete: () {
                          deletePosition(position);
                        },
                      ),
                      const SizedBox(
                        height: AppSpacing.sm,
                      ),
                    ],
                  const SizedBox(
                    height: AppSpacing.xxxl,
                  ),
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
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(
          14,
        ),
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
          const SizedBox(
            height: AppSpacing.xs,
          ),
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

class _EmptyPortfolio extends StatelessWidget {
  const _EmptyPortfolio();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(
            height: AppSpacing.md,
          ),
          Text(
            'Todavía no hay posiciones',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(
            height: AppSpacing.xs,
          ),
          Text(
            'Agregá tu primera inversión para comenzar.',
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