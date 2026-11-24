import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku/models/recipe.dart';
import 'package:resepku/services/recipe_service.dart';
import 'package:resepku/widgets/error_view.dart';
import 'package:resepku/widgets/recipe_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Future<List<Recipe>>? _searchFuture;
  String _query = '';

  void _search(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _query = trimmed;
      _searchFuture = context.read<RecipeService>().searchRecipes(trimmed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Cari resep',
            border: InputBorder.none,
          ),
          onSubmitted: _search,
        ),
      ),
      body: _searchFuture == null
          ? const Center(child: Text('Masukkan kata kunci pencarian.'))
          : FutureBuilder<List<Recipe>>(
              future: _searchFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return ErrorView(
                    message: 'Gagal mencari "$_query".\n${snapshot.error}',
                    onRetry: () => _search(_query),
                  );
                }
                final recipes = snapshot.data ?? [];
                if (recipes.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada resep yang ditemukan.'),
                  );
                }
                return ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) =>
                      RecipeTile(recipe: recipes[index]),
                );
              },
            ),
    );
  }
}
