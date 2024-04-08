import 'package:flutter/material.dart';
import 'package:fyp2/Models/recipe_model.dart';
import '../API/api.dart';

class DeleteRecipe extends StatefulWidget {
  @override
  _DeleteRecipeState createState() => _DeleteRecipeState();
}

class _DeleteRecipeState extends State<DeleteRecipe> {
  List<Recipe> recipes = [];

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> _deleteRecipeAndReload(int index) async {
    deleteRecipe(index);
    fetchRecipes();
  }

  void fetchRecipes() async {
    List<Recipe> fetchedRecipes = await Api.getRecipe();
    if (!mounted) return; // Check if the widget is still mounted
    setState(() {
      recipes = fetchedRecipes;
    });
  }

  Future<void> deleteRecipe(int index) async {
    try {
      await Api.deleteRecipe(recipes[index].id);
    } catch (e) {
      print("Error deleting recipe: $e");
    }
  }

  Future<void> _confirmDelete(BuildContext context, int index) async {
    if (!mounted) return; // Check if the widget is still mounted

    // Show the dialog
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<void>(
          future: _deleteRecipeAndReload(index),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                title: Text('Deleting...'),
                content: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text('An error occurred: ${snapshot.error}'),
              );
            } else {
              return AlertDialog(
                title: const Text('Confirm Deletion'),
                content: const Text('Are you sure you want to delete this recipe?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Delete'),
                    onPressed: () async {
                      // Close the dialog
                      Navigator.of(context).pop();

                      // Delete the recipe on the server
                      await _deleteRecipeAndReload(index);
                      Navigator.of(context).pop(); // Pop the current page
                      Navigator.of(context).pushReplacement( // Push the current page again
                        MaterialPageRoute(
                          builder: (context) => DeleteRecipe(),
                        ),
                      );
                    },
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text('Delete Recipe'),
        ),
        body: ListView.builder(
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: Image.network(
                  recipes[index].rimage,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
                title: Text(recipes[index].rname),
                subtitle: Text(
                    'Ratings: ${recipes[index].rratings.toString()}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _confirmDelete(context, index);
                  },
                ),
              ),
            );
          },
        ),
      );
    }
  }
