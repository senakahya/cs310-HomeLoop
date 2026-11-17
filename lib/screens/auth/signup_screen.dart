import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/headers.dart';
import 'auth_validators.dart';

/// S02 · Sign up (UI only). Invalid fields show inline errors (S02·a).
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _createAccount() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.chooseHousehold, (route) => false);
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
              const ScreenHeader(),
              const SizedBox(height: AppSpacing.sm),
              const Text('Create your account', style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.sm),
              const Text('One account for every household you join.', style: AppTextStyles.bodyMuted),
              const SizedBox(height: AppSpacing.xxl),
              AppTextField(
                label: 'Full name',
                controller: _name,
                hint: 'Your name',
                icon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
                validator: AuthValidators.name,
              ),
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
                hint: 'At least 8 characters',
                helper: 'At least 8 characters',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                textInputAction: TextInputAction.next,
                validator: AuthValidators.newPassword,
              ),
              AppTextField(
                label: 'Confirm password',
                controller: _confirm,
                hint: 'Repeat your password',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                textInputAction: TextInputAction.done,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Repeat your password';
                  if (v != _password.text) return "Passwords don't match";
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(label: 'Create account', onPressed: _createAccount),
              const SizedBox(height: AppSpacing.xxl),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('Already have an account? ', style: AppTextStyles.bodyMuted),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        'Log in',
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
