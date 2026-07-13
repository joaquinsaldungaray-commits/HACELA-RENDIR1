import 'package:flutter/material.dart';
import 'package:hacela_rendir/core/design_system/app_spacing.dart';
import 'package:hacela_rendir/core/design_system/app_typography.dart';
import 'package:hacela_rendir/core/theme/app_theme.dart';
import 'package:hacela_rendir/features/transactions/domain/portfolio_transaction.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    required this.transaction,
    required this.onDelete,
    super.key,
  });

  final PortfolioTransaction transaction;
  final VoidCallback onDelete;

  String get typeLabel {
    return switch (transaction.type) {
      TransactionType.buy => 'Compra',
      TransactionType.sell => 'Venta',
      TransactionType.dividend => 'Dividendo',
      TransactionType.fee => 'Comisión',
      TransactionType.deposit => 'Depósito',
      TransactionType.withdrawal => 'Retiro',
    };
  }

  IconData get icon {
    return switch (transaction.type) {
      TransactionType.buy => Icons.add_shopping_cart_rounded,
      TransactionType.sell => Icons.sell_outlined,
      TransactionType.dividend => Icons.payments_outlined,
      TransactionType.fee => Icons.receipt_long_outlined,
      TransactionType.deposit => Icons.south_west_rounded,
      TransactionType.withdrawal => Icons.north_east_rounded,
    };
  }

  Color get valueColor {
    return transaction.netCashFlow >= 0
        ? AppColors.primary
        : AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final date = transaction.date;
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.ticker == null
                      ? typeLabel
                      : '$typeLabel · ${transaction.ticker}',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  formattedDate,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.netCashFlow >= 0 ? '+' : ''}'
            'USD ${transaction.netCashFlow.toStringAsFixed(2)}',
            style: AppTypography.titleMedium.copyWith(
              color: valueColor,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'delete',
                child: Text('Eliminar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}