import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/home_store.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/bottom_actions.dart';
import '../../widgets/headers.dart';

/// S05 · Join household with a 6-digit invite code.
/// A wrong code shows the error state S05·a. (Demo code: 482913)
class JoinHouseholdScreen extends StatefulWidget {
  const JoinHouseholdScreen({super.key});

  @override
  State<JoinHouseholdScreen> createState() => _JoinHouseholdScreenState();
}

class _JoinHouseholdScreenState extends State<JoinHouseholdScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _invalid = false;

  @override
  void initState() {
    super.initState();
    // Rebuild when the hidden field gains/loses focus (to highlight the active box).
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _join() {
    final ok = HomeStore.instance.joinHousehold(_controller.text);
    if (!ok) {
      setState(() => _invalid = true); // S05·a
      return;
    }
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final code = _controller.text;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          children: [
            const ScreenHeader(),
            const SizedBox(height: AppSpacing.sm),
            const Text('Join a household', style: AppTextStyles.display),
            const SizedBox(height: AppSpacing.sm),
            const Text('Enter the invite code a member shared with you.',
                style: AppTextStyles.bodyMuted),
            const SizedBox(height: AppSpacing.xxl),
            const Padding(
              padding: EdgeInsets.only(left: AppSpacing.xs, bottom: 8),
              child: Text('Invite code', style: AppTextStyles.label),
            ),
            // The real text field is invisible; the six boxes show what was typed.
            Stack(
              children: [
                GestureDetector(
                  onTap: () => _focus.requestFocus(),
                  child: Row(
                    children: [
                      for (int i = 0; i < 6; i++) ...[
                        if (i > 0) const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _CodeBox(
                            digit: i < code.length ? code[i] : '',
                            active: _focus.hasFocus && i == code.length,
                            error: _invalid,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Positioned.fill(
                  child: Opacity(
                    opacity: 0,
                    child: TextField(
                      controller: _controller,
                      focusNode: _focus,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      showCursor: false,
                      enableInteractiveSelection: false,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() => _invalid = false),
                      onSubmitted: (_) {
                        if (_controller.text.length == 6) _join();
                      },
                      decoration: const InputDecoration(
                          counterText: '', border: InputBorder.none),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_invalid)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 15, color: AppColors.red),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "This code doesn't match any household. Check it and try again.",
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.red, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              )
            else
              const Padding(
                padding: EdgeInsets.only(left: AppSpacing.xs),
                child: Text(
                  'Codes are 6 digits. The owner can find it in Household settings.',
                  style: AppTextStyles.caption,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomActions(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppButton(
                    label: 'Join household',
                    onPressed: code.length == 6 ? _join : null),
                const SizedBox(height: AppSpacing.xs),
                AppButton(
                  label: 'Cancel',
                  style: AppButtonStyle.text,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  final String digit;
  final bool active;
  final bool error;

  const _CodeBox(
      {required this.digit, required this.active, required this.error});

  @override
  Widget build(BuildContext context) {
    Color border = AppColors.line;
    if (error) {
      border = AppColors.red;
    } else if (active) {
      border = AppColors.primary;
    }
    return Container(
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Text(digit, style: AppTextStyles.title),
    );
  }
}
