import 'package:flutter/material.dart';
import '../API/api.dart';
import '../Models/ingredients_model.dart';

class GroceryProvider with ChangeNotifier {
  List<Ingredient> _items = [];
  List<Ingredient> _searchResults = [];

  List<Ingredient> get items => _items;
  List<Ingredient> get searchResults => _searchResults.isNotEmpty ? _searchResults : _items;

  GroceryProvider() {
    fetchGroceries();
  }

  Future<void> fetchGroceries() async {
    try {
      List<Ingredient> fetchedItems = await Api.fetchIngredients();
      _items = fetchedItems;
      print(_items);
      notifyListeners();
    } catch (e) {
      // Handle any errors here
      print("Failed to fetch groceries: $e");
    }
  }

  void searchItems(String query) {
    if (query.isEmpty) {
      _searchResults = _items;
    } else {
      _searchResults = _items.where((item) => item.name.toLowerCase().contains(query.toLowerCase())).toList();
    }
    notifyListeners();
  }
}
