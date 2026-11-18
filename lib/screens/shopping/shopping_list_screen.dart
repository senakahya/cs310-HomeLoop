import 'package:flutter/material.dart';

import '../../data/formatters.dart';
import '../../data/home_store.dart';
import '../../models/shopping_item.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/feedback_widgets.dart';
import '../../widgets/headers.dart';
import '../../widgets/inputs.dart';
import '../../widgets/member_avatar.dart';

/// S08 · Shared shopping list.
/// Items are shown with Card widgets. Swipe an item to the left to remove it
/// (with Undo). Select items and tap "Mark as purchased" to open S10.
class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final HomeStore store = HomeStore.instance;
  final Set<String> _selected = {};
  bool _showPurchased = false;

  void _remove(ShoppingItem item) {
    _selected.remove(item.id);
    final index = store.removeShoppingItem(item);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('${item.name} removed'),
        action: SnackBarAction(label: 'Undo', onPressed: () => store.restoreShoppingItem(item, index)),
      ));
  }

  Future<void> _markPurchased() async {
    final ids = _selected.toList();
    final done = await Navigator.of(context).pushNamed(AppRoutes.confirmPurchase, arguments: ids);
    if (done == true && mounted) {
      setState(() => _selected.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${ids.length} item${ids.length == 1 ? '' : 's'} marked as purchased')),
      );
    }
  }

  void _openForm([ShoppingItem? item]) {
    Navigator.of(context).pushNamed(AppRoutes.shoppingItem, arguments: item);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final toBuy = store.toBuy;
          final purchased = store.purchased;
          _selected.removeWhere((id) => !toBuy.any((i) => i.id == id));
          final items = _showPurchased ? purchased : toBuy;

          return Stack(
            children: [
              ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  0,
                  AppSpacing.screen,
                  AppSpacing.tabBarSpace + (_selected.isEmpty ? 0 : 80),
                ),
                children: [
                  LargeTitleHeader(
                    title: 'Shopping',
                    subtitle: Row(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Synced · ${store.household?.name ?? ''}',
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    trailing: CircleIconButton(icon: Icons.add_rounded, dark: true, tooltip: 'Add item', onTap: _openForm),
                  ),
                  Row(
                    children: [
                      PillChip(
                        label: 'To buy · ${toBuy.length}',
                        selected: !_showPurchased,
                        onTap: () => setState(() => _showPurchased = false),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      PillChip(
                        label: 'Purchased · ${purchased.length}',
                        selected: _showPurchased,
                        onTap: () => setState(() => _showPurchased = true),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (items.isEmpty && !_showPurchased)
                    EmptyState( // S08·a
                      icon: Icons.shopping_basket_outlined,
                      title: 'Your list is empty',
                      message: 'Add something the household needs. Everyone sees changes instantly.',
                      buttonLabel: 'Add first item',
                      onPressed: _openForm,
                    )
                  else if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text('No purchases yet.', textAlign: TextAlign.center, style: AppTextStyles.bodyMuted),
                    ),
                  for (final item in items)
                    Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      background: const _DeleteBackground(),
                      onDismissed: (_) => _remove(item),
                      child: _ShoppingCard(
                        item: item,
                        selected: _selected.contains(item.id),
                        onToggle: item.isPurchased
                            ? null
                            : () => setState(() {
                                  if (!_selected.remove(item.id)) _selected.add(item.id);
                                }),
                        onTap: item.isPurchased ? null : () => _openForm(item),
                      ),
                    ),
                  if (items.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: AppSpacing.xs, left: AppSpacing.xs),
                      child: Text('Swipe left to remove an item.', style: AppTextStyles.caption),
                    ),
                ],
              ),
              if (_selected.isNotEmpty)
                Positioned(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: 100 + MediaQuery.of(context).padding.bottom,
                  child: _SelectionBar(
                    names: toBuy.where((i) => _selected.contains(i.id)).map((i) => i.name).toList(),
                    onPressed: _markPurchased,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ShoppingCard extends StatelessWidget {
  final ShoppingItem item;
  final bool selected;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  const _ShoppingCard({required this.item, required this.selected, this.onToggle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final store = HomeStore.instance;
    final purchased = item.isPurchased;
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
              _RoundCheck(checked: selected || purchased, muted: purchased, onTap: onToggle),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyStrong.copyWith(
                        color: purchased ? AppColors.faint : AppColors.ink,
                        decoration: purchased ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (purchased && item.boughtById != null)
                      Row(
                        children: [
                          MemberAvatar(member: store.memberById(item.boughtById!), size: 16),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'Bought by ${store.displayName(item.boughtById!)} · ${Fmt.day(item.purchasedOn ?? DateTime.now())}',
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption,
                            ),
                          ),
                        ],
                      )
                    else
                      Text('Added by ${store.displayName(item.addedById)}', style: AppTextStyles.caption),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${Fmt.qty(item.quantity)} ${item.unit}',
                style: AppTextStyles.label.copyWith(color: purchased ? AppColors.faint : AppColors.ink2, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundCheck extends StatelessWidget {
  final bool checked;
  final bool muted;
  final VoidCallback? onTap;

  const _RoundCheck({required this.checked, required this.muted, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = muted ? const Color(0xFFB9C5BF) : AppColors.primary;
    return Semantics(
      checked: checked,
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: checked ? color : Colors.transparent,
              border: Border.all(color: checked ? color : const Color(0xFFCBCEC8), width: 2),
            ),
            child: checked ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
          ),
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.only(right: AppSpacing.xl),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(20)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline_rounded, color: Colors.white),
          SizedBox(width: 6),
          Text('Remove', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SelectionBar extends StatelessWidget {
  final List<String> names;
  final VoidCallback onPressed;

  const _SelectionBar({required this.names, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: const [BoxShadow(color: Color(0x591F2522), blurRadius: 30, offset: Offset(0, 14), spreadRadius: -12)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${names.length} selected', style: AppTextStyles.bodyStrong.copyWith(fontSize: 13.5)),
                Text(names.join(', '), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppButton(label: 'Mark as purchased', small: true, expand: false, onPressed: onPressed),
        ],
      ),
    );
  }
}
