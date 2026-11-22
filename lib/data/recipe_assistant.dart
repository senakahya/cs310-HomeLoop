import '../models/recipe.dart';
import 'formatters.dart';
import 'home_store.dart';

/// Thrown when the assistant cannot be reached (S20·a).
class RecipeAssistantUnavailable implements Exception {
  const RecipeAssistantUnavailable();
}

/// The answer of the assistant to one question.
class AssistantReply {
  final String message;
  final List<RecipeMatch> recipes;

  const AssistantReply(this.message, this.recipes);
}

/// Recipe ideas based on the kitchen inventory (proposal feature 7).
///
/// Step 2.2: this is a PLACEHOLDER. It picks recipes from a small built-in
/// list and ranks them so that food which expires soon is used first.
/// Step 3: the same methods will call Gemini through Firebase, so the screens
/// do not have to change (the API key never ships inside the app).
class RecipeAssistant {
  RecipeAssistant._();

  static final RecipeAssistant instance = RecipeAssistant._();

  /// Demo switch to show the "no connection" state (S20·a).
  bool simulateOffline = false;

  final HomeStore _store = HomeStore.instance;

  /// Checks which ingredients of [recipe] are at home and which expire soon.
  RecipeMatch match(Recipe recipe) {
    final available = <RecipeIngredient>[];
    final missing = <RecipeIngredient>[];
    final expiring = <String>[];
    for (final ingredient in recipe.ingredients) {
      final item = _store.inventory.where(
        (i) => i.name.toLowerCase() == ingredient.name.toLowerCase(),
      );
      if (item.isEmpty) {
        missing.add(ingredient);
        continue;
      }
      available.add(ingredient);
      final next = item.first.nextExpiry;
      if (next != null && Fmt.daysFromToday(next) <= 3) {
        expiring.add(ingredient.name);
      }
    }
    return RecipeMatch(
      recipe: recipe,
      available: available,
      missing: missing,
      expiringUsed: expiring,
    );
  }

  /// Recipes ranked for today: expiring food first, then fewest missing items.
  List<RecipeMatch> rank({bool vegetarianOnly = false, bool quickOnly = false}) {
    final matches = <RecipeMatch>[];
    for (final recipe in _catalog) {
      if (vegetarianOnly && !recipe.vegetarian) continue;
      if (quickOnly && recipe.minutes > 20) continue;
      final m = match(recipe);
      if (m.available.isEmpty) continue;
      matches.add(m);
    }
    int score(RecipeMatch m) =>
        m.expiringUsed.length * 3 + m.available.length - m.missing.length * 2;
    matches.sort((a, b) => score(b).compareTo(score(a)));
    return matches;
  }

  /// First message when the screen opens.
  Future<AssistantReply> welcome() async {
    await _fakeNetworkDelay();
    final expiring = _store.expiringSoon;
    final ideas = rank().take(2).toList();
    if (_store.inventory.isEmpty) {
      return const AssistantReply(
        'Your inventory is empty. Add the food you have at home and I will suggest recipes.',
        [],
      );
    }
    if (expiring.isEmpty) {
      return AssistantReply('Nothing expires soon. Here are ideas with what you have:', ideas);
    }
    final parts = expiring
        .take(2)
        .map((i) => '${i.name} expires ${Fmt.expiry(i.nextExpiry).toLowerCase()}')
        .join(' and ');
    return AssistantReply('$parts. Here are ideas for today:', ideas);
  }

  /// Answers a typed question or a quick filter.
  Future<AssistantReply> ask(String question, {List<String> alreadyShown = const []}) async {
    await _fakeNetworkDelay();
    final q = question.toLowerCase();
    final vegetarian = q.contains('vegetarian') || q.contains('veggie') ||
        q.contains('without meat') || q.contains('no meat');
    final quick = q.contains('quick') || q.contains('fast') || q.contains('20 min');

    var ideas = rank(vegetarianOnly: vegetarian, quickOnly: quick);
    final fresh = ideas.where((m) => !alreadyShown.contains(m.recipe.id)).toList();
    if (fresh.isNotEmpty) ideas = fresh;
    ideas = ideas.take(2).toList();

    if (ideas.isEmpty) {
      return const AssistantReply(
        "I couldn't find a recipe for that with the food you have. Try another idea.",
        [],
      );
    }
    String intro = 'Here are more ideas:';
    if (vegetarian && quick) {
      intro = 'Quick vegetarian ideas:';
    } else if (vegetarian) {
      intro = 'Vegetarian ideas from your kitchen:';
    } else if (quick) {
      intro = 'Ready in 20 minutes or less:';
    } else if (q.contains('expir')) {
      intro = 'These use the food that expires first:';
    }
    return AssistantReply(intro, ideas);
  }

