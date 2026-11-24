import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:resepku/models/recipe.dart';
import 'package:resepku/services/recipe_service.dart';

void main() {
  test('Recipe.fromJson converts int rating and default fields', () {
    final recipe = Recipe.fromJson({
      'id': 99,
      'name': 'Rendang',
      'rating': 5,
    });

    expect(recipe.rating, 5.0);
    expect(recipe.cuisine, '-');
    expect(recipe.ingredients, isEmpty);
  });

  test('fetchRecipes decodes a mock response', () async {
    final service = RecipeService(
      client: MockClient((request) async => http.Response(
        jsonEncode({
          'recipes': [
            {
              'id': 1,
              'name': 'Pasta',
              'cuisine': 'Italian',
              'difficulty': 'Easy',
              'prepTimeMinutes': 10,
              'cookTimeMinutes': 20,
              'servings': 2,
              'caloriesPerServing': 300,
              'rating': 5,
              'image': '',
              'ingredients': ['Pasta'],
            },
          ],
        }),
        200,
      )),
    );

    final recipes = await service.fetchRecipes();
    expect(recipes, hasLength(1));
    expect(recipes.first.name, 'Pasta');
  });

  test('fetchRecipes throws RecipeServiceException on 404', () async {
    final service = RecipeService(
      client: MockClient((request) async => http.Response('not found', 404)),
    );

    expect(
      service.fetchRecipes(),
      throwsA(isA<RecipeServiceException>()),
    );
  });
}
