import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:resepku/main.dart';
import 'package:resepku/providers/favorite_provider.dart';
import 'package:resepku/providers/theme_provider.dart';
import 'package:resepku/services/recipe_service.dart';

Widget buildTestApp() {
  final client = MockClient((request) async {
    if (request.url.path.endsWith('/recipes')) {
      return http.Response(
        jsonEncode({
          'recipes': [
            {
              'id': 1,
              'name': 'Classic Margherita Pizza',
              'cuisine': 'Italian',
              'difficulty': 'Easy',
              'prepTimeMinutes': 20,
              'cookTimeMinutes': 15,
              'servings': 4,
              'caloriesPerServing': 300,
              'rating': 4.6,
              'image': '',
              'ingredients': ['Pizza dough'],
              'instructions': ['Bake the pizza'],
            },
            {
              'id': 2,
              'name': 'Vegetarian Stir-Fry',
              'cuisine': 'Asian',
              'difficulty': 'Medium',
              'prepTimeMinutes': 15,
              'cookTimeMinutes': 20,
              'servings': 3,
              'caloriesPerServing': 250,
              'rating': 5,
              'image': '',
              'ingredients': ['Tofu'],
              'instructions': ['Stir-fry the tofu'],
            },
          ],
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    return http.Response(jsonEncode({'isDeleted': true}), 200);
  });

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      Provider<RecipeService>.value(value: RecipeService(client: client)),
    ],
    child: const ResepKuApp(),
  );
}

void main() {
  testWidgets('loads recipes and toggles grid view', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Classic Margherita Pizza'), findsOneWidget);
    await tester.tap(find.byTooltip('Tampilan grid'));
    await tester.pump();
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('opens detail and shows ingredients and instructions', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Classic Margherita Pizza'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Bahan'), findsOneWidget);
    expect(find.text('Pizza dough'), findsOneWidget);
    expect(find.text('Langkah'), findsOneWidget);
    expect(find.text('Bake the pizza'), findsOneWidget);
  });
}
