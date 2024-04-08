import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:fyp2/API/api.dart';
import 'package:fyp2/Models/recipe_model.dart';
import 'package:fyp2/Models/ingredients_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Recipe> recipes = [];
  TextEditingController searchController = TextEditingController();
  List<String> selectedIngredients = [];
  List<String> ingredients = [];
  bool isFetching = false;
  List<Recipe> filteredRecipes = [];
  String currentIngredient = '';
  List<String> availableRecipeNames = [];
  final recipeIngredientNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  void fetchInitialData() async {
    setState(() => isFetching = true);
    await fetchRecipes();
    await fetchIngredients();
    setState(() => isFetching = false);
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Recipes', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: searchController.text.isEmpty
                ? null
                : () {
              searchController.clear();
              setState(() {});
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child:  DropdownSearch<String>(
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
            ),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search recipes...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
              ),
              onChanged: (value) {
                // Filter logic here
              },
            ),

            if (isFetching)
              Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ...selectedIngredients.map((ingredient) => Chip(
              label: Text(ingredient),
              onDeleted: () {
                setState(() {
                  selectedIngredients.remove(ingredient);
                });
              },
            )).toList(),
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
