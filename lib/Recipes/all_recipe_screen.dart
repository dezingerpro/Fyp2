import 'package:flutter/material.dart';
import 'package:fyp2/Recipes/single_recipe_screen.dart';
import 'package:provider/provider.dart';
import '../Models/recipe_model.dart';
import '../Main Page/search_page.dart';
import '../provider/recipe_provider.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const SearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: GestureDetector(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const SearchPage())),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Search for dishes...",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ),
    );
  }
}

class RecipeListView extends StatelessWidget {
  final List<Recipe> recipes;
  final double screenWidth;

  const RecipeListView(
      {super.key, required this.recipes, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    List<Recipe> recipes = Provider.of<RecipeProvider>(context).recipes;
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(), // Ensure the list is always scrollable
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => RecipeIngredients(recipe: recipes[index])));
          },
          child: RecipeCard(recipe: recipes[index], screenWidth: screenWidth),
        );
      },
    );

  }
}

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final double screenWidth;

  const RecipeCard({super.key, required this.recipe, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity, // Image takes the full width available
                height: 200, // Fixed height for uniformity
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(recipe.rimage),
                    fit: BoxFit.cover,
                    onError: (error, stackTrace) => Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white, // White background circle
                  radius: 16, // Size of the circle
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.favorite_border, color: Colors.red),
                    onPressed: () {}, // Placeholder for functionality
                    iconSize: 20,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              recipe.rname,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text("${recipe.rratings} (0)", style: TextStyle(color: Colors.grey[600])),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {}, // Placeholder for functionality
              ),
            ],
          ),
        ],
      ),
    );
  }
}

