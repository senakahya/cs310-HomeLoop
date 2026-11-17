import 'package:flutter/material.dart';

import '../models/member.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Round avatar of a member.
/// The picture is a NETWORK image; while it loads, or if there is no
/// internet, the member's initial on their colour is shown instead.
class MemberAvatar extends StatelessWidget {
  final Member member;
  final double size;
  final bool selected;

  const MemberAvatar({
    super.key,
    required this.member,
    this.size = 36,
    this.selected = false,
  });

  Widget _initialCircle() {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: member.color, shape: BoxShape.circle),
      child: Text(
        member.initial,
        style: AppTextStyles.number.copyWith(color: Colors.white, fontSize: size * 0.42),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatar = ClipOval(
      child: Image.network(
        member.avatarUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) => progress == null ? child : _initialCircle(),
        errorBuilder: (context, error, stack) => _initialCircle(),
      ),
    );
    if (!selected) return avatar;
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: avatar,
      ),
    );
  }
}

/// Small overlapping row of avatars (e.g. "split between 4 members").
class AvatarStack extends StatelessWidget {
  final List<Member> members;
  final double size;

  const AvatarStack({super.key, required this.members, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: members.isEmpty ? 0 : size + (members.length - 1) * size * 0.75,
      child: Stack(
        children: [
          for (int i = 0; i < members.length; i++)
            Positioned(
              left: i * size * 0.75,
              child: Container(
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                padding: const EdgeInsets.all(1.5),
                child: MemberAvatar(member: members[i], size: size - 3),
              ),
            ),
        ],
      ),
    );
  }
}
