import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hacela_rendir/app/router/app_routes.dart';
import 'package:hacela_rendir/core/design_system/app_spacing.dart';
import 'package:hacela_rendir/core/design_system/app_typography.dart';
import 'package:hacela_rendir/core/theme/app_theme.dart';
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
  final repository = TransactionRepository();

  List<PortfolioTransaction> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final loaded = await repository.loadTransactions();

    if (!mounted) {
      return;
    }

    setState(() {
      transactions = loaded;
      isLoading = false;
    });
  }

  Future<void> addTransaction() async {
    final transaction = await showDialog<PortfolioTransaction>(
      context: context,
      builder: (context) {
        return const AddTransactionDialog();
      },
    );

    if (transaction == null || !mounted) {
      return;
    }

    setState(() {
      transactions.insert(0, transaction);
    });

    await repository.saveTransactions(transactions);
  }

  Future<void> deleteTransaction(
    PortfolioTransaction transaction,
  ) async {
    setState(() {
      transactions.removeWhere(
        (item) => item.id == transaction.id,
      );
    });

    await repository.saveTransactions(transactions);
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

    final summary = TransactionCalculator.calculate(
      transactions,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.go(AppRoutes.portfolio);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Movimientos',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: addTransaction,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addTransaction,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo movimiento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
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
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1.8,
                  children: [
                    _SummaryCard(
                      label: 'Compras',
                      value: summary.totalPurchases,
                    ),
                    _SummaryCard(
                      label: 'Ventas',
                      value: summary.totalSales,
                    ),
                    _SummaryCard(
                      label: 'Dividendos',
                      value: summary.totalDividends,
                    ),
                    _SummaryCard(
                      label: 'Comisiones',
                      value: summary.totalFees,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Historial',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (transactions.isEmpty)
                  Text(
                    'Todavía no registraste movimientos.',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  for (final transaction in transactions) ...[
                    TransactionCard(
                      transaction: transaction,
                      onDelete: () {
                        deleteTransaction(transaction);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

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
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
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