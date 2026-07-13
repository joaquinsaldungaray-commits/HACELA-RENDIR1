import 'package:flutter/material.dart';
import 'package:hacela_rendir/core/design_system/app_button.dart';
import 'package:hacela_rendir/core/design_system/app_spacing.dart';
import 'package:hacela_rendir/core/design_system/app_typography.dart';
import 'package:hacela_rendir/core/theme/app_theme.dart';
import 'package:hacela_rendir/features/portfolio/domain/portfolio_position.dart';

class AddPositionDialog extends StatefulWidget {
  const AddPositionDialog({super.key});

  @override
  State<AddPositionDialog> createState() => _AddPositionDialogState();
}

class _AddPositionDialogState extends State<AddPositionDialog> {
  final formKey = GlobalKey<FormState>();

  final tickerController = TextEditingController();
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final averagePriceController = TextEditingController();
  final currentPriceController = TextEditingController();

  @override
  void dispose() {
    tickerController.dispose();
    nameController.dispose();
    quantityController.dispose();
    averagePriceController.dispose();
    currentPriceController.dispose();
    super.dispose();
  }

  double? parseNumber(String value) {
    return double.tryParse(
      value.trim().replaceAll(',', '.'),
    );
  }

  String? validatePositiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio.';
    }

    final number = parseNumber(value);

    if (number == null || number <= 0) {
      return 'Ingresá un número mayor que cero.';
    }

    return null;
  }

  void submit() {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final quantity = parseNumber(quantityController.text);
    final averagePrice = parseNumber(averagePriceController.text);
    final currentPrice = parseNumber(currentPriceController.text);

    if (quantity == null ||
        averagePrice == null ||
        currentPrice == null) {
      return;
    }

    final position = PortfolioPosition(
      ticker: tickerController.text.trim().toUpperCase(),
      name: nameController.text.trim(),
      quantity: quantity,
      averagePrice: averagePrice,
      currentPrice: currentPrice,
    );

    Navigator.of(context).pop(position);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agregar posición',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Ingresá los datos actuales de la inversión.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _PositionField(
                  controller: tickerController,
                  label: 'Ticker',
                  hint: 'Ejemplo: AAPL',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresá el ticker.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _PositionField(
                  controller: nameController,
                  label: 'Nombre del activo',
                  hint: 'Ejemplo: Apple Inc.',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresá el nombre del activo.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _PositionField(
                  controller: quantityController,
                  label: 'Cantidad',
                  hint: 'Ejemplo: 10',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: validatePositiveNumber,
                ),
                const SizedBox(height: AppSpacing.md),
                _PositionField(
                  controller: averagePriceController,
                  label: 'Precio promedio',
                  hint: 'Ejemplo: 180.50',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: validatePositiveNumber,
                ),
                const SizedBox(height: AppSpacing.md),
                _PositionField(
                  controller: currentPriceController,
                  label: 'Precio actual',
                  hint: 'Ejemplo: 192.40',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: validatePositiveNumber,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Agregar posición',
                  icon: Icons.add_rounded,
                  onPressed: submit,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'Cancelar',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PositionField extends StatelessWidget {
  const _PositionField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.validator,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
}