import 'package:flutter/material.dart';
import 'package:hacela_rendir/core/design_system/app_button.dart';
import 'package:hacela_rendir/core/design_system/app_spacing.dart';
import 'package:hacela_rendir/features/portfolio/domain/portfolio_position.dart';

class EditPositionDialog extends StatefulWidget {
  const EditPositionDialog({
    required this.position,
    super.key,
  });

  final PortfolioPosition position;

  @override
  State<EditPositionDialog> createState() => _EditPositionDialogState();
}

class _EditPositionDialogState extends State<EditPositionDialog> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController tickerController;
  late final TextEditingController nameController;
  late final TextEditingController quantityController;
  late final TextEditingController averagePriceController;
  late final TextEditingController currentPriceController;

  @override
  void initState() {
    super.initState();

    tickerController = TextEditingController(
      text: widget.position.ticker,
    );

    nameController = TextEditingController(
      text: widget.position.name,
    );

    quantityController = TextEditingController(
      text: widget.position.quantity.toString(),
    );

    averagePriceController = TextEditingController(
      text: widget.position.averagePrice.toStringAsFixed(2),
    );

    currentPriceController = TextEditingController(
      text: widget.position.currentPrice.toStringAsFixed(2),
    );
  }

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

  String? validateRequiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio.';
    }

    return null;
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

    final updatedPosition = PortfolioPosition(
      ticker: tickerController.text.trim().toUpperCase(),
      name: nameController.text.trim(),
      quantity: quantity,
      averagePrice: averagePrice,
      currentPrice: currentPrice,
    );

    Navigator.of(context).pop(updatedPosition);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar posición'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: tickerController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Ticker',
                  ),
                  validator: validateRequiredText,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del activo',
                  ),
                  validator: validateRequiredText,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: quantityController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Cantidad',
                  ),
                  validator: validatePositiveNumber,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: averagePriceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Precio promedio',
                  ),
                  validator: validatePositiveNumber,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: currentPriceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Precio actual',
                  ),
                  validator: validatePositiveNumber,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        SizedBox(
          width: 150,
          child: AppButton(
            label: 'Guardar',
            icon: Icons.save_outlined,
            onPressed: submit,
          ),
        ),
      ],
    );
  }
}