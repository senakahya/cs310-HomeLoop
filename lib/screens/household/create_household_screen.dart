import 'package:flutter/material.dart';

import '../../data/home_store.dart';
import '../../models/household.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/bottom_actions.dart';
import '../../widgets/feedback_widgets.dart';
import '../../widgets/headers.dart';
import '../../widgets/inputs.dart';

/// S04 · Create household – name + currency. The creator becomes the owner.
class CreateHouseholdScreen extends StatefulWidget {
  const CreateHouseholdScreen({super.key});

  @override
  State<CreateHouseholdScreen> createState() => _CreateHouseholdScreenState();
}

class _CreateHouseholdScreenState extends State<CreateHouseholdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  Currency _currency = Currency.all.first;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _create() {
    if (!_formKey.currentState!.validate()) return;
    HomeStore.instance.createHousehold(_name.text.trim(), _currency);
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
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
              const Text('Create a household', style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Give your home a name and pick the currency for shared expenses.',
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppTextField(
                label: 'Household name',
                controller: _name,
                hint: 'e.g. Sunny Flat',
                icon: Icons.home_outlined,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Give your household a name';
                  if (value.length > 30) return 'Use 30 characters or fewer';
                  return null;
                },
              ),
              const FieldLabel('Currency'),
              ChoiceChipsField<Currency>(
                options: Currency.all,
                selected: _currency,
                labelOf: (c) => '${c.code} ${c.symbol}',
                onChanged: (c) => setState(() => _currency = c),
              ),
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xs, top: 6),
                child: Text(
                    '${_currency.name} is used for every expense in this household.',
                    style: AppTextStyles.caption),
              ),
              const SizedBox(height: AppSpacing.xl),
              const InfoNote(
                text:
                    "You'll be the owner. After creating, share the invite code from Household settings so others can join.",
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomActions(
        children: [
          Expanded(
            child: AppButton(
              label: 'Cancel',
              style: AppButtonStyle.secondary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
              flex: 2,
              child: AppButton(label: 'Create household', onPressed: _create)),
        ],
      ),
    );
  }
}
