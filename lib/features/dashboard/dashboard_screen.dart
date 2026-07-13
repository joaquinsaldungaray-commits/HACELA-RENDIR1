import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hacela_rendir/app/router/app_routes.dart';
import 'package:hacela_rendir/core/design_system/app_button.dart';
import 'package:hacela_rendir/core/design_system/app_spacing.dart';
import 'package:hacela_rendir/core/design_system/app_typography.dart';
import 'package:hacela_rendir/core/finance/engine/financial_engine.dart';
import 'package:hacela_rendir/core/finance/models/financial_snapshot.dart';
import 'package:hacela_rendir/core/theme/app_theme.dart';
import 'package:hacela_rendir/features/portfolio/services/portfolio_sync_service.dart';
import 'package:hacela_rendir/features/transactions/data/transaction_repository.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TransactionRepository transactionRepository =
      TransactionRepository();

  final PortfolioSyncService portfolioSyncService =
      PortfolioSyncService();

  FinancialSnapshot? snapshot;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final transactions =
          await transactionRepository.loadTransactions();

      final positions =
          await portfolioSyncService.syncFromTransactions();

      final calculatedSnapshot =
          FinancialEngine.calculateFromData(
        transactions: transactions,
        positions: positions,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        snapshot = calculatedSnapshot;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });
    }
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

    final currentSnapshot = snapshot;

    final totalEquity =
        currentSnapshot?.totalEquity ?? 0;

    final totalResult =
        currentSnapshot?.totalResult ?? 0;

    final returnPercent =
        currentSnapshot?.returnPercent ?? 0;

    final resultColor = totalResult >= 0
        ? AppColors.primary
        : AppColors.danger;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hacela Rendir',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: loadDashboard,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () {
              context.go(
                AppRoutes.welcome,
              );
            },
            icon: const Icon(
              Icons.logout_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadDashboard,
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
                      'Buen día, Joaquín',
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
                      'Este es el estado actual de tus inversiones.',
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
                    _DashboardHeroCard(
                      totalEquity: totalEquity,
                      totalResult: totalResult,
                      returnPercent:
                          returnPercent,
                      resultColor:
                          resultColor,
                    ),
                    const SizedBox(
                      height: AppSpacing.lg,
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
                      childAspectRatio: 1.45,
                      children: [
                        _DashboardMetric(
                          label: 'Efectivo',
                          value:
                              'USD ${(currentSnapshot?.cashBalance ?? 0).toStringAsFixed(2)}',
                          icon:
                              Icons.account_balance_wallet_outlined,
                        ),
                        _DashboardMetric(
                          label: 'Valor de mercado',
                          value:
                              'USD ${(currentSnapshot?.marketValue ?? 0).toStringAsFixed(2)}',
                          icon:
                              Icons.show_chart_rounded,
                        ),
                        _DashboardMetric(
                          label: 'Resultado realizado',
                          value:
                              'USD ${(currentSnapshot?.realizedProfit ?? 0).toStringAsFixed(2)}',
                          icon:
                              Icons.task_alt_rounded,
                          valueColor:
                              (currentSnapshot?.realizedProfit ?? 0) >= 0
                                  ? AppColors.primary
                                  : AppColors.danger,
                        ),
                        _DashboardMetric(
                          label: 'Posiciones',
                          value:
                              '${currentSnapshot?.positionsCount ?? 0}',
                          icon:
                              Icons.layers_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: AppSpacing.xl,
                    ),
                    Text(
                      'Accesos rápidos',
                      style: AppTypography
                          .headlineMedium
                          .copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(
                      height: AppSpacing.md,
                    ),
                    AppButton(
                      label: 'Ver mi cartera',
                      icon:
                          Icons.account_balance_wallet_outlined,
                      onPressed: () {
                        context.push(
                          AppRoutes.portfolio,
                        );
                      },
                    ),
                    const SizedBox(
                      height: AppSpacing.sm,
                    ),
                    AppButton(
                      label: 'Ver performance',
                      icon:
                          Icons.insights_outlined,
                      variant:
                          AppButtonVariant.secondary,
                      onPressed: () {
                        context.push(
                          AppRoutes.performance,
                        );
                      },
                    ),
                    const SizedBox(
                      height: AppSpacing.sm,
                    ),
                    AppButton(
                      label: 'Ver movimientos',
                      icon:
                          Icons.receipt_long_outlined,
                      variant:
                          AppButtonVariant.secondary,
                      onPressed: () {
                        context.push(
                          AppRoutes.transactions,
                        );
                      },
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

class _DashboardHeroCard extends StatelessWidget {
  const _DashboardHeroCard({
    required this.totalEquity,
    required this.totalResult,
    required this.returnPercent,
    required this.resultColor,
  });

  final double totalEquity;
  final double totalResult;
  final double returnPercent;
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
            height: AppSpacing.md,
          ),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              Text(
                '${totalResult >= 0 ? '+' : ''}'
                'USD ${totalResult.toStringAsFixed(2)}',
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
        ],
      ),
    );
  }
}

class _DashboardMetric extends StatelessWidget {
  const _DashboardMetric({
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
      padding: const EdgeInsets.all(
        AppSpacing.md,
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color:
                valueColor ?? AppColors.primary,
          ),
          const Spacer(),
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
            style: AppTypography.titleLarge.copyWith(
              color:
                  valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}