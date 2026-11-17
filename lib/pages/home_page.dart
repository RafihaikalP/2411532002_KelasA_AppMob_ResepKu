import 'package:flutter/material.dart';
import 'package:resepku/data/dummy_recipes.dart';
import 'package:resepku/models/recipe.dart';
import 'package:resepku/pages/settings_page.dart';
import 'package:resepku/widgets/favorite_badge_button.dart';
import 'package:resepku/widgets/recipe_grid_card.dart';
import 'package:resepku/widgets/recipe_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isGrid = false;
  String? _cuisine;

  Widget _buildList(List<Recipe> recipes) {
    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) => RecipeTile(recipe: recipes[index]),
    );
  }

  Widget _buildGrid(List<Recipe> recipes) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) => RecipeGridCard(recipe: recipes[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cuisines = dummyRecipes.map((recipe) => recipe.cuisine).toSet();
    final recipes = _cuisine == null
        ? dummyRecipes
        : dummyRecipes.where((recipe) => recipe.cuisine == _cuisine).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Text('ResepKu'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Pengaturan',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            ),
          ),
          IconButton(
            tooltip: _isGrid ? 'Tampilan daftar' : 'Tampilan grid',
            icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
          const FavoriteBadgeButton(),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: _cuisine == null,
                  onSelected: (_) => setState(() => _cuisine = null),
                ),
                for (final cuisine in cuisines)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(cuisine),
                      selected: _cuisine == cuisine,
                      onSelected: (_) => setState(() => _cuisine = cuisine),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: _isGrid ? _buildGrid(recipes) : _buildList(recipes)),
        ],
      ),
    );
  }
}
