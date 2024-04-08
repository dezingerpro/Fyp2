import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:fyp2/API/api.dart';
import 'package:fyp2/Models/recipe_model.dart';
import 'package:fyp2/Models/ingredients_model.dart';

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

  @override
  void initState() {
    super.initState();
    fetchRecipes();
    fetchIngredients();
  }

  void sortFilteredRecipes() {
    setState(() {
      filteredRecipes.sort((a, b) =>
          availableRecipeNames.indexOf(a.rname).compareTo(availableRecipeNames.indexOf(b.rname))
      );
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
  }

  Future<void> fetchIngredients() async {
    List<Ingredient> Ing = await Api.fetchIngredients();
    setState(() {
      ingredients = Ing.map((ing) => ing.name).toList();
    });
  }

  void filterRecipes(String query, List<String> availableRecipes) {
    setState(() {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Recipes'),
        elevation: 0, // Removes the shadow for a more modern look
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                onChanged: (value) => filterRecipes(value, availableRecipeNames),
                decoration: InputDecoration(
                  labelText: 'Search for dishes...',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                      ? GestureDetector(
                          child: const Icon(Icons.close),
                          onTap: () {
                            searchController.clear();
                            filterRecipes('',availableRecipeNames);
                            Api.sendIngredients(selectedIngredients);
                          },
                        )
                      : null,
                ),
              ),
            ),
            DropdownSearch<String>(
              items: ingredients,
              dropdownBuilder: (context, selectedItem) {
                return Text(
                  selectedItem ?? "Select Ingredient",
                  style: const TextStyle(fontSize: 16),
                );
              },
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        10.0), // Adjust the value as needed
                  ),
                ),
              ),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    currentIngredient =
                        value; // Update currentIngredient with the selected value
                    recipeIngredientNameController.text = value;
                  });
                }
              },
              popupProps: PopupProps.bottomSheet(
                isFilterOnline: true,
                showSearchBox: true,
                showSelectedItems: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    labelText: "Search",
                    hintText: "Search Ingredients",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          20.0), // Adjust the value as needed
                    ),
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
                      });
                      // Fetch available recipe names based on the updated selected ingredients
                      var newAvailableRecipeNames = await Api.sendIngredients(selectedIngredients);
                      setState(() {
                        availableRecipeNames = newAvailableRecipeNames;
                        // Filter recipes to display based on the new list of available recipe names
                        filterRecipes(searchController.text, availableRecipeNames);
                      });
                      sortFilteredRecipes();
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
                      });
                      // Re-fetch available recipe names based on the updated selected ingredients
                      Api.sendIngredients(selectedIngredients).then((newAvailableRecipeNames) {
                        setState(() {
                          availableRecipeNames = newAvailableRecipeNames;
                          // Filter recipes to display based on the new list of available recipe names
                          filterRecipes(searchController.text, availableRecipeNames);
                        });
                      });
                    },
                );
              }).toList(),
            ),
            ListView.builder(
              shrinkWrap:
                  true, // Use it to make ListView scrollable inside Column
              physics:
                  const NeverScrollableScrollPhysics(), // Disables ListView's own scrolling
              itemCount: filteredRecipes.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(filteredRecipes[index].rimage),
                    ),
                    title: Text(filteredRecipes[index].rname,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Click for more details'),
                    onTap: () {
                      print(filteredRecipes[0].rname);
                      // Implement navigation to recipe details
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


}
