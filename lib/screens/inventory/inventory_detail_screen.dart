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
import '../../widgets/status_badge.dart';
import 'inventory_form_screen.dart';
import 'stock_update_screen.dart';

/// S13 · Item detail – every batch of one product with its own expiry date.
class InventoryDetailScreen extends StatelessWidget {
  final String itemId;
  const InventoryDetailScreen({super.key, required this.itemId});

  /// S13·a – bottom sheet to put the product back on the shopping list.
  Future<void> _addToShopping(BuildContext context, InventoryItem item) async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (context) => _AddToListSheet(item: item),
    );
    if (added == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${item.name} added to the shopping list'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoutes.main, (route) => false, arguments: 1),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = HomeStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final item = store.inventoryById(itemId);
        if (item == null) {
          return const Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.screen),
                child: Column(
                  children: [
                    ScreenHeader(),
                    Spacer(),
                    Text('This item is no longer in the inventory.', style: AppTextStyles.bodyMuted),
                    Spacer(),
                  ],
                ),
              ),
            ),
          );
        }
        final next = item.nextExpiry;
        Color tileBg = AppColors.fill;
        Color tileFg = AppColors.ink2;
        if (next != null && Fmt.daysFromToday(next) <= 3) {
          tileBg = AppColors.amberSoft;
          tileFg = AppColors.amber;
        }
        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
              children: [
                ScreenHeader(
                  actions: [
                    CircleIconButton(
                      icon: Icons.edit_outlined,
                      tooltip: 'Edit',
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.inventoryForm,
                        arguments: InventoryFormArgs(itemId: item.id, batchId: item.batches.first.id),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    IconTile(icon: item.location.icon, size: 58, background: tileBg, foreground: tileFg),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: AppTextStyles.display.copyWith(fontSize: 26)),
                          const SizedBox(height: 2),
                          Text(
                            '${Fmt.qty(item.totalQuantity)} ${item.unit} in total · ${item.location.label}',
                            style: AppTextStyles.bodyMuted.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SectionHeader(title: 'Batches · ${item.batches.length}'),
                for (final batch in item.batches) ...[
                  _BatchCard(item: item, batch: batch),
                  const SizedBox(height: AppSpacing.sm),
                ],
                const Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.xs, AppSpacing.xs, AppSpacing.xl),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 15, color: AppColors.muted),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Purchases with different expiry dates are kept as separate batches.',
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomActions(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Add to shopping list',
                  icon: Icons.add_shopping_cart_rounded,
                  style: AppButtonStyle.secondary,
                  onPressed: () => _addToShopping(context, item),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BatchCard extends StatelessWidget {
  final InventoryItem item;
  final InventoryBatch batch;

  const _BatchCard({required this.item, required this.batch});

  void _openStock(BuildContext context, bool discard) {
    Navigator.of(context).pushNamed(
      AppRoutes.stockUpdate,
      arguments: StockUpdateArgs(itemId: item.id, batchId: batch.id, discard: discard),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expiry = batch.expiry;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 14, AppSpacing.sm, 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${Fmt.qty(batch.quantity)} ${item.unit}', style: AppTextStyles.number),
                    const SizedBox(height: 2),
                    Text(
                      expiry == null ? 'No expiry date' : 'Expires ${Fmt.day(expiry)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              StatusBadge.expiry(expiry),
              IconButton(
                tooltip: 'Edit batch',
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.muted),
                onPressed: () => Navigator.of(context).pushNamed(
                  AppRoutes.inventoryForm,
                  arguments: InventoryFormArgs(itemId: item.id, batchId: batch.id),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Consumed',
                    icon: Icons.check_rounded,
                    small: true,
                    style: AppButtonStyle.secondary,
                    onPressed: () => _openStock(context, false),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: 'Discarded',
                    icon: Icons.delete_outline_rounded,
                    small: true,
                    style: AppButtonStyle.secondary,
                    onPressed: () => _openStock(context, true),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddToListSheet extends StatefulWidget {
  final InventoryItem item;
  const _AddToListSheet({required this.item});

  @override
  State<_AddToListSheet> createState() => _AddToListSheetState();
}

class _AddToListSheetState extends State<_AddToListSheet> {
  double _qty = 1;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen, 10, AppSpacing.screen,
          AppSpacing.xl + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(color: const Color(0xFFD9DAD4), borderRadius: BorderRadius.circular(3)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                const IconTile(
                  icon: Icons.shopping_cart_outlined,
                  size: 44,
                  background: AppColors.primarySoft,
                  foreground: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add ${widget.item.name} to shopping list?',
                          style: AppTextStyles.title.copyWith(fontSize: 18)),
                      const Text('Everyone will see it under To buy.', style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const FieldLabel('Quantity'),
            QuantityStepper(
              value: _qty,
              min: 1,
              unit: widget.item.unit,
              onChanged: (v) => setState(() => _qty = v),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Cancel',
                    style: AppButtonStyle.secondary,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: 'Add to list',
                    onPressed: () {
                      HomeStore.instance.addShoppingItem(widget.item.name, _qty, widget.item.unit);
                      Navigator.of(context).pop(true);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
