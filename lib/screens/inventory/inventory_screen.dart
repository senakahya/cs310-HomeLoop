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
import '../../widgets/feedback_widgets.dart';
import '../../widgets/headers.dart';
import '../../widgets/inputs.dart';
import '../../widgets/status_badge.dart';

/// S11 · Kitchen inventory – sorted by the soonest expiry date.
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final HomeStore store = HomeStore.instance;
  final TextEditingController _search = TextEditingController();
  StorageLocation? _filter; // null = All

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _remove(InventoryItem item) {
    final index = store.removeInventoryItem(item);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('${item.name} removed from inventory'),
        action: SnackBarAction(label: 'Undo', onPressed: () => store.restoreInventoryItem(item, index)),
      ));
  }

  void _add() => Navigator.of(context).pushNamed(AppRoutes.inventoryForm);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final query = _search.text.trim().toLowerCase();
          final items = store.inventorySorted.where((i) {
            final matchesFilter = _filter == null || i.location == _filter;
            final matchesSearch = query.isEmpty || i.name.toLowerCase().contains(query);
            return matchesFilter && matchesSearch;
          }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.tabBarSpace),
            children: [
              LargeTitleHeader(
                title: 'Inventory',
                subtitle: Text('${store.inventory.length} items · sorted by expiry'),
                trailing: CircleIconButton(icon: Icons.add_rounded, dark: true, tooltip: 'Add food', onTap: _add),
              ),
              if (store.inventory.isEmpty)
                EmptyState( // S11·a
                  icon: Icons.kitchen_outlined,
                  color: AppColors.amber,
                  background: AppColors.amberSoft,
                  title: 'No food tracked yet',
                  message: "Add what's in your fridge, freezer and pantry to see what expires soon.",
                  buttonLabel: 'Add first item',
                  onPressed: _add,
                )
              else ...[
                TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search food',
                    hintStyle: AppTextStyles.body.copyWith(color: AppColors.faint),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted),
                    filled: true,
                    fillColor: AppColors.fill,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.field),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      PillChip(label: 'All', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                      for (final loc in StorageLocation.values) ...[
                        const SizedBox(width: 7),
                        PillChip(
                          label: loc.label,
                          icon: loc.icon,
                          selected: _filter == loc,
                          onTap: () => setState(() => _filter = loc),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text('No items match.', textAlign: TextAlign.center, style: AppTextStyles.bodyMuted),
                  ),
                for (final item in items)
                  Dismissible(
                    key: ValueKey(item.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.only(right: AppSpacing.xl),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(20)),
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                    ),
                    onDismissed: (_) => _remove(item),
                    child: InventoryCard(
                      item: item,
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.inventoryDetail, arguments: item.id),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// One product of the inventory as a Card.
class InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onTap;

  const InventoryCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final next = item.nextExpiry;
    final days = next == null ? 999 : Fmt.daysFromToday(next);
    Color tileBg = AppColors.fill;
    Color tileFg = AppColors.ink2;
    if (days <= 1) {
      tileBg = AppColors.redSoft;
      tileFg = AppColors.red;
    } else if (days <= 3) {
      tileBg = AppColors.amberSoft;
      tileFg = AppColors.amber;
    }
    final batches = item.batches.length;

    return Card(
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              IconTile(icon: item.location.icon, background: tileBg, foreground: tileFg),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(item.name,
                              maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodyStrong),
                        ),
                        if (batches > 1) ...[
                          const SizedBox(width: 6),
                          StatusBadge(text: '$batches batches'),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${Fmt.qty(item.totalQuantity)} ${item.unit} · ${item.location.label}'
                      '${batches > 1 && next != null ? ' · next ${Fmt.day(next)}' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusBadge.expiry(next),
            ],
          ),
        ),
      ),
    );
  }
}
