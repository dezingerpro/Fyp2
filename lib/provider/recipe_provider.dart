import 'package:flutter/material.dart';
import '../Models/recipe_model.dart';

class RecipeProvider with ChangeNotifier {
  List<Recipe> _recipes = [];

  List<Recipe> get recipes => _recipes;

  void updateRecipes(List<Recipe> newRecipes) {
    _recipes = newRecipes;
    notifyListeners();
  }
}
