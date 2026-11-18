import 'package:flutter/material.dart';

import '../../data/formatters.dart';
import '../../data/home_store.dart';
import '../../models/inventory_item.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/bottom_actions.dart';
import '../../widgets/headers.dart';
import '../../widgets/inputs.dart';

class StockUpdateArgs {
  final String itemId;
  final String batchId;
  final bool discard;
  const StockUpdateArgs({required this.itemId, required this.batchId, this.discard = false});
}

/// S14 · Update stock – how much of a batch was consumed or discarded.
class StockUpdateScreen extends StatefulWidget {
  final StockUpdateArgs args;
  const StockUpdateScreen({super.key, required this.args});

  @override
  State<StockUpdateScreen> createState() => _StockUpdateScreenState();
}

class _StockUpdateScreenState extends State<StockUpdateScreen> {
  final HomeStore store = HomeStore.instance;
  late bool _discarded = widget.args.discard;
  InventoryItem? _item;
  InventoryBatch? _batch;
  double _amount = 1;

  /// Step of the − / + buttons depends on the unit.
  double get _step {
    switch (_item?.unit) {
      case 'g':
      case 'mL':
        return 50;
      case 'kg':
      case 'L':
        return 0.25;
      default:
        return 1;
    }
  }

  @override
  void initState() {
    super.initState();
    _item = store.inventoryById(widget.args.itemId);
    final item = _item;
    if (item != null) {
      for (final b in item.batches) {
        if (b.id == widget.args.batchId) _batch = b;
      }
    }
    final available = _batch?.quantity ?? 1;
    _amount = _step <= available ? _step : available;
  }

  void _update() {
    final item = _item!;
    final used = store.useStock(item, _batch!, _amount);
    final verb = _discarded ? 'discarded' : 'consumed';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(used
          ? '${item.name} is used up and was removed from the inventory'
          : '${Fmt.qty(_amount)} ${item.unit} ${item.name} marked as $verb'),
    ));
    if (used) {
      // The detail screen (S13) would be empty, so go back to the inventory list.
      Navigator.of(context).popUntil((route) => route.settings.name == AppRoutes.main || route.isFirst);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    final batch = _batch;
    if (item == null || batch == null) {
      return const Scaffold(body: Center(child: Text('Batch not found')));
    }
    final available = batch.quantity;
    final left = available - _amount;
    final quick = <double>{_step, _step * 2, available}.where((v) => v <= available).toList()..sort();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          children: [
            const ScreenHeader(title: 'Update stock', leadingIcon: Icons.close_rounded),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              child: Row(
                children: [
                  IconTile(icon: item.location.icon, background: AppColors.amberSoft, foreground: AppColors.amber),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          batch.expiry == null ? item.name : '${item.name} · batch ${Fmt.day(batch.expiry!)}',
                          style: AppTextStyles.bodyStrong,
                        ),
                        Text('${Fmt.qty(available)} ${item.unit} available · ${item.location.label}',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const FieldLabel('What happened?'),
            SegmentedChoice<bool>(
              options: const [false, true],
              selected: _discarded,
              labelOf: (d) => d ? 'Discarded' : 'Consumed',
              iconOf: (d) => d ? Icons.delete_outline_rounded : Icons.check_rounded,
              onChanged: (d) => setState(() => _discarded = d),
            ),
            const SizedBox(height: AppSpacing.lg),
            const FieldLabel('Amount'),
            QuantityStepper(
              value: _amount,
              step: _step,
              min: _step < available ? _step : available,
              max: available,
              unit: item.unit,
              onChanged: (v) => setState(() => _amount = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              children: [
                for (final q in quick)
                  PillChip(
                    label: q == available ? 'All (${Fmt.qty(q)} ${item.unit})' : '${Fmt.qty(q)} ${item.unit}',
                    selected: (q - _amount).abs() < 0.0001,
                    onTap: () => setState(() => _amount = q),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              color: AppColors.primaryTint,
              shadow: false,
              child: Row(
                children: [
                  const Expanded(child: Text('Left in this batch', style: AppTextStyles.body)),
                  Text('${Fmt.qty(left < 0 ? 0 : left)} ${item.unit}', style: AppTextStyles.number),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.sm, AppSpacing.xs, AppSpacing.xl),
              child: Text("If the whole batch is used, it's removed from the inventory.", style: AppTextStyles.caption),
            ),
          ],
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
          Expanded(child: AppButton(label: 'Update stock', onPressed: _update)),
        ],
      ),
    );
  }
}
