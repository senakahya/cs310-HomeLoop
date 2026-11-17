import 'package:flutter/material.dart';

import '../../data/home_store.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/feedback_widgets.dart';
import 'auth_validators.dart';

/// S01 · Login (UI only in Step 2.2 – Firebase Auth comes in Step 3).
///
/// Demo rule: any valid email + a password of at least 8 characters logs in.
/// A shorter password shows the "Incorrect email or password" banner (S01·a).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _wrongCredentials = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    setState(() => _wrongCredentials = false);
    if (!_formKey.currentState!.validate()) return;

    if (_password.text.length < 8) {
      setState(() => _wrongCredentials = true); // S01·a
      return;
    }
    final hasHousehold = HomeStore.instance.household != null;
    Navigator.of(context).pushNamedAndRemoveUntil(
      hasHousehold ? AppRoutes.main : AppRoutes.chooseHousehold,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            children: [
              const SizedBox(height: AppSpacing.xxxl),
              const _Logo(),
              const SizedBox(height: 36),
              const Text('Welcome back', style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Log in to see your shared list, kitchen and expenses.',
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: AppSpacing.xxl),
              if (_wrongCredentials) ...[
                const InfoNote(
                  tone: NoteTone.error,
                  title: 'Incorrect email or password.',
                  text: 'Check your details and try again.',
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              AppTextField(
                label: 'Email',
                controller: _email,
                hint: 'name@example.com',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: AuthValidators.email,
              ),
              AppTextField(
                label: 'Password',
                controller: _password,
                hint: 'Your password',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                textInputAction: TextInputAction.done,
                validator: (v) => (v == null || v.isEmpty) ? 'Enter your password' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(label: 'Log in', onPressed: _login),
              const SizedBox(height: 56),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: AppTextStyles.bodyMuted),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.signup),
                      child: Text(
                        'Sign up',
                        style: AppTextStyles.bodyStrong.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.home_rounded, color: AppColors.lime),
        ),
        const SizedBox(width: AppSpacing.md),
        Text('HomeLoop', style: AppTextStyles.title.copyWith(fontSize: 20)),
      ],
    );
  }
}
