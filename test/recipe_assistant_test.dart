import 'package:flutter_test/flutter_test.dart';
import 'package:homeloop/data/recipe_assistant.dart';

void main() {
  final assistant = RecipeAssistant.instance;

  test('Ideas that use food expiring soon come first', () {
    final ideas = assistant.rank();
    expect(ideas, isNotEmpty);
    expect(ideas.first.expiringUsed, isNotEmpty);
  });

  test('Missing ingredients are detected', () {
    final pancakes = assistant.rank().firstWhere((m) => m.recipe.title == 'Yogurt pancakes');
    final missing = pancakes.missing.map((i) => i.name).toList();
    expect(missing, containsAll(['Flour', 'Baking powder']));
    expect(pancakes.readyToCook, isFalse);
  });

  test('Vegetarian filter only returns vegetarian recipes', () {
    final ideas = assistant.rank(vegetarianOnly: true);
    expect(ideas.every((m) => m.recipe.vegetarian), isTrue);
  });

  test('Offline mode shows the unavailable state', () async {
    assistant.simulateOffline = true;
    await expectLater(assistant.welcome(), throwsA(isA<RecipeAssistantUnavailable>()));
    assistant.simulateOffline = false;
  });
}
