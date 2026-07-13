import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hacela_rendir/app/router/app_routes.dart';
import 'package:hacela_rendir/core/design_system/app_spacing.dart';
import 'package:hacela_rendir/core/design_system/app_typography.dart';
import 'package:hacela_rendir/core/finance/engine/financial_engine.dart';
import 'package:hacela_rendir/core/theme/app_theme.dart';
import 'package:hacela_rendir/features/portfolio/domain/portfolio_position.dart';
import 'package:hacela_rendir/features/portfolio/presentation/widgets/portfolio_distribution_section.dart';
import 'package:hacela_rendir/features/portfolio/presentation/widgets/position_card.dart';
import 'package:hacela_rendir/features/portfolio/services/portfolio_sync_service.dart';
import 'package:hacela_rendir/features/transactions/data/transaction_repository.dart';
import 'package:hacela_rendir/features/transactions/domain/portfolio_transaction.dart';
import 'package:hacela_rendir/features/transactions/presentation/widgets/add_transaction_dialog.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final PortfolioSyncService portfolioSyncService =
      PortfolioSyncService();

  final TransactionRepository transactionRepository =
      TransactionRepository();

  List<PortfolioPosition> positions = [];
  List<PortfolioTransaction> transactions = [];

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadPortfolio();
  }

  Future<void> loadPortfolio() async {
    try {
      final loadedTransactions =
          await transactionRepository.loadTransactions();

      final synchronizedPositions =
          await portfolioSyncService.syncFromTransactions();

      if (!mounted) {
        return;
      }

      setState(() {
        transactions = loadedTransactions;
        positions = synchronizedPositions;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      showMessage(
        'No se pudo cargar la cartera.',
        isError: true,
      );
    }
  }

  Future<void> registerPurchase() async {
    final transaction =
        await showDialog<PortfolioTransaction>(
      context: context,
      builder: (dialogContext) {
        return const AddTransactionDialog();
      },
    );

    if (transaction == null || !mounted) {
      return;
    }

    if (transaction.type != TransactionType.buy) {
      showMessage(
        'Desde este botón debés registrar una compra.',
        isError: true,
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final updatedTransactions = [
        transaction,
        ...transactions,
      ];

      await transactionRepository.saveTransactions(
        updatedTransactions,
      );

      final synchronizedPositions =
          await portfolioSyncService.syncFromTransactions();

      if (!mounted) {
        return;
      }

      setState(() {
        transactions = updatedTransactions;
        positions = synchronizedPositions;
        isSaving = false;
      });

      showMessage(
        '${transaction.ticker} fue incorporado mediante una compra.',
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
      });

      showMessage(
        'No se pudo registrar la compra.',
        isError: true,
      );
    }
  }

  Future<void> openTransactions() async {
    await context.push(
      AppRoutes.transactions,
    );

    if (!mounted) {
      return;
    }

    await loadPortfolio();
  }

  void openPositionDetail(
    PortfolioPosition position,
  ) {
    context.push(
      AppRoutes.positionDetail,
      extra: position,
    );
  }

  void showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? AppColors.danger : null,
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

    final snapshot = FinancialEngine.calculateFromData(
      transactions: transactions,
      positions: positions,
    );

    final resultColor = snapshot.isPositive
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
            tooltip: 'Movimientos',
            onPressed: isSaving
                ? null
                : openTransactions,
            icon: const Icon(
              Icons.receipt_long_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Registrar compra',
            onPressed: isSaving
                ? null
                : registerPurchase,
            icon: const Icon(
              Icons.add_shopping_cart_rounded,
            ),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: isSaving
            ? null
            : registerPurchase,
        icon: isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons.add_shopping_cart_rounded,
              ),
        label: Text(
          isSaving
              ? 'Guardando...'
              : 'Registrar compra',
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadPortfolio,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(
              AppSpacing.lg,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 900,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen',
                      style: AppTypography
                          .headlineLarge
                          .copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(
                      height: AppSpacing.md,
                    ),
                    _PortfolioSummaryCard(
                      marketValue: snapshot.marketValue,
                      investedCapital:
                          snapshot.investedCapital,
                      profitLoss:
                          snapshot.unrealizedProfit,
                      returnPercent:
                          snapshot.returnPercent,
                      positionsCount:
                          snapshot.positionsCount,
                      resultColor: resultColor,
                      largestPositionWeight:
                          _largestPositionWeight(
                        positions,
                        snapshot.marketValue,
                      ),
                    ),
                    const SizedBox(
                      height: AppSpacing.xl,
                    ),
                    PortfolioDistributionSection(
                      distribution:
                          snapshot.distribution,
                    ),
                    const SizedBox(
                      height: AppSpacing.xl,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Posiciones',
                            style: AppTypography
                                .headlineMedium
                                .copyWith(
                              color:
                                  AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          '${positions.length} activos',
                          style: AppTypography
                              .bodyMedium
                              .copyWith(
                            color:
                                AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: AppSpacing.md,
                    ),
                    if (positions.isEmpty)
                      _EmptyPortfolio(
                        onRegisterPurchase:
                            registerPurchase,
                      )
                    else
                      for (final position
                          in positions) ...[
                        PositionCard(
                          position: position,
                          portfolioTotal:
                              snapshot.marketValue,
                          onTap: () {
                            openPositionDetail(
                              position,
                            );
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
      ),
    );
  }

  double _largestPositionWeight(
    List<PortfolioPosition> positions,
    double marketValue,
  ) {
    if (positions.isEmpty || marketValue == 0) {
      return 0;
    }

    var largestValue = 0.0;

    for (final position in positions) {
      if (position.currentValue > largestValue) {
        largestValue = position.currentValue;
      }
    }

    return largestValue / marketValue * 100;
  }
}

class _PortfolioSummaryCard extends StatelessWidget {
  const _PortfolioSummaryCard({
    required this.marketValue,
    required this.investedCapital,
    required this.profitLoss,
    required this.returnPercent,
    required this.positionsCount,
    required this.resultColor,
    required this.largestPositionWeight,
  });

  final double marketValue;
  final double investedCapital;
  final double profitLoss;
  final double returnPercent;
  final int positionsCount;
  final Color resultColor;
  final double largestPositionWeight;

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
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
            'USD ${marketValue.toStringAsFixed(2)}',
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
                '${profitLoss >= 0 ? '+' : ''}'
                'USD ${profitLoss.toStringAsFixed(2)}',
                style:
                    AppTypography.titleMedium.copyWith(
                  color: resultColor,
                ),
              ),
              Text(
                '${returnPercent >= 0 ? '+' : ''}'
                '${returnPercent.toStringAsFixed(2)}%',
                style:
                    AppTypography.titleMedium.copyWith(
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
                      'USD ${investedCapital.toStringAsFixed(2)}',
                ),
              ),
              const SizedBox(
                width: AppSpacing.sm,
              ),
              Expanded(
                child: _SummaryMetric(
                  label: 'Posiciones',
                  value: '$positionsCount',
                ),
              ),
              const SizedBox(
                width: AppSpacing.sm,
              ),
              Expanded(
                child: _SummaryMetric(
                  label: 'Mayor concentración',
                  value:
                      '${largestPositionWeight.toStringAsFixed(2)}%',
                ),
              ),
            ],
          ),
        ],
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
  const _EmptyPortfolio({
    required this.onRegisterPurchase,
  });

  final VoidCallback onRegisterPurchase;

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
            'Registrá tu primera compra para comenzar.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(
            height: AppSpacing.lg,
          ),
          FilledButton.icon(
            onPressed: onRegisterPurchase,
            icon: const Icon(
              Icons.add_shopping_cart_rounded,
            ),
            label: const Text(
              'Registrar compra',
            ),
          ),
        ],
      ),
    );
  }
}