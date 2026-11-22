import 'package:flutter/material.dart';

import '../../data/formatters.dart';
import '../../data/home_store.dart';
import '../../data/recipe_assistant.dart';
import '../../models/recipe.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/feedback_widgets.dart';
import '../../widgets/headers.dart';
import '../../widgets/inputs.dart';
import '../../widgets/status_badge.dart';
import 'recipe_card.dart';

/// One message in the recipe chat.
class _ChatMessage {
  final bool fromUser;
  final String text;
  final List<RecipeMatch> recipes;

  const _ChatMessage({required this.fromUser, required this.text, this.recipes = const []});
}

/// S20 · Recipe ideas – chat with the recipe assistant.
/// Food that expires soon is used first. When the assistant cannot be
/// reached, the "unavailable" state S20·a is shown instead.
class RecipeIdeasScreen extends StatefulWidget {
  const RecipeIdeasScreen({super.key});

  @override
  State<RecipeIdeasScreen> createState() => _RecipeIdeasScreenState();
}

class _RecipeIdeasScreenState extends State<RecipeIdeasScreen> {
  final RecipeAssistant _assistant = RecipeAssistant.instance;
  final HomeStore _store = HomeStore.instance;
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<_ChatMessage> _messages = [];

  bool _thinking = false;
  bool _unavailable = false;

  static const List<String> _quickPrompts = [
    'Something vegetarian',
    'Quick, under 20 min',
    'Use what expires first',
  ];

  @override
  void initState() {
    super.initState();
    _loadWelcome();
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  List<String> get _shownIds =>
      [for (final m in _messages) for (final r in m.recipes) r.recipe.id];

  Future<void> _loadWelcome() async {
    setState(() {
      _thinking = true;
      _unavailable = false;
    });
    try {
      final reply = await _assistant.welcome();
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..add(_ChatMessage(fromUser: false, text: reply.message, recipes: reply.recipes));
      });
    } on RecipeAssistantUnavailable {
      if (mounted) setState(() => _unavailable = true);
    } finally {
      if (mounted) setState(() => _thinking = false);
    }
  }

  Future<void> _send(String text) async {
    final question = text.trim();
    if (question.isEmpty || _thinking) return;
    _input.clear();
    setState(() {
      _messages.add(_ChatMessage(fromUser: true, text: question));
      _thinking = true;
    });
    _scrollToEnd();
    try {
      final reply = await _assistant.ask(question, alreadyShown: _shownIds);
      if (!mounted) return;
      setState(() => _messages.add(_ChatMessage(fromUser: false, text: reply.message, recipes: reply.recipes)));
    } on RecipeAssistantUnavailable {
      if (mounted) setState(() => _unavailable = true);
    } finally {
      if (mounted) setState(() => _thinking = false);
    }
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _openRecipe(RecipeMatch match) {
    Navigator.of(context).pushNamed(AppRoutes.recipeDetail, arguments: match.recipe);
  }

  void _toggleOffline() {
    setState(() => _assistant.simulateOffline = !_assistant.simulateOffline);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_assistant.simulateOffline
          ? 'Demo: the assistant is now offline'
          : 'Demo: the assistant is back online'),
    ));
    if (!_assistant.simulateOffline && _unavailable) _loadWelcome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
              child: ScreenHeader(
                title: 'Recipe ideas',
                actions: [
                  PopupMenuButton<String>(
                    tooltip: 'Demo options',
                    icon: const Icon(Icons.more_vert_rounded),
                    onSelected: (_) => _toggleOffline(),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'offline',
                        child: Text(_assistant.simulateOffline
                            ? 'Demo: go back online'
                            : 'Demo: simulate no connection'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: _store,
                builder: (context, _) => ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.xs, AppSpacing.screen, AppSpacing.lg),
                  children: [
                    _KitchenContext(store: _store),
                    const SizedBox(height: AppSpacing.md),
                    if (_unavailable)
                      _UnavailableState(store: _store, onRetry: _loadWelcome) // S20·a
                    else ...[
                      for (final m in _messages) ...[
                        if (m.fromUser) _UserBubble(text: m.text) else _AssistantBubble(text: m.text),
                        for (final r in m.recipes)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: RecipeCard(match: r, onTap: () => _openRecipe(r)),
                          ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      if (_thinking) const _ThinkingBubble(),
                    ],
                  ],
                ),
              ),
            ),
            _Composer(
              controller: _input,
              enabled: !_unavailable && !_thinking,
              prompts: _quickPrompts,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _KitchenContext extends StatelessWidget {
  final HomeStore store;
  const _KitchenContext({required this.store});

  @override
  Widget build(BuildContext context) {
    final expiring = store.expiringSoon;
    final others = store.inventory.length - expiring.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.amberSoft, borderRadius: BorderRadius.circular(AppRadius.card)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.kitchen_outlined, size: 16, color: AppColors.amberText),
              const SizedBox(width: 6),
              Text(
                'Based on your kitchen · ${store.inventory.length} items',
                style: AppTextStyles.label.copyWith(color: AppColors.amberText, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          if (expiring.isNotEmpty || others > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final item in expiring.take(3))
                  _ContextChip(
                    text: '${item.name} · ${Fmt.expiry(item.nextExpiry).toLowerCase()}',
                    color: Fmt.daysFromToday(item.nextExpiry!) <= 1 ? AppColors.red : AppColors.amberText,
                  ),
                if (others > 0) _ContextChip(text: '+$others more', color: AppColors.muted),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ContextChip extends StatelessWidget {
  final String text;
  final Color color;
  const _ContextChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(text, style: AppTextStyles.badge.copyWith(color: color)),
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  final String text;
  const _AssistantBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
          child: const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.accent),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Text(text, style: AppTextStyles.caption.copyWith(color: AppColors.ink2, fontSize: 13, height: 1.45)),
          ),
        ),
      ],
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String text;
  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(left: 48),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: const BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(text, style: AppTextStyles.caption.copyWith(color: Colors.white, fontSize: 13)),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ),
        SizedBox(width: AppSpacing.sm),
        Text('Finding recipes…', style: AppTextStyles.caption),
      ],
    );
  }
}

