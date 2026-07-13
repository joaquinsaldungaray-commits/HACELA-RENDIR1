import 'package:flutter/material.dart';
import 'package:hacela_rendir/core/design_system/app_button.dart';
import 'package:hacela_rendir/core/design_system/app_spacing.dart';
import 'package:hacela_rendir/features/assets/services/asset_lookup_service.dart';
import 'package:hacela_rendir/features/transactions/domain/portfolio_transaction.dart';

class AddTransactionDialog extends StatefulWidget {
  const AddTransactionDialog({super.key});

  @override
  State<AddTransactionDialog> createState() =>
      _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final formKey = GlobalKey<FormState>();

  final AssetLookupService assetLookupService =
      const AssetLookupService();

  TransactionType selectedType = TransactionType.buy;

  final tickerController = TextEditingController();
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  final amountController = TextEditingController();
  final feeController = TextEditingController(text: '0');
  final notesController = TextEditingController();

  bool isLookingUpAsset = false;
  String? assetLookupMessage;

  @override
  void dispose() {
    tickerController.dispose();
    nameController.dispose();
    quantityController.dispose();
    priceController.dispose();
    amountController.dispose();
    feeController.dispose();
    notesController.dispose();

    super.dispose();
  }

  bool get usesAssetFields {
    return selectedType == TransactionType.buy ||
        selectedType == TransactionType.sell;
  }

  double? parseNumber(String value) {
    return double.tryParse(
      value.trim().replaceAll(',', '.'),
    );
  }

  String? validatePositiveNumber(String? value) {
    final number = parseNumber(value ?? '');

    if (number == null || number <= 0) {
      return 'Ingresá un número mayor que cero.';
    }

    return null;
  }

  String transactionLabel(TransactionType type) {
    return switch (type) {
      TransactionType.buy => 'Compra',
      TransactionType.sell => 'Venta',
      TransactionType.dividend => 'Dividendo',
      TransactionType.fee => 'Comisión',
      TransactionType.deposit => 'Depósito',
      TransactionType.withdrawal => 'Retiro',
    };
  }

  Future<void> lookupAsset() async {
    final symbol = tickerController.text.trim().toUpperCase();

    if (symbol.isEmpty) {
      setState(() {
        assetLookupMessage = 'Ingresá un ticker para buscar.';
      });

      return;
    }

    setState(() {
      isLookingUpAsset = true;
      assetLookupMessage = null;
    });

    final asset = await assetLookupService.findBySymbol(
      symbol,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isLookingUpAsset = false;

      if (asset == null) {
        assetLookupMessage =
            'No encontramos ese activo en la base local.';
        return;
      }

      tickerController.text = asset.symbol;
      nameController.text = asset.name;

      assetLookupMessage =
          '${asset.exchange} · ${asset.country} · '
          '${asset.currency} · ${asset.sector}';
    });
  }

  void submit() {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final transaction = PortfolioTransaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: selectedType,
      date: DateTime.now(),
      ticker: usesAssetFields
          ? tickerController.text.trim().toUpperCase()
          : null,
      assetName: usesAssetFields
          ? nameController.text.trim()
          : null,
      quantity: usesAssetFields
          ? parseNumber(quantityController.text) ?? 0
          : 0,
      price: usesAssetFields
          ? parseNumber(priceController.text) ?? 0
          : 0,
      amount: usesAssetFields
          ? 0
          : parseNumber(amountController.text) ?? 0,
      fee: usesAssetFields
          ? parseNumber(feeController.text) ?? 0
          : 0,
      notes: notesController.text.trim(),
    );

    Navigator.of(context).pop(transaction);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar movimiento'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 460,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<TransactionType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de movimiento',
                  ),
                  items: TransactionType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(
                            transactionLabel(type),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      selectedType = value;
                      assetLookupMessage = null;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                if (usesAssetFields) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: tickerController,
                          textCapitalization:
                              TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Ticker',
                            hintText: 'Ejemplo: AAPL',
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Ingresá el ticker.';
                            }

                            return null;
                          },
                          onFieldSubmitted: (_) {
                            lookupAsset();
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox(
                        width: 110,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: isLookingUpAsset
                              ? null
                              : lookupAsset,
                          child: isLookingUpAsset
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Buscar'),
                        ),
                      ),
                    ],
                  ),
                  if (assetLookupMessage != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        assetLookupMessage!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del activo',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresá el nombre.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: quantityController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
                    ),
                    validator: validatePositiveNumber,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Precio',
                    ),
                    validator: validatePositiveNumber,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: feeController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Comisión',
                    ),
                  ),
                ] else
                  TextFormField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Importe',
                    ),
                    validator: validatePositiveNumber,
                  ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notas opcionales',
                  ),
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
          width: 170,
          child: AppButton(
            label: 'Registrar',
            icon: Icons.save_outlined,
            onPressed: submit,
          ),
        ),
      ],
    );
  }
}