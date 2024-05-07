import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/api.dart';
import '../Models/recipe_model.dart';

class RecipeProvider with ChangeNotifier {
  List<Recipe> _recipes = [];
  List<Recipe> get recipes => _recipes;
  bool _isLoading = false; // Boolean flag to track loading state
  bool get isLoading => _isLoading;
  List<Recipe> _filteredRecipes = [];
  List<Recipe> get filteredRecipes => _filteredRecipes;


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

  /// Fetches all recipes and filters them based on whether the user is a guest.
  Future<void> recommendedRecipes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isGuest = prefs.getBool('isGuest') ?? true;

    var data = await Api.getRecipeAll();
    var allRecipes = data.map<Recipe>((recipeJson) => Recipe.fromJson(recipeJson)).toList();

    if (!isGuest) {
      var recommendedNames = await Api.fetchRecommendedRecipeNames();
      _filteredRecipes = allRecipes.where((recipe) => recommendedNames.contains(recipe.rname)).toList();
      notifyListeners();
    } else {
      _filteredRecipes = (allRecipes..shuffle()).take(10).toList();
      notifyListeners();
    }
  }

  /// Updates the `filteredRecipes` list directly and notifies listeners.
  void updateFilteredRecipes(List<Recipe> newFilteredRecipes) {
    _filteredRecipes = newFilteredRecipes;
    notifyListeners();
  }

  void updateRecipes(List<Recipe> newRecipes) {
    _recipes = newRecipes;
    notifyListeners();
  }
}
