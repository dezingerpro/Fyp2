import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../Models/recipe_model.dart';
import '../SQFLite DB/database_sqflite.dart';
import '../provider/recipe_provider.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  List<Recipe> _recipes = [];
  bool _isLoading = true;

  Future<void> checkPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  @override
  void initState() {
    super.initState();
    checkPermissions().then((_) {
      loadRecipesFromDatabase().then((loadedRecipes) {
        setState(() {
          _recipes = loadedRecipes;
          _isLoading = false;
        });
        Provider.of<RecipeProvider>(context, listen: false).updateRecipes(_recipes);
      });
    });
  }

  Future<List<Recipe>> loadRecipesFromDatabase() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> recipeMaps = await db.query('Recipes');

    if (recipeMaps.isEmpty) {
      return [];
    }

    List<Recipe> recipes = [];
    for (var recipeMap in recipeMaps) {
      final ingredientsMaps = await db.query(
        'Ingredients',
        where: 'recipeId = ?',
        whereArgs: [recipeMap['id']],
      );

      final allergensMaps = await db.query(
        'Allergens',
        where: 'recipeId = ?',
        whereArgs: [recipeMap['id']],
      );

      final instructionsMaps = await db.query(
        'Instructions',
        where: 'recipeId = ?',
        whereArgs: [recipeMap['id']],
      );

      final instructions = instructionsMaps.map((m) => m['instruction']?.toString() ?? '').toList();

      // Print instructions to console for debugging
      instructions.forEach(print);

      recipes.add(Recipe(
        id: recipeMap['id'],
        rinstructions: instructions,
        rname: recipeMap['rname'],
        rmainingredient: recipeMap['rmainingredient'],
        rratings: recipeMap['rratings'],
        rimage: recipeMap['rimage'],
        rlink: recipeMap['rlink'],
        rtype: recipeMap['rtype'],
        ringredients: ingredientsMaps,
        allergens: allergensMaps.map((m) => m['allergen']?.toString() ?? '').toList(),
      ));
    }

    return recipes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes',style: TextStyle(
          fontWeight: FontWeight.bold,fontSize: 28
        ),),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<RecipeProvider>(
        builder: (context, provider, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: provider.recipes.length,
            itemBuilder: (context, index) {
              final recipe = provider.recipes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  title: Text(
                    recipe.rname,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Main ingredient: ${recipe.rmainingredient}'),
                  trailing: recipe.rimage.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      recipe.rimage,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  )
                      : const Icon(Icons.image_not_supported),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SingleRecipeScreen(recipe: recipe),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class SingleRecipeScreen extends StatelessWidget {
  final Recipe recipe;

  const SingleRecipeScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(recipe.rname,style: const TextStyle(
            fontSize: 28,fontWeight: FontWeight.bold
          ),),
          backgroundColor: Colors.transparent,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Ingredients'),
              Tab(text: 'Instructions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            IngredientsTab(recipe: recipe),
            InstructionsTab(recipe: recipe),
          ],
        ),
      ),
    );
  }
}

class IngredientsTab extends StatelessWidget {
  final Recipe recipe;

  const IngredientsTab({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          recipe.rimage.isNotEmpty
              ? Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: NetworkImage(recipe.rimage),
                fit: BoxFit.cover,
              ),
            ),
          )
              : const Icon(Icons.image_not_supported, size: 150, color: Colors.grey),
          const SizedBox(height: 10),
          Text(
            recipe.rname,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 5),
              Text(
                recipe.rratings.toString(),
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Ingredients',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          const SizedBox(height: 10),
          ...recipe.ringredients.map((ingredient) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.deepPurple),
                title: Text(
                  ingredient['ingredientName'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Quantity: ${ingredient['quantity']}'),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class InstructionsTab extends StatelessWidget {
  final Recipe recipe;

  const InstructionsTab({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          recipe.rimage.isNotEmpty
              ? Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: NetworkImage(recipe.rimage),
                fit: BoxFit.cover,
              ),
            ),
          )
              : const Icon(Icons.image_not_supported, size: 150, color: Colors.grey),
          const SizedBox(height: 10),
          Text(
            recipe.rname,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 5),
              Text(
                recipe.rratings.toString(),
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Instructions',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          const SizedBox(height: 10),
          ...recipe.rinstructions.map((instruction) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.deepPurple),
                title: Text(
                  instruction,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
