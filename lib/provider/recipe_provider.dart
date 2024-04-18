import 'package:flutter/material.dart';
import '../API/api.dart';
import '../Models/recipe_model.dart';

class RecipeProvider with ChangeNotifier {
  List<Recipe> _recipes = [];
  List<Recipe> get recipes => _recipes;
  bool _isLoading = false; // Boolean flag to track loading state
  bool get isLoading => _isLoading;

  Future<List<Recipe>> fetchRecipes() async {
    _isLoading = true;
    notifyListeners(); // Start loading
    try {
      // Simulate a network request with a delay
      await Future.delayed(const Duration(seconds: 2));
      var data = await Api.getRecipeAll();
      return _recipes = data
          .map<Recipe>((recipeJson) => Recipe.fromJson(recipeJson))
          .toList();
      //filteredRecipes = List.from(recipes);// Fetch recipes
      //_recipes = fetchedRecipes.map((json) => Recipe.fromJson(json)).toList();
    } finally {
      _isLoading = false;
      notifyListeners(); // End loading
    }
  }

  void updateRecipes(List<Recipe> newRecipes) {
    _recipes = newRecipes;
    notifyListeners();
  }
}
