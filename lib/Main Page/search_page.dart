import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:fyp2/API/api.dart';
import 'package:fyp2/Models/recipe_model.dart';
import 'package:fyp2/Models/ingredients_model.dart';
import 'package:provider/provider.dart';
import '../Recipes/all_recipe_screen.dart';
import '../provider/recipe_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Recipe> recipes = [];
  List<Recipe> filteredRecipes = [];
  TextEditingController searchController = TextEditingController();
  List<String> selectedIngredients = [];
  String currentIngredient = '';
  List<String> ingredients = [];
  List<String> availableRecipeNames = [];
  final recipeIngredientNameController = TextEditingController();
  bool isLoading = false;
  final debouncer =
      Debouncer(milliseconds: 500); // Adjust the milliseconds as needed
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchRecipes();
    fetchIngredients();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
    debouncer.run(() {
      filterRecipes(query, availableRecipeNames);
    });
  }

  void sortFilteredRecipes() {
    setState(() {
      filteredRecipes.sort((a, b) => availableRecipeNames
          .indexOf(a.rname)
          .compareTo(availableRecipeNames.indexOf(b.rname)));
    });
  }

  Future<void> fetchRecipes() async {
    var data = await Api.getRecipeAll();
    setState(() {
      recipes = data
          .map<Recipe>((recipeJson) => Recipe.fromJson(recipeJson))
          .toList();
      filteredRecipes = List.from(recipes);
    });
    Provider.of<RecipeProvider>(context, listen: false)
        .updateRecipes(filteredRecipes);
  }

  Future<void> fetchIngredients() async {
    List<Ingredient> Ing = await Api.fetchIngredients();
    setState(() {
      ingredients = Ing.map((ing) => ing.name).toList();
    });
  }

  void filterRecipes(String query, List<String> availableRecipes) {
    // First, filter the recipes to include only those in the availableRecipes list
    var recipesToShow = recipes
        .where((recipe) => availableRecipes.contains(recipe.rname))
        .toList();
    // Next, filter based on the query if it's not empty
    filteredRecipes = query.isEmpty
        ? recipesToShow
        : recipesToShow
            .where((recipe) =>
                recipe.rname.toLowerCase().contains(query.toLowerCase()))
            .toList();

    Provider.of<RecipeProvider>(context, listen: false)
        .updateRecipes(filteredRecipes);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Search Recipes",
                  style: TextStyle(
                    fontSize: 32,  // Large font size for emphasis
                    fontWeight: FontWeight.bold,  // Bold for visual impact
                    color: Colors.black,  // Thematic color consistency
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                onChanged: _onSearchChanged,
                style: TextStyle(fontSize: 16, color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Search for recipe...',
                  hintText: "Enter a recipe name",
                  fillColor: _isSearching ? Colors.lightBlue[50] : Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0), // Subtle rounding of corners
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0), // Light grey outline
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0), // Consistent with the overall border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.deepPurple, width: 1.5), // Highlighted when focused
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                  suffixIcon: AnimatedOpacity(
                    opacity: searchController.text.isNotEmpty ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        searchController.clear();
                        _onSearchChanged('');
                      },
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  floatingLabelBehavior: FloatingLabelBehavior.never, // Keeps the label as a placeholder
                  labelStyle: TextStyle(color: Colors.grey),
                ),
              )

            ),
            DropdownSearch<String>(
              items: ingredients,
              dropdownBuilder: (context, selectedItem) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    selectedItem ?? "Select Ingredient",
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                );
              },
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Select Ingredient",
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    currentIngredient = value; // Update currentIngredient with the selected value
                    recipeIngredientNameController.text = value;
                  });
                }
              },
              popupProps: PopupProps.bottomSheet(
                isFilterOnline: true,
                showSearchBox: true,
                showSelectedItems: true,
                searchFieldProps: TextFieldProps(
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: "Search Ingredients",
                    hintText: "Type to search...",
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  cursorColor: Theme.of(context).primaryColor,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple, // Text color
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add Ingredient'),
                onPressed: () async {
                  if (currentIngredient.isNotEmpty &&
                      !selectedIngredients.contains(currentIngredient)) {
                    setState(() {
                      selectedIngredients.add(currentIngredient);
                      currentIngredient = '';
                      // Set loading state to true when the button is pressed
                      isLoading = true;
                    });

                    try {
                      // Fetch available recipe names based on the updated selected ingredients
                      var newAvailableRecipeNames =
                          await Api.sendIngredients(selectedIngredients);
                      setState(() {
                        availableRecipeNames = newAvailableRecipeNames;
                        // Filter recipes to display based on the new list of available recipe names
                        filterRecipes(
                            searchController.text, availableRecipeNames);
                        // Set loading state back to false when operation completes
                        isLoading = false;
                      });
                      sortFilteredRecipes();
                    } catch (error) {
                      print('Error fetching recipe names: $error');
                      // Ensure loading state is set to false even if there's an error
                      setState(() {
                        isLoading = false;
                      });
                    }
                  }
                },
              ),
            ),
            Wrap(
              spacing: 8.0,
              children: selectedIngredients.map((ingredient) {
                return Chip(
                  label: Text(ingredient),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      selectedIngredients.remove(ingredient);
                      isLoading =
                          true; // Start loading indicator when deleting begins
                    });

                    Api.sendIngredients(selectedIngredients)
                        .then((newAvailableRecipeNames) {
                      setState(() {
                        availableRecipeNames = newAvailableRecipeNames;
                        // Filter recipes to display based on the new list of available recipe names
                        filterRecipes(
                            searchController.text, availableRecipeNames);
                        isLoading =
                            false; // Stop loading indicator once data is fetched and processed
                      });
                    }).catchError((error) {
                      // Always handle potential errors and stop loading
                      print('Error updating after deletion: $error');
                      setState(() {
                        isLoading = false;
                      });
                    });
                  },
                );
              }).toList(),
            ),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator()) // Show loading indicator
                : Expanded(
                    child: RecipeListView(
                      recipes: filteredRecipes,
                      screenWidth: screenWidth,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
