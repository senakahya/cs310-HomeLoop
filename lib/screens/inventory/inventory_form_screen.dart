import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/formatters.dart';
import '../../data/home_store.dart';
import '../../models/inventory_item.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/bottom_actions.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/headers.dart';
import '../../widgets/inputs.dart';

/// Arguments for S12. Empty = add new food; itemId + batchId = edit that batch.
class InventoryFormArgs {
  final String? itemId;
  final String? batchId;
  const InventoryFormArgs({this.itemId, this.batchId});
}

/// S12 · Add / edit food in the inventory.
/// The expiry date is optional: "No expiry date on package" disables it (S12·a).
class InventoryFormScreen extends StatefulWidget {
  final InventoryFormArgs args;
  const InventoryFormScreen({super.key, required this.args});

  @override
  State<InventoryFormScreen> createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends State<InventoryFormScreen> {
  final HomeStore store = HomeStore.instance;
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _quantity = TextEditingController();
  String _unit = 'pcs';
  StorageLocation _location = StorageLocation.fridge;
  DateTime? _expiry;
  bool _noExpiry = false;
  bool _submitted = false;

  InventoryItem? _item;
  InventoryBatch? _batch;

  bool get _isEdit => _item != null && _batch != null;

  @override
  void initState() {
    super.initState();
    final itemId = widget.args.itemId;
    if (itemId != null) {
      _item = store.inventoryById(itemId);
      final item = _item;
      if (item != null && item.batches.isNotEmpty) {
        _batch = item.batches.firstWhere(
          (b) => b.id == widget.args.batchId,
          orElse: () => item.batches.first,
        );
        _name.text = item.name;
        _unit = item.unit;
        _location = item.location;
        _quantity.text = Fmt.qty(_batch!.quantity);
        _expiry = _batch!.expiry;
        _noExpiry = _batch!.expiry == null;
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = Fmt.today();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiry ?? today.add(const Duration(days: 7)),
      firstDate: today.subtract(const Duration(days: 30)),
      lastDate: today.add(const Duration(days: 365 * 5)),
      helpText: 'Date printed on the package',
    );
    if (picked != null) setState(() => _expiry = picked);
  }

  String? get _expiryError {
    if (!_submitted || _noExpiry || _expiry != null) return null;
    return 'Pick the date on the package, or turn on "No expiry date"';
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
    final fieldsOk = _formKey.currentState!.validate();
    if (!fieldsOk || _expiryError != null) return;

    final name = _name.text.trim();
    final qty = double.parse(_quantity.text.replaceAll(',', '.'));
    final expiry = _noExpiry ? null : _expiry;

    if (_isEdit) {
      store.updateInventory(
        item: _item!, batch: _batch!, name: name, quantity: qty,
        unit: _unit, location: _location, expiry: expiry,
      );
    } else {
      store.addInventory(name: name, quantity: qty, unit: _unit, location: _location, expiry: expiry);
    }
    await showSuccessDialog(
      context,
      title: _isEdit ? 'Changes saved' : 'Added to inventory',
      message: '$name · ${Fmt.qty(qty)} $_unit in the ${_location.label.toLowerCase()}'
          '${expiry == null ? ' (no expiry date).' : ', expires ${Fmt.dayYear(expiry)}.'}',
    );
    if (mounted) Navigator.of(context).pop();
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
              ScreenHeader(
                title: _isEdit ? 'Edit food' : 'Add to inventory',
                leadingIcon: Icons.close_rounded,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Item name',
                controller: _name,
                hint: 'e.g. Greek yogurt',
                icon: Icons.inventory_2_outlined,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Enter an item name';
                  if (value.length > 40) return 'Use 40 characters or fewer';
                  return null;
                },
              ),
              AppTextField(
                label: 'Quantity',
                controller: _quantity,
                hint: 'e.g. 500',
                icon: Icons.numbers_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                validator: (v) {
                  final value = double.tryParse((v ?? '').replaceAll(',', '.'));
                  if (value == null) return 'Enter a number';
                  if (value <= 0) return 'Must be more than 0';
                  return null;
                },
              ),
              const FieldLabel('Unit'),
              ChoiceChipsField<String>(
                options: InventoryItem.units,
                selected: _unit,
                labelOf: (u) => u,
                onChanged: (u) => setState(() => _unit = u),
              ),
              const SizedBox(height: AppSpacing.lg),
              const FieldLabel('Storage location'),
              SegmentedChoice<StorageLocation>(
                options: StorageLocation.values,
                selected: _location,
                labelOf: (l) => l.label,
                iconOf: (l) => l.icon,
                onChanged: (l) => setState(() => _location = l),
              ),
              const SizedBox(height: AppSpacing.lg),
              PickerField(
                label: 'Expiry date',
                value: _noExpiry
                    ? 'Not specified'
                    : (_expiry == null ? 'Select date' : Fmt.dayYear(_expiry!)),
                placeholder: _expiry == null,
                onTap: _noExpiry ? null : _pickDate,
                helper: 'Use the date printed on the package.',
                error: _expiryError,
              ),
              Row(
                children: [
                  const Expanded(
                    child: Text('No expiry date on package', style: AppTextStyles.bodyStrong),
                  ),
                  Switch(
                    value: _noExpiry,
                    activeTrackColor: AppColors.primary,
                    onChanged: (v) => setState(() => _noExpiry = v),
                  ),
                ],
              ),
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
