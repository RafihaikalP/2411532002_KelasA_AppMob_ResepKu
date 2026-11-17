import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:resepku/data/dummy_recipes.dart';
import 'package:resepku/main.dart';
import 'package:resepku/pages/detail_page.dart';
import 'package:resepku/pages/favorite_page.dart';
import 'package:resepku/providers/favorite_provider.dart';
import 'package:resepku/providers/theme_provider.dart';
import 'package:resepku/widgets/recipe_tile.dart';

Widget _buildApp(FavoriteProvider favorites) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: favorites),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: const ResepKuApp(),
  );
}

void main() {
  testWidgets('cuisine filter and grid toggle preserve favorites', (
    tester,
  ) async {
    final favorites = FavoriteProvider();
    await tester.pumpWidget(_buildApp(favorites));
    await tester.pump();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Asian'));
    await tester.pump();
    expect(find.text('Vegetarian Stir-Fry'), findsOneWidget);
    expect(find.text('Classic Margherita Pizza'), findsNothing);

    await tester.tap(find.byTooltip('Tampilan grid'));
    await tester.pump();
    expect(find.byType(GridView), findsOneWidget);

    await tester.tap(find.byTooltip('Tambahkan ke favorit'));
    await tester.pump();
    expect(favorites.isFavorite(dummyRecipes[1]), isTrue);

    await tester.tap(find.byTooltip('Tampilan daftar'));
    await tester.pump();
    expect(
      find.descendant(
        of: find.byType(RecipeTile),
        matching: find.byIcon(Icons.favorite),
      ),
      findsOneWidget,
    );
  });

  testWidgets('detail page uses cached sliver image and lists ingredients', (
    tester,
  ) async {
    final favorites = FavoriteProvider();
    await tester.pumpWidget(_buildApp(favorites));
    await tester.pump();

    await tester.tap(find.text('Classic Margherita Pizza'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(DetailPage), findsOneWidget);
    expect(find.byType(SliverAppBar), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsOneWidget);
    expect(find.text('Bahan'), findsOneWidget);
    expect(find.text('Pizza dough'), findsOneWidget);
  });

  testWidgets('swiping a favorite removes it and shows its name', (
    tester,
  ) async {
    final favorites = FavoriteProvider()..toggle(dummyRecipes.first);
    await tester.pumpWidget(_buildApp(favorites));
    await tester.pump();

    await tester.tap(find.byTooltip('Favorit saya'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(FavoritePage), findsOneWidget);

    await tester.fling(find.byType(Dismissible), const Offset(-1000, 0), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(favorites.count, 0);
    expect(
      find.text('Classic Margherita Pizza dihapus dari favorit'),
      findsOneWidget,
    );
  });
}
