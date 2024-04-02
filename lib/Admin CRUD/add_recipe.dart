import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fyp2/Models/main_ingredient_model.dart';
import '../API/api.dart';
import '../Models/ingredients_model.dart';

class AddRecipe extends StatefulWidget {
  const AddRecipe({Key? key}) : super(key: key);

  @override
  State<AddRecipe> createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  List<Map<String, String>> ingredientsList = [];

  final recipeNameController = TextEditingController();
  final recipeRatingController = TextEditingController();
  final recipeImageController = TextEditingController();
  final recipeMainIngredientController = TextEditingController();
  final recipeLinkController = TextEditingController();
  final recipeIngredientNameController = TextEditingController();
  final recipeIngredientQtyController = TextEditingController();
  final recipeTypeController = TextEditingController(); // Controller for recipe type
  List<String> mainIngredients = [];
  List<String> ingredients = [];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    fetchMainIngredients();
    fetchIngredients();
    super.initState();
  }

  void addIngredient() {
    setState(() {
      ingredientsList.add({
        "ingredientName": recipeIngredientNameController.text,
        "quantity": recipeIngredientQtyController.text,
      });
    });

    print(recipeIngredientNameController.text);
    recipeIngredientNameController.clear();
    recipeIngredientQtyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.purple,
        title: const Text("Add Recipe"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: recipeNameController,
                  decoration: const InputDecoration(
                    labelText: "Recipe Name",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Recipe Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: recipeRatingController,
                  decoration: const InputDecoration(
                    labelText: "Recipe Rating",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Recipe Rating is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: recipeTypeController,
                  decoration: const InputDecoration(
                    labelText: "Recipe Type", // Label for recipe type
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Recipe Type is required'; // Validation message
                    }
                    return null;
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Main Ingredient"),
                    SizedBox(
                      width: 250,
                      child: DropdownSearch(
                        items: mainIngredients,
                        dropdownBuilder: (context, selectedItem) {
                          return Text(
                            selectedItem ?? "Select Ingredient",
                            style: const TextStyle(fontSize: 16),
                          );
                        },
                        compareFn: (item1, item2) {
                          return true;
                        },
                        onChanged: (value){
                          recipeMainIngredientController.text = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Main Ingredient is required';
                          }
                          return null;
                        },
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0), // Adjust the value as needed
                            ),
                          ),
                        ),

                        popupProps: PopupProps.modalBottomSheet(
                            isFilterOnline: true,
                            showSearchBox: true,
                            showSelectedItems: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              labelText: "Search",
                              hintText: "Search Main Ingredient",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0), // Adjust the value as needed
                              ),
                            ),
                            cursorColor: Theme.of(context).primaryColor,
                          )
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: recipeImageController,
                  decoration: const InputDecoration(
                    labelText: "Recipe Image Link",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Recipe Image Link is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: recipeLinkController,
                  decoration: const InputDecoration(
                    labelText: "Recipe Link",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Recipe Link is required';
                    }
                    return null;
                  },
                ),
                // Ingredient input fields
                Column(
                  children:
                  ingredientsList.map((ingredient) {
                    return Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                "Ingredient Name: ${ingredient['ingredientName']}"),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Quantity: ${ingredient['quantity']}"),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text("Ingredient: "),
                    SizedBox(
                      width: 250,
                      child: DropdownSearch(
                        // recipe = Api.getRecipe();
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
                                borderRadius: BorderRadius.circular(10.0), // Adjust the value as needed
                              ),
                            ),
                          ),
                        compareFn: (item1, item2) {
                          return true;
                        },
                        onChanged: (value){
                          recipeIngredientNameController.text = value;
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
                            )
                            ),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: recipeIngredientQtyController,
                  decoration: const InputDecoration(
                    labelText: "Ingredient Qty",
                  ),
                ),

                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    addIngredient();
                  },
                  child: const Text("Add Ingredient"),
                ),

                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      addOneRecipe();
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> fetchMainIngredients() async {
    List<MainIngredient> mainIng = await Api.fetchMainIngredients();
    setState(() {
      mainIngredients = mainIng.map((main_ing) => main_ing.mname).toList();
      print(mainIngredients);
    });
  }

  Future<void> fetchIngredients() async {
    List<Ingredient> Ing = await Api.fetchIngredients();
    setState(() {
      ingredients = Ing.map((ing) => ing.name).toList();
      print(ingredients);
    });
  }

  void addOneRecipe() async {
    if (ingredientsList.length < 3) {
      // Show an alert or message indicating that at least 3 ingredients are required
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Minimum 3 Ingredients Required"),
            content: const Text("Please add at least 3 ingredients to submit."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    String ringredientsString = jsonEncode(ingredientsList);

    var data = {
      "rname": recipeNameController.text,
      "rmainingredient": recipeMainIngredientController.text,
      "rratings":
          double.tryParse(recipeRatingController.text)?.toString() ?? "0.0",
      "rlink": recipeLinkController.text,
      "rimage": recipeImageController.text,
      "ringredients": ringredientsString,
      "rtype": recipeTypeController.text,
    };

    Api.addRecipe(data);
  }
}
