/// One ingredient line of a recipe, e.g. "Yogurt · 200 g".
class RecipeIngredient {
  final String name;
  final double amount;
  final String unit;

  const RecipeIngredient(this.name, this.amount, this.unit);
}

/// A recipe suggested by the recipe assistant (S20 / S21).
class Recipe {
  final String id;
  final String title;
  final int minutes;
  final int servings;
  final bool vegetarian;
  final List<RecipeIngredient> ingredients;
  final List<String> steps;

  const Recipe({
    required this.id,
    required this.title,
    required this.minutes,
    required this.servings,
    required this.vegetarian,
    required this.ingredients,
    required this.steps,
  });
}

/// How well a recipe fits the food that is at home right now.
class RecipeMatch {
  final Recipe recipe;

  /// Ingredients that are in the kitchen inventory.
  final List<RecipeIngredient> available;

  /// Ingredients the household still has to buy.
  final List<RecipeIngredient> missing;

  /// Names of available ingredients that expire within 3 days.
  final List<String> expiringUsed;

  const RecipeMatch({
    required this.recipe,
    required this.available,
    required this.missing,
    required this.expiringUsed,
  });

  bool get readyToCook => missing.isEmpty;
}
