import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';

/// S03 · Choose household – first step for a user without a household.
class ChooseHouseholdScreen extends StatelessWidget {
  const ChooseHouseholdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          children: [
            const SizedBox(height: AppSpacing.xxl),
            // LOCAL image (Step 2.2 requirement) – assets/images/household_illustration.png
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: AspectRatio(
                aspectRatio: 2,
                child: Image.asset(
                  'assets/images/household_illustration.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const Text('Set up your home', style: AppTextStyles.display),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'HomeLoop works around a shared household. Create one, or join your housemates with their invite code.',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: AppSpacing.xxl),
            _OptionCard(
              icon: Icons.add_home_outlined,
              title: 'Create a household',
              subtitle: "Start fresh and invite others. You'll be the owner.",
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.createHousehold),
            ),
            const SizedBox(height: AppSpacing.md),
            _OptionCard(
              icon: Icons.key_outlined,
              title: 'Join with a code',
              subtitle: 'Enter the 6-digit code from a member.',
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.joinHousehold),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            Center(
              child: TextButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.profile),
                icon: const Icon(Icons.person_outline_rounded,
                    size: 17, color: AppColors.muted),
                label: Text('Profile',
                    style: AppTextStyles.bodyMuted.copyWith(fontSize: 13.5)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          IconTile(
              icon: icon,
              size: 48,
              background: AppColors.primarySoft,
              foreground: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyStrong.copyWith(fontSize: 15.5)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: AppTextStyles.caption.copyWith(fontSize: 12.5)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.faint),
        ],
      ),
    );
  }
}
