import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../Models/recipe_model.dart';
import '../SQFLite DB/database_sqflite.dart';
import '../provider/recipe_provider.dart';
import 'recipe_cards.dart';


class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  List<Recipe> _recipes = [];
  bool _isLoading = true;

  Future<void> checkPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  @override
  initState() {
    super.initState();
    loadRecipesFromDatabase().then((loadedRecipes) {
      setState(() {
        _recipes = loadedRecipes;
        _isLoading = false;
      });
      // Update the provider with the newly loaded recipes
      Provider.of<RecipeProvider>(context, listen: false).updateRecipes(_recipes);
    });
  }

  // Future<void> loadRecipes() async {
  //   final db = await DatabaseHelper().database; // Assuming DatabaseHelper is correctly set up to provide an instance
  //   final List<Map<String, dynamic>> recipeMaps = await db.query('Recipes');
  //   setState(() {
  //     _recipes = recipeMaps.map((recipeMap) => Recipe.fromMap(recipeMap)).toList();
  //     _isLoading = false;
  //   });
  // }

  Future<List<Recipe>> loadRecipesFromDatabase() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> recipeMaps = await db.query('Recipes');

    List<Recipe> recipes = [];
    for (var recipeMap in recipeMaps) {
      final ingredientsMaps = await db.query(
        'Ingredients',
        where: 'recipeId = ?',
        whereArgs: [recipeMap['id']],
      );

      final allergensMaps = await db.query(
        'Allergens',
        where: 'recipeId = ?',
        whereArgs: [recipeMap['id']],
      );

      recipes.add(Recipe(
        id: recipeMap['id'],
        rname: recipeMap['rname'],
        ringredients: ingredientsMaps,
        rratings: recipeMap['rratings'],
        rimage: recipeMap['rimage'],
        rlink: recipeMap['rlink'],
        rmainingredient: recipeMap['rmainingredient'],
        rtype: recipeMap['rtype'],
        allergens: allergensMaps.map((m) => m['allergen'].toString()).toList(),
        rinstructions: allergensMaps.map((m) => m['rinstructions'].toString()).toList(),
      ));
    }

    return recipes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipe'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RecipeListView(recipes: _recipes, screenWidth: MediaQuery.of(context).size.width,selectedIngredients: const [],),
    );
  }
}