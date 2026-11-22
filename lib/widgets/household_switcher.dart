import 'package:flutter/material.dart';

import '../data/home_store.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// The name opens settings; the separate arrow switches the active household.
class HouseholdSwitcher extends StatelessWidget {
  const HouseholdSwitcher({super.key});

  void _select(BuildContext context, String value) {
    // Undo actions belong to the home in which they were created.
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..removeCurrentSnackBar();
    if (value == AppRoutes.createHousehold ||
        value == AppRoutes.joinHousehold) {
      Navigator.of(context).pushNamed(value);
      return;
    }
    final store = HomeStore.instance;
    if (value == store.household?.inviteCode) return;
    if (store.switchHousehold(value)) {
      // Reset tab selections and the previous household's navigation history.
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = HomeStore.instance;
    return Material(
      color: AppColors.surface,
      shape: const StadiumBorder(side: BorderSide(color: AppColors.line)),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Tooltip(
              message: 'View household',
              child: InkWell(
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.household),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 10, 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.home_outlined, size: 18),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          store.household?.name ?? 'Household',
                          style: AppTextStyles.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 24,
            child: VerticalDivider(width: 1, color: AppColors.line),
          ),
          PopupMenuButton<String>(
            tooltip: 'Switch household',
            position: PopupMenuPosition.under,
            icon: const Icon(Icons.expand_more_rounded, size: 20),
            onSelected: (value) => _select(context, value),
            itemBuilder: (_) => [
              const PopupMenuItem<String>(
                enabled: false,
                child: Text('Your households'),
              ),
              for (final household in store.households)
                CheckedPopupMenuItem<String>(
                  value: household.inviteCode,
                  checked: household == store.household,
                  child: Text(household.name),
                ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: AppRoutes.createHousehold,
                child: Text('Create a household'),
              ),
              const PopupMenuItem<String>(
                value: AppRoutes.joinHousehold,
                child: Text('Join with a code'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
