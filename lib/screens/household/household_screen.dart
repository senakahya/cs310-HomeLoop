import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/home_store.dart';
import '../../models/member.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/headers.dart';
import '../../widgets/member_avatar.dart';
import '../../widgets/status_badge.dart';

/// S07 · Household & members – invite code, member list, owner actions.
class HouseholdScreen extends StatelessWidget {
  const HouseholdScreen({super.key});

  Future<void> _rename(BuildContext context) async {
    final store = HomeStore.instance;
    var name = store.household?.name ?? '';
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Rename household', style: AppTextStyles.title),
        content: TextFormField(
          initialValue: name,
          onChanged: (value) => name = value,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Household name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(name.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) store.renameHousehold(newName);
  }

  /// S07·a – confirmation before removing a member.
  Future<void> _removeMember(BuildContext context, Member member) async {
    final store = HomeStore.instance;
    final balance = store.balances[member.id] ?? 0;
    final balanceText = balance.abs() >= 0.01
        ? ' and open balance (${store.currency}${balance.abs().toStringAsFixed(0)})'
        : '';
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove ${member.name}?',
      message:
          "${member.name} will lose access to ${store.household?.name ?? 'the household'}'s "
          'shopping list, inventory and expenses. Their past expenses$balanceText stay in the history.',
      confirmLabel: 'Remove',
      danger: true,
      icon: Icons.person_remove_outlined,
    );
    if (confirmed) {
      store.removeMember(member.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${member.name} was removed')));
      }
    }
  }

  Future<void> _leave(BuildContext context) async {
    final store = HomeStore.instance;
    final others = store.households.where((h) => h != store.household).toList();
    final destination = others.isEmpty
        ? 'return to household setup to create or join a household'
        : 'switch to ${others.first.name}';
    final confirmed = await showConfirmDialog(
      context,
      title: 'Leave household?',
      message:
          'You will lose access to ${store.household?.name ?? 'this household'}\'s '
          'shopping list, inventory and expenses. Past expenses and any open '
          'balances will remain in the household history.\n\n'
          'You will stay signed in and $destination. '
          'You can rejoin with an invite code.',
      confirmLabel: 'Leave household',
      danger: true,
      icon: Icons.logout_rounded,
    );
    if (confirmed && context.mounted) {
      store.leaveHousehold();
      Navigator.of(context).pushNamedAndRemoveUntil(
          store.household == null ? AppRoutes.chooseHousehold : AppRoutes.main,
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = HomeStore.instance;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final household = store.household;
            final isOwner = store.currentUser.isOwner;
            return ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
              children: [
                const ScreenHeader(title: 'Household'),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  child: Row(
                    children: [
                      const IconTile(
                        icon: Icons.home_outlined,
                        size: 46,
                        background: AppColors.primarySoft,
                        foreground: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(household?.name ?? '-',
                                style: AppTextStyles.bodyStrong
                                    .copyWith(fontSize: 16)),
                            const SizedBox(height: 2),
                            Text(
                              '${household?.currencyCode ?? ''} (${store.currency}) · ${store.members.length} members',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      if (isOwner)
                        IconButton(
                          tooltip: 'Rename',
                          onPressed: () => _rename(context),
                          icon: const Icon(Icons.edit_outlined, size: 20),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _InviteCard(code: household?.inviteCode ?? '------'),
                const SectionHeader(title: 'Members'),
                AppCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                  child: Column(
                    children: [
                      for (int i = 0; i < store.members.length; i++) ...[
                        if (i > 0) const RowDivider(),
                        _MemberRow(
                          member: store.members[i],
                          isYou: store.members[i].id == store.currentUserId,
                          canRemove: isOwner &&
                              store.members[i].id != store.currentUserId,
                          onRemove: () =>
                              _removeMember(context, store.members[i]),
                        ),
                      ],
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                      AppSpacing.xs, AppSpacing.sm, AppSpacing.xs, 0),
                  child: Text('Only the owner can remove members.',
                      style: AppTextStyles.caption),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const Text(
                  'Leaving removes your access to this household. Your account '
                  'stays signed in, and past expenses and open balances are kept.',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Leave household',
                  icon: Icons.door_front_door_outlined,
                  style: AppButtonStyle.dangerSoft,
                  onPressed: () => _leave(context),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  final String code;
  const _InviteCard({required this.code});

  @override
  Widget build(BuildContext context) {
    final pretty = code.length == 6
        ? '${code.substring(0, 3)} ${code.substring(3)}'
        : code;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Invite code',
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.whiteMuted)),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Text(
                  pretty,
                  style: AppTextStyles.amount.copyWith(
                      color: Colors.white, fontSize: 28, letterSpacing: 3),
                ),
              ),
              IconButton.filled(
                tooltip: 'Copy code',
                style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF333A36)),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invite code copied')),
                  );
                },
                icon: const Icon(Icons.copy_rounded,
                    size: 18, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Anyone with this code can join your household.',
            style: AppTextStyles.caption.copyWith(color: AppColors.whiteMuted),
          ),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final Member member;
  final bool isYou;
  final bool canRemove;
  final VoidCallback onRemove;

  const _MemberRow({
    required this.member,
    required this.isYou,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          MemberAvatar(member: member, size: 38),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(isYou ? '${member.name} (you)' : member.name,
                style: AppTextStyles.bodyStrong),
          ),
          if (member.isOwner)
            const StatusBadge(text: 'Owner', tone: BadgeTone.success)
          else
            const Text('Member', style: AppTextStyles.caption),
          if (canRemove)
            PopupMenuButton<String>(
              tooltip: 'Member options',
              icon: const Icon(Icons.more_vert_rounded, color: AppColors.muted),
              onSelected: (_) => onRemove(),
              itemBuilder: (context) => const [
                PopupMenuItem(
                    value: 'remove', child: Text('Remove from household')),
              ],
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}
