import 'package:flutter/material.dart';

import '../../data/home_store.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/headers.dart';
import '../../widgets/member_avatar.dart';

/// Account details and sign out, separate from household management (S07).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = HomeStore.instance;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            children: [
              const ScreenHeader(title: 'Profile'),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                child: Row(
                  children: [
                    MemberAvatar(member: store.currentUser, size: 56),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(store.currentUser.name,
                              style: AppTextStyles.title),
                          const SizedBox(height: AppSpacing.xs),
                          const Text('Your account',
                              style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SectionHeader(title: 'Your household'),
              AppCard(
                onTap: () => Navigator.of(context).pushNamed(
                  store.household == null
                      ? AppRoutes.chooseHousehold
                      : AppRoutes.household,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.home_outlined, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(store.household?.name ?? 'Set up your home',
                              style: AppTextStyles.bodyStrong),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            store.household == null
                                ? 'Create a household or join with a code.'
                                : 'View members and household settings.',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.muted),
                  ],
                ),
              ),
              const SectionHeader(title: 'Account'),
              const Text(
                'Signing out keeps your household membership and shared data. '
                'Log in again to return to your household.',
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Sign out',
                icon: Icons.logout_rounded,
                style: AppButtonStyle.secondary,
                onPressed: () => Navigator.of(context)
                    .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
