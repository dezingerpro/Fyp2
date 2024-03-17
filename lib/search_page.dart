import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:fyp2/API/api.dart'; // Adjust the import path as necessary
import 'package:fyp2/Models/recipe_model.dart';
import 'package:fyp2/Models/ingredients_model.dart'; // Adjust the import path as necessary

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

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
  final recipeIngredientNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchRecipes();
    fetchIngredients();
  }

  Future<void> fetchRecipes() async {
    var data = await Api.getRecipeAll();
    setState(() {
      recipes = data.map<Recipe>((recipeJson) => Recipe.fromJson(recipeJson)).toList();
      filteredRecipes = List.from(recipes);
    });
  }

  Future<void> fetchIngredients() async {
    List<Ingredient> Ing = await Api.fetchIngredients();
    setState(() {
      ingredients = Ing.map((ing) => ing.name).toList();
    });
  }

  void filterRecipes(String query) {
    setState(() {
      filteredRecipes = query.isEmpty
          ? recipes
          : recipes.where((recipe) => recipe.rname.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Recipes'),
        elevation: 0, // Removes the shadow for a more modern look
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                onChanged: (value) => filterRecipes(value),
                decoration: InputDecoration(
                  labelText: 'Search for dishes...',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                      ? GestureDetector(
                    child: Icon(Icons.close),
                    onTap: () {
                      searchController.clear();
                      filterRecipes('');
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
                  style: TextStyle(fontSize: 16),
                );
              },
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0), // Adjust the value as needed
                  ),
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
                  decoration: InputDecoration(
                    labelText: "Search",
                    hintText: "Search Ingredients",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                    ),
                  ),
                  cursorColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.deepPurple, // Text color
                ),
                icon: Icon(Icons.add),
                label: Text('Add Ingredient'),
                onPressed: () {
                  if (currentIngredient.isNotEmpty && !selectedIngredients.contains(currentIngredient)) {
                    setState(() {
                      selectedIngredients.add(currentIngredient);
                      currentIngredient = '';
                    });
                  }
                },
              ),
            ),
            Wrap(
              spacing: 8.0,
              children: selectedIngredients.map((ingredient) {
                return Chip(
                  label: Text(ingredient),
                  deleteIcon: Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      selectedIngredients.remove(ingredient);
                    });
                  },
                );
              }).toList(),
            ),
            ListView.builder(
              shrinkWrap: true, // Use it to make ListView scrollable inside Column
              physics: NeverScrollableScrollPhysics(), // Disables ListView's own scrolling
              itemCount: filteredRecipes.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(filteredRecipes[index].rimage),
                    ),
                    title: Text(filteredRecipes[index].rname, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Click for more details'),
                    onTap: () {
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