  Future<void> _fakeNetworkDelay() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (simulateOffline) throw const RecipeAssistantUnavailable();
  }

  static const List<Recipe> _catalog = [
    Recipe(
      id: 'r1',
      title: 'Yogurt pancakes',
      minutes: 20,
      servings: 2,
      vegetarian: true,
      ingredients: [
        RecipeIngredient('Yogurt', 200, 'g'),
        RecipeIngredient('Milk', 150, 'mL'),
        RecipeIngredient('Eggs', 2, 'pcs'),
        RecipeIngredient('Flour', 150, 'g'),
        RecipeIngredient('Baking powder', 1, 'tsp'),
      ],
      steps: [
        'Whisk the yogurt, milk and eggs in a bowl.',
        'Fold in the flour and baking powder until just combined.',
        'Cook small ladles of batter in a hot pan, 2 minutes per side.',
        'Serve warm with honey or fruit.',
      ],
    ),
    Recipe(
      id: 'r2',
      title: 'Chicken & rice bowl',
      minutes: 35,
      servings: 3,
      vegetarian: false,
      ingredients: [
        RecipeIngredient('Chicken breast', 400, 'g'),
        RecipeIngredient('Rice', 200, 'g'),
        RecipeIngredient('Tomato paste', 1, 'tbsp'),
      ],
      steps: [
        'Rinse the rice and cook it in salted water.',
        'Cut the chicken into cubes and brown it in a pan.',
        'Stir in the tomato paste with a splash of water and simmer for 10 minutes.',
        'Serve the chicken over the rice.',
      ],
    ),
    Recipe(
      id: 'r3',
      title: 'Tomato & egg skillet',
      minutes: 15,
      servings: 2,
      vegetarian: true,
      ingredients: [
        RecipeIngredient('Eggs', 4, 'pcs'),
        RecipeIngredient('Tomato paste', 1, 'tbsp'),
        RecipeIngredient('Tomatoes', 2, 'pcs'),
        RecipeIngredient('Bread', 1, 'loaf'),
      ],
      steps: [
        'Cook the chopped tomatoes with the tomato paste for 5 minutes.',
        'Crack in the eggs and stir gently until just set.',
        'Serve straight from the pan with bread.',
      ],
    ),
    Recipe(
      id: 'r4',
      title: 'Creamy rice pudding',
      minutes: 40,
      servings: 4,
      vegetarian: true,
      ingredients: [
        RecipeIngredient('Milk', 1, 'L'),
        RecipeIngredient('Rice', 100, 'g'),
        RecipeIngredient('Sugar', 120, 'g'),
      ],
      steps: [
        'Simmer the rice in a little water until soft.',
        'Add the milk and cook on low heat for 25 minutes, stirring often.',
        'Stir in the sugar, pour into bowls and chill.',
      ],
    ),
    Recipe(
      id: 'r5',
      title: 'Yogurt-marinated chicken',
      minutes: 45,
      servings: 3,
      vegetarian: false,
      ingredients: [
        RecipeIngredient('Chicken breast', 500, 'g'),
        RecipeIngredient('Yogurt', 150, 'g'),
        RecipeIngredient('Tomato paste', 1, 'tbsp'),
        RecipeIngredient('Garlic', 2, 'cloves'),
      ],
      steps: [
        'Mix the yogurt, tomato paste and crushed garlic.',
        'Coat the chicken and leave it for 20 minutes.',
        'Bake at 200 °C for 25 minutes.',
      ],
    ),
    Recipe(
      id: 'r6',
      title: 'Overnight oats',
      minutes: 10,
      servings: 2,
      vegetarian: true,
      ingredients: [
        RecipeIngredient('Milk', 200, 'mL'),
        RecipeIngredient('Yogurt', 100, 'g'),
        RecipeIngredient('Oats', 100, 'g'),
      ],
      steps: [
        'Mix the oats, milk and yogurt in a jar.',
        'Leave in the fridge overnight.',
        'Top with fruit in the morning.',
      ],
    ),
  ];
}
