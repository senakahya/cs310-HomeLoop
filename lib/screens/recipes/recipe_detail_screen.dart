import 'package:flutter/material.dart';

import '../../data/formatters.dart';
import '../../data/home_store.dart';
import '../../data/recipe_assistant.dart';
import '../../models/recipe.dart';
import '../../models/shopping_item.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/bottom_actions.dart';
import '../../widgets/feedback_widgets.dart';
import '../../widgets/headers.dart';
import '../../widgets/inputs.dart';
import '../../widgets/status_badge.dart';
import 'recipe_card.dart';

/// S21 · Recipe detail – which ingredients are at home, which are missing,
/// and the steps. Missing ingredients can be added to the shopping list.
class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  void _addMissing(BuildContext context, RecipeMatch match) {
    final store = HomeStore.instance;
    final onList = store.toBuy.map((i) => i.name.toLowerCase()).toSet();
    int added = 0;
    for (final ing in match.missing) {
      if (onList.contains(ing.name.toLowerCase())) continue;
      // Shopping units are simpler than recipe units (no "tsp", "cloves"…).
      final usable = ShoppingItem.units.contains(ing.unit);
      store.addShoppingItem(ing.name, usable ? ing.amount : 1, usable ? ing.unit : 'pack');
      added++;
    }
    final text = added == 0
        ? 'The missing ingredients are already on the shopping list'
        : '$added item${added == 1 ? '' : 's'} added to the shopping list';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(text),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.main,
            (route) => false,
            arguments: 1, // Shopping tab
          ),
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final store = HomeStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final match = RecipeAssistant.instance.match(recipe);
        final onList = store.toBuy.map((i) => i.name.toLowerCase()).toSet();
        final stillMissing = match.missing.where((i) => !onList.contains(i.name.toLowerCase())).length;

        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
              children: [
                const ScreenHeader(),
                const SizedBox(height: AppSpacing.sm),
                const ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(AppRadius.card)),
                  child: SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: FittedBox(fit: BoxFit.cover, child: RecipePicture(size: 130, radius: 0)),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(recipe.title, style: AppTextStyles.display.copyWith(fontSize: 26)),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    PillChip(label: '${recipe.minutes} min', icon: Icons.schedule_rounded),
                    PillChip(label: '${recipe.servings} servings', icon: Icons.people_outline_rounded),
                    if (recipe.vegetarian) const PillChip(label: 'Vegetarian', icon: Icons.eco_outlined),
                  ],
                ),
                if (match.expiringUsed.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  InfoNote(
                    tone: NoteTone.warning,
                    text: 'Uses ${_expiringText(store, match)}.',
                  ),
                ],
                SectionHeader(title: 'Ingredients · ${recipe.ingredients.length}'),
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                  child: Column(
                    children: [
                      for (int i = 0; i < recipe.ingredients.length; i++) ...[
                        if (i > 0) const RowDivider(),
                        _IngredientRow(
                          ingredient: recipe.ingredients[i],
                          have: match.available.contains(recipe.ingredients[i]),
                        ),
                      ],
                    ],
                  ),
                ),
                SectionHeader(title: 'Steps · ${recipe.steps.length}'),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < recipe.steps.length; i++)
                        Padding(
                          padding: EdgeInsets.only(bottom: i == recipe.steps.length - 1 ? 0 : AppSpacing.md),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                                child: Text('${i + 1}',
                                    style: AppTextStyles.badge.copyWith(color: AppColors.primary, fontSize: 12)),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(child: Text(recipe.steps[i], style: AppTextStyles.body.copyWith(height: 1.4))),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.md, AppSpacing.xs, AppSpacing.xl),
                  child: Text('AI-generated suggestion – check ingredients and allergies.', style: AppTextStyles.caption),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomActions(
            children: [
              Expanded(
                child: match.missing.isEmpty
                    ? const AppButton(label: 'Everything is in your kitchen', icon: Icons.check_rounded, onPressed: null)
                    : AppButton(
                        label: stillMissing == 0
                            ? 'Missing items are on the list'
                            : 'Add $stillMissing missing to shopping list',
                        icon: Icons.add_shopping_cart_rounded,
                        onPressed: stillMissing == 0 ? null : () => _addMissing(context, match),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _expiringText(HomeStore store, RecipeMatch match) {
    final parts = <String>[];
    for (final name in match.expiringUsed) {
      final item = store.inventory.where((i) => i.name == name);
      final when = item.isEmpty ? '' : ' (expires ${Fmt.expiry(item.first.nextExpiry).toLowerCase()})';
      parts.add('$name$when');
    }
    return parts.join(' and ');
  }
}

class _IngredientRow extends StatelessWidget {
  final RecipeIngredient ingredient;
  final bool have;

  const _IngredientRow({required this.ingredient, required this.have});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            have ? Icons.check_circle_rounded : Icons.cancel_outlined,
            size: 22,
            color: have ? AppColors.primary : AppColors.red,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(ingredient.name, style: AppTextStyles.bodyStrong)),
          Text('${Fmt.qty(ingredient.amount)} ${ingredient.unit}', style: AppTextStyles.caption),
          const SizedBox(width: AppSpacing.sm),
          StatusBadge(
            text: have ? 'In kitchen' : 'Missing',
            tone: have ? BadgeTone.success : BadgeTone.danger,
          ),
        ],
      ),
    );
  }
}
