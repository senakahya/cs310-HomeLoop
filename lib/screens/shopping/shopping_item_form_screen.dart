import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/formatters.dart';
import '../../data/home_store.dart';
import '../../models/shopping_item.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/bottom_actions.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/feedback_widgets.dart';
import '../../widgets/headers.dart';
import '../../widgets/inputs.dart';

/// S09 · Add / edit shopping item.
/// Form with two text fields + inline validation, and a confirmation dialog
/// after a valid submission (Step 2.2 form requirement).
class ShoppingItemFormScreen extends StatefulWidget {
  /// null = add a new item, otherwise edit this item.
  final ShoppingItem? item;

  const ShoppingItemFormScreen({super.key, this.item});

  @override
  State<ShoppingItemFormScreen> createState() => _ShoppingItemFormScreenState();
}

class _ShoppingItemFormScreenState extends State<ShoppingItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _quantity;
  late String _unit;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.item?.name ?? '');
    _quantity = TextEditingController(text: widget.item == null ? '1' : Fmt.qty(widget.item!.quantity));
    _unit = widget.item?.unit ?? 'pcs';
  }

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter an item name';
    if (v.length > 40) return 'Use 40 characters or fewer';
    return null;
  }

  String? _validateQuantity(String? value) {
    final v = double.tryParse((value ?? '').replaceAll(',', '.'));
    if (v == null) return 'Enter a number';
    if (v <= 0) return 'Quantity must be more than 0';
    if (v > 999) return 'That is a lot – use 999 or less';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final store = HomeStore.instance;
    final name = _name.text.trim();
    final qty = double.parse(_quantity.text.replaceAll(',', '.'));

    if (_isEdit) {
      store.updateShoppingItem(widget.item!, name, qty, _unit);
    } else {
      store.addShoppingItem(name, qty, _unit);
    }
    await showSuccessDialog(
      context,
      title: _isEdit ? 'Item updated' : 'Item added',
      message: '$name (${Fmt.qty(qty)} $_unit) is on the shared list. Everyone in the household can see it.',
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Delete ${widget.item!.name}?',
      message: 'The item will be removed from everyone\'s shopping list.',
      confirmLabel: 'Delete',
      danger: true,
      icon: Icons.delete_outline_rounded,
    );
    if (ok && mounted) {
      HomeStore.instance.removeShoppingItem(widget.item!);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            children: [
              ScreenHeader(title: _isEdit ? 'Edit item' : 'Add item', leadingIcon: Icons.close_rounded),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Item name',
                controller: _name,
                hint: 'e.g. Olive oil',
                icon: Icons.inventory_2_outlined,
                textInputAction: TextInputAction.next,
                validator: _validateName,
              ),
              AppTextField(
                label: 'Quantity',
                controller: _quantity,
                hint: '1',
                icon: Icons.numbers_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                validator: _validateQuantity,
              ),
              const FieldLabel('Unit'),
              ChoiceChipsField<String>(
                options: ShoppingItem.units,
                selected: _unit,
                labelOf: (u) => u,
                onChanged: (u) => setState(() => _unit = u),
              ),
              const SizedBox(height: AppSpacing.xl),
              const InfoNote(text: 'Everyone in the household will see this item right away.'),
              if (_isEdit) ...[
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Delete item',
                  icon: Icons.delete_outline_rounded,
                  style: AppButtonStyle.dangerSoft,
                  onPressed: _delete,
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomActions(
        children: [
          Expanded(
            child: AppButton(
              label: 'Cancel',
              style: AppButtonStyle.secondary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: AppButton(label: 'Save', onPressed: _save)),
        ],
      ),
    );
  }
}