/// S20·a – the assistant cannot be reached.
class _UnavailableState extends StatelessWidget {
  final HomeStore store;
  final VoidCallback onRetry;
  const _UnavailableState({required this.store, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final soon = store.expiringSoon.where((i) => Fmt.daysFromToday(i.nextExpiry!) >= 0).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const InfoNote(
          tone: NoteTone.error,
          title: "Can't reach the recipe assistant.",
          text: 'Recipe ideas need an internet connection. Your inventory is still saved.',
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(label: 'Try again', icon: Icons.refresh_rounded, style: AppButtonStyle.secondary, onPressed: onRetry),
        if (soon.isNotEmpty) ...[
          const SectionHeader(title: 'Use these soon'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            child: Column(
              children: [
                for (int i = 0; i < soon.length; i++) ...[
                  if (i > 0) const RowDivider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(soon[i].name, style: AppTextStyles.bodyStrong),
                              Text('${Fmt.qty(soon[i].totalQuantity)} ${soon[i].unit}', style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        StatusBadge.expiry(soon[i].nextExpiry),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final List<String> prompts;
  final ValueChanged<String> onSend;

  const _Composer({
    required this.controller,
    required this.enabled,
    required this.prompts,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.sm, AppSpacing.screen, AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < prompts.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  PillChip(label: prompts[i], onTap: enabled ? () => onSend(prompts[i]) : null),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  textInputAction: TextInputAction.send,
                  onSubmitted: onSend,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    hintText: 'Ask for a recipe…',
                    hintStyle: AppTextStyles.body.copyWith(color: AppColors.faint),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      borderSide: const BorderSide(color: AppColors.line, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      borderSide: const BorderSide(color: AppColors.line, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              CircleIconButton(
                icon: Icons.arrow_upward_rounded,
                dark: true,
                tooltip: 'Send',
                onTap: enabled ? () => onSend(controller.text) : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'AI suggestions – check ingredients and allergies.',
            style: AppTextStyles.caption.copyWith(fontSize: 10.5, color: AppColors.faint),
          ),
        ],
      ),
    );
  }
}
