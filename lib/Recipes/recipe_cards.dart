import 'package:flutter/material.dart';
import 'package:fyp2/Recipes/single_recipe_screen.dart';
import 'package:provider/provider.dart';
import '../Models/recipe_model.dart';
import '../provider/recipe_provider.dart';
import 'package:shimmer/shimmer.dart';

class RecipeListView extends StatelessWidget {
  final List<Recipe> recipes;
  final double screenWidth;
  final List<String> selectedIngredients;


  const RecipeListView(
      {super.key, required this.recipes, required this.screenWidth, required this.selectedIngredients});

  @override
  Widget build(BuildContext context) {
    List<Recipe> recipes = Provider.of<RecipeProvider>(context).recipes;
    if (recipes.isEmpty) {
      // Display a placeholder widget or error message if recipes list is empty
      return const Center(
        child: Text('No recipes available. :(',textAlign: TextAlign.center,),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => RecipeIngredients(recipe: recipes[index],selectedIngredients: selectedIngredients)));
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
                    onError: (error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
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
              Positioned(
                bottom: 12,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8), // Adjust padding as necessary
                  decoration: BoxDecoration(
                    color: Colors.white, // White background color
                    borderRadius: BorderRadius.circular(16), // Rounded corners with a border radius
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // shadow position
                      ),
                    ],
                  ),
                  child: Text(
                    'Match: ${recipe.similarity.toStringAsFixed(2)}', // Displaying similarity score
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              )
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

class RecipeCardShimmer extends StatelessWidget {
  final double screenWidth;

  const RecipeCardShimmer({Key? key, required this.screenWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 18,
                width: screenWidth * 0.5,
                color: Colors.white,
              ),
            ),
          ),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 18,
                  color: Colors.white,
                ),
                Container(
                  width: 40,
                  height: 18,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


