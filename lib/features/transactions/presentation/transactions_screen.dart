import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hacela_rendir/app/router/app_routes.dart';
import 'package:hacela_rendir/core/design_system/app_spacing.dart';
import 'package:hacela_rendir/core/design_system/app_typography.dart';
import 'package:hacela_rendir/core/finance/engine/financial_engine.dart';
import 'package:hacela_rendir/core/theme/app_theme.dart';
import 'package:hacela_rendir/features/portfolio/domain/portfolio_position.dart';
import 'package:hacela_rendir/features/portfolio/services/portfolio_sync_service.dart';
import 'package:hacela_rendir/features/transactions/data/transaction_repository.dart';
import 'package:hacela_rendir/features/transactions/domain/portfolio_transaction.dart';
import 'package:hacela_rendir/features/transactions/presentation/widgets/add_transaction_dialog.dart';
import 'package:hacela_rendir/features/transactions/presentation/widgets/transaction_card.dart';
import 'package:hacela_rendir/features/transactions/services/transaction_calculator.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TransactionRepository repository = TransactionRepository();

  final PortfolioSyncService portfolioSyncService =
      PortfolioSyncService();

  List<PortfolioTransaction> transactions = [];
  List<PortfolioPosition> openPositions = [];

  bool isLoading = true;
  bool isSynchronizing = false;

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      final loadedTransactions =
          await repository.loadTransactions();

      final calculatedPositions =
          await portfolioSyncService.syncFromTransactions();

      if (!mounted) {
        return;
      }

      setState(() {
        transactions = loadedTransactions;
        openPositions = calculatedPositions;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      showErrorMessage(
        'No se pudieron cargar los movimientos.',
      );
    }
  }

  Future<List<PortfolioPosition>> synchronizePortfolio() async {
    if (mounted) {
      setState(() {
        isSynchronizing = true;
      });
    }

    try {
      return await portfolioSyncService.syncFromTransactions();
    } finally {
      if (mounted) {
        setState(() {
          isSynchronizing = false;
        });
      }
    }
  }

  Future<void> addTransaction() async {
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

    final updatedTransactions = [
      transaction,
      ...transactions,
    ];

    try {
      await repository.saveTransactions(
        updatedTransactions,
      );

      final updatedPositions =
          await synchronizePortfolio();

      if (!mounted) {
        return;
      }

      setState(() {
        transactions = updatedTransactions;
        openPositions = updatedPositions;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Movimiento registrado y cartera actualizada.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      showErrorMessage(
        'No se pudo registrar el movimiento.',
      );
    }
  }

  Future<void> deleteTransaction(
    PortfolioTransaction transaction,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Eliminar movimiento',
          ),
          content: Text(
            '¿Querés eliminar este movimiento de '
            '${transaction.ticker ?? transactionTypeLabel(transaction.type)}?',
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
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
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

    final updatedTransactions = transactions
        .where(
          (item) => item.id != transaction.id,
        )
        .toList();

    try {
      await repository.saveTransactions(
        updatedTransactions,
      );

      final updatedPositions =
          await synchronizePortfolio();

      if (!mounted) {
        return;
      }

      setState(() {
        transactions = updatedTransactions;
        openPositions = updatedPositions;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Movimiento eliminado y cartera recalculada.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      showErrorMessage(
        'No se pudo eliminar el movimiento.',
      );
    }
  }

  String transactionTypeLabel(
    TransactionType type,
  ) {
    return switch (type) {
      TransactionType.buy => 'Compra',
      TransactionType.sell => 'Venta',
      TransactionType.dividend => 'Dividendo',
      TransactionType.fee => 'Comisión',
      TransactionType.deposit => 'Depósito',
      TransactionType.withdrawal => 'Retiro',
    };
  }

  void showErrorMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
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

    final transactionSummary =
        TransactionCalculator.calculate(
      transactions,
    );

    final snapshot = FinancialEngine.calculateFromData(
      transactions: transactions,
      positions: openPositions,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver a la cartera',
          onPressed: () {
            context.go(AppRoutes.portfolio);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),
        title: const Text(
          'Movimientos',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (isSynchronizing)
            const Padding(
              padding: EdgeInsets.only(
                right: AppSpacing.md,
              ),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Nuevo movimiento',
            onPressed: isSynchronizing
                ? null
                : addTransaction,
            icon: const Icon(
              Icons.add_rounded,
            ),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: isSynchronizing
            ? null
            : addTransaction,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Nuevo movimiento',
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patrimonio',
                    style:
                        AppTypography.headlineLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(
                    height: AppSpacing.md,
                  ),
                  _EquityCard(
                    totalEquity: snapshot.totalEquity,
                    cashBalance: snapshot.cashBalance,
                    marketValue: snapshot.marketValue,
                  ),
                  const SizedBox(
                    height: AppSpacing.xl,
                  ),
                  Text(
                    'Resultado de inversiones',
                    style:
                        AppTypography.headlineMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(
                    height: AppSpacing.md,
                  ),
                  _TotalResultCard(
                    totalResult: snapshot.totalResult,
                    returnPercent: snapshot.returnPercent,
                  ),
                  const SizedBox(
                    height: AppSpacing.md,
                  ),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1.8,
                    children: [
                      _ResultMetricCard(
                        label: 'Resultado realizado',
                        value: snapshot.realizedProfit,
                        icon: Icons.task_alt_rounded,
                      ),
                      _ResultMetricCard(
                        label: 'Resultado no realizado',
                        value: snapshot.unrealizedProfit,
                        icon: Icons.show_chart_rounded,
                      ),
                      _ResultMetricCard(
                        label: 'Dividendos',
                        value: snapshot.dividends,
                        icon: Icons.payments_outlined,
                      ),
                      _ResultMetricCard(
                        label: 'Comisiones',
                        value: -snapshot.fees,
                        icon: Icons.receipt_long_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: AppSpacing.xl,
                  ),
                  Text(
                    'Actividad de la cuenta',
                    style:
                        AppTypography.headlineMedium.copyWith(
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
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1.8,
                    children: [
                      _ActivityMetricCard(
                        label: 'Compras',
                        value:
                            transactionSummary.totalPurchases,
                        icon:
                            Icons.add_shopping_cart_rounded,
                      ),
                      _ActivityMetricCard(
                        label: 'Ventas',
                        value: transactionSummary.totalSales,
                        icon: Icons.sell_outlined,
                      ),
                      _ActivityMetricCard(
                        label: 'Depósitos',
                        value:
                            transactionSummary.totalDeposits,
                        icon: Icons.south_west_rounded,
                      ),
                      _ActivityMetricCard(
                        label: 'Retiros',
                        value:
                            transactionSummary.totalWithdrawals,
                        icon: Icons.north_east_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: AppSpacing.xl,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Historial',
                          style: AppTypography
                              .headlineMedium
                              .copyWith(
                            color:
                                AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${transactionSummary.transactionCount} movimientos',
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
                  if (transactions.isEmpty)
                    const _EmptyTransactions()
                  else
                    for (final transaction
                        in transactions) ...[
                      TransactionCard(
                        transaction: transaction,
                        onDelete: () {
                          deleteTransaction(
                            transaction,
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
    );
  }
}

class _EquityCard extends StatelessWidget {
  const _EquityCard({
    required this.totalEquity,
    required this.cashBalance,
    required this.marketValue,
  });

  final double totalEquity;
  final double cashBalance;
  final double marketValue;

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
            'Patrimonio total',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(
            height: AppSpacing.xs,
          ),
          Text(
            'USD ${totalEquity.toStringAsFixed(2)}',
            style:
                AppTypography.displayMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(
            height: AppSpacing.lg,
          ),
          Row(
            children: [
              Expanded(
                child: _EquityDetail(
                  label: 'Efectivo',
                  value: cashBalance,
                ),
              ),
              const SizedBox(
                width: AppSpacing.sm,
              ),
              Expanded(
                child: _EquityDetail(
                  label: 'Valor de mercado',
                  value: marketValue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EquityDetail extends StatelessWidget {
  const _EquityDetail({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

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
            height: AppSpacing.xxs,
          ),
          Text(
            'USD ${value.toStringAsFixed(2)}',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalResultCard extends StatelessWidget {
  const _TotalResultCard({
    required this.totalResult,
    required this.returnPercent,
  });

  final double totalResult;
  final double returnPercent;

  @override
  Widget build(BuildContext context) {
    final isPositive = totalResult >= 0;

    final resultColor =
        isPositive ? AppColors.primary : AppColors.danger;

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
            'Resultado total',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(
            height: AppSpacing.xs,
          ),
          Text(
            '${isPositive ? '+' : ''}'
            'USD ${totalResult.toStringAsFixed(2)}',
            style:
                AppTypography.displayMedium.copyWith(
              color: resultColor,
            ),
          ),
          const SizedBox(
            height: AppSpacing.sm,
          ),
          Text(
            '${returnPercent >= 0 ? '+' : ''}'
            '${returnPercent.toStringAsFixed(2)}%',
            style: AppTypography.titleMedium.copyWith(
              color: resultColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultMetricCard extends StatelessWidget {
  const _ResultMetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final double value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final valueColor =
        value >= 0 ? AppColors.primary : AppColors.danger;

    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: valueColor,
          ),
          const Spacer(),
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(
            height: AppSpacing.xxs,
          ),
          Text(
            '${value >= 0 ? '+' : ''}'
            'USD ${value.toStringAsFixed(2)}',
            style: AppTypography.titleLarge.copyWith(
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityMetricCard extends StatelessWidget {
  const _ActivityMetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final double value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
          ),
          const Spacer(),
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(
            height: AppSpacing.xxs,
          ),
          Text(
            'USD ${value.toStringAsFixed(2)}',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

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
            Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(
            height: AppSpacing.md,
          ),
          Text(
            'Todavía no hay movimientos',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(
            height: AppSpacing.xs,
          ),
          Text(
            'Registrá una compra, venta, dividendo, '
            'depósito o retiro para comenzar.',
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