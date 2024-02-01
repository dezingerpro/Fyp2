import 'package:flutter/material.dart';
import 'dart:async';
import '../API/api.dart';
import '../Models/recipe_model.dart';
import 'single_recipe_screen.dart';
import '../nav_bar.dart';

class FoodRecipesScreen extends StatefulWidget {
  const FoodRecipesScreen({Key? key}) : super(key: key);

  @override
  _FoodRecipesScreenState createState() => _FoodRecipesScreenState();
}

class _FoodRecipesScreenState extends State<FoodRecipesScreen> {
  List<Recipe> recipes = [];
  List<Recipe> filteredRecipes = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Call the function to fetch recipes when the screen is loaded
    fetchRecipes();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // Function to fetch recipes from the API
  Future<void> fetchRecipes() async {
    setState(() {
      isLoading = true;
    });

    var data = await Api.getRecipeAll();

    setState(() {
      recipes = data.map((recipeJson) {
        return Recipe.fromJson(recipeJson);
      }).toList();

      filteredRecipes = List.from(recipes);
      isLoading = false;
    });
  }

  // Function to filter recipes based on the search query
  void filterRecipes(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        isLoading = true; // Set loading while filtering
      });

      if (query.isEmpty) {
        setState(() {
          filteredRecipes = List.from(recipes);
          isLoading = false; // Disable loading after filtering
        });
        return;
      }

      setState(() {
        filteredRecipes = recipes.where((recipe) {
          final nameLower = recipe.rname.toLowerCase();
          final queryLower = query.toLowerCase();

          // Check if the recipe name contains the query
          if (nameLower.contains(queryLower)) {
            return true;
          }

          // Check if any part of the query matches the recipe name
          final queryParts = queryLower.split(' ');
          return queryParts.every((part) => nameLower.contains(part));
        }).toList();
        isLoading = false; // Disable loading after filtering
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.purple[100],
        title: const Text('Food Recipes'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        actions: const [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.shopping_bag_outlined,color: Colors.black),
          ),
          SizedBox(width: 10)
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                filterRecipes(value);
              },
              decoration: InputDecoration(
                labelText: "Search for dishes",
                prefixIcon: Icon(
                  Icons.search,
                  color: Color(0xff7b7b7b),
                ),
                filled: true,
                fillColor: Color(0xfff7f7f7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(
                color: Color(0xff707070),
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          isLoading
              ? Container(
                  height: MediaQuery.of(context).size.height *
                      0.5, // Adjust the height as needed
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeIngredients(
                                recipe: filteredRecipes[index],
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(15.0)),
                                  child: Image.network(
                                    filteredRecipes[index].rimage,
                                    height: 150.0,
                                    width: screenWidth,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        filteredRecipes[index].rname,
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                      Text(
                                        'Ratings: ${filteredRecipes[index].rratings}',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
