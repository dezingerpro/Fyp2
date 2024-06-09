// setState(() {
// if (selectedIngredients.contains(ingredient)) {
// selectedIngredients.remove(ingredient);
// } else {
// selectedIngredients.add(ingredient);
// }
// });


import 'package:flutter/material.dart';
import 'package:fyp2/Models/recipe_model.dart';
import '../API/api.dart';
import 'update_recipe.dart';

class MyRecipeApp extends StatefulWidget {
  @override
  _MyRecipeAppState createState() => _MyRecipeAppState();
}

class _MyRecipeAppState extends State<MyRecipeApp> {
  List<Recipe> recipes = [];

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  void fetchRecipes() async {
    List<Recipe> fetchedRecipes = await Api.getRecipe();
    setState(() {
      recipes = fetchedRecipes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text("Update Recipe",style: TextStyle(
            fontWeight: FontWeight.bold,fontSize: 28
        ),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView.builder(
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateRecipe(recipe: recipes[index]),
                  ),
                );
              },
              child: Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Image.network(
                    recipes[index].rimage,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                  title: Text(recipes[index].rname),
                  subtitle: Text('Ratings: ${recipes[index].rratings.toString()}'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
