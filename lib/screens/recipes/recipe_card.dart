import 'package:flutter/material.dart';

import '../../models/recipe.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';

/// Placeholder picture of a recipe (real photos can come with the AI answer later).
class RecipePicture extends StatelessWidget {
  final double size;
  final double radius;
  const RecipePicture({super.key, this.size = 62, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.amberSoft, AppColors.primarySoft],
        ),
      ),
      child: Icon(Icons.restaurant_menu_rounded, color: AppColors.amber, size: size * 0.42),
    );
  }
}

/// A suggested recipe inside the chat (S20).
class RecipeCard extends StatelessWidget {
  final RecipeMatch match;
  final VoidCallback onTap;

  const RecipeCard({super.key, required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final r = match.recipe;
    final meta = '${r.minutes} min · ${r.servings} servings${r.vegetarian ? ' · vegetarian' : ''}';
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RecipePicture(),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(r.title, style: AppTextStyles.bodyStrong)),
                    const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.faint),
                  ],
                ),
                Text(meta, style: AppTextStyles.caption.copyWith(fontSize: 11.5)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Uses: ${match.available.map((i) => i.name).join(', ')}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(color: AppColors.ink2, fontSize: 11.5),
                ),
                if (match.missing.isNotEmpty)
                  Text(
                    'Missing: ${match.missing.map((i) => i.name).join(', ')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(color: AppColors.red, fontSize: 11.5),
                  )
                else
                  Text(
                    'Everything is in your kitchen',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 11.5),
                  ),
                const SizedBox(height: 6),
                if (match.expiringUsed.isNotEmpty)
                  StatusBadge(
                    text: 'Uses ${match.expiringUsed.length} expiring item${match.expiringUsed.length == 1 ? '' : 's'}',
                    tone: BadgeTone.warning,
                  )
                else if (match.readyToCook)
                  const StatusBadge(text: 'Ready to cook', tone: BadgeTone.success),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
