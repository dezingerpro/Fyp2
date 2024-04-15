import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fyp2/Models/main_ingredient_model.dart';
import '../API/api.dart';
import '../Models/ingredients_model.dart';
import '../Others/custom_text_fields.dart';

class AddRecipe extends StatefulWidget {
  const AddRecipe({super.key});

  @override
  State<AddRecipe> createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  List<Map<String, String>> ingredientsList = [];
  List<Ingredient> ingredientsList2 = [];
  Map<String, String> ingredientNameToTypeMap = {};
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
  String currentQuantityType = "Qty"; // Default label text for quantity type


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
                CustomTextField(
                  labelText: "Recipe Name",
                  controller: recipeNameController,
                  validator: (value) => value == null || value.isEmpty ? 'Recipe Name is required' : null,
                ),
                const SizedBox(height: 16.0),
                CustomTextField(
                  labelText: "Recipe Rating",
                  controller: recipeRatingController,
                  validator: (value) => value == null || value.isEmpty ? 'Recipe Rating is required' : null,
                ),
                const SizedBox(height: 16.0),
                CustomTextField(
                  labelText: "Recipe Type",
                  controller: recipeTypeController,
                  validator: (value) => value == null || value.isEmpty ? 'Recipe Type is required' : null,
                ),
                const SizedBox(height: 16.0),
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
                CustomTextField(
                  labelText: "Recipe Image Link",
                  controller: recipeImageController,
                  validator: (value) => value == null || value.isEmpty ? 'Recipe Image Link is required' : null,
                ),
                const SizedBox(height: 16.0),
                CustomTextField(
                  labelText: "Recipe Link",
                  controller: recipeLinkController,
                  validator: (value) => value == null || value.isEmpty ? 'Recipe Link is required' : null,
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
                const Text("Ingredient: "),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownSearch<String>(
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
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value != null) {
                              String quantityType = ingredientNameToTypeMap[value] ?? "Qty"; // Default to "Qty" if not found
                              setState(() {
                                recipeIngredientNameController.text = value;
                                currentQuantityType = quantityType; // Update the state for quantity type
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
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              cursorColor: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10), // Add some spacing between the dropdown and the text field
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomTextField(
                    labelText: "Type in $currentQuantityType",  // Use the updated state here
                    controller: recipeIngredientQtyController,
                  ),
                ),
                const SizedBox(height: 16.0),
                CustomElevatedButton(
                  text: "Add Ingredient",
                  onPressed: () {
                    addIngredient();
                  },
                ),
                const SizedBox(height: 16.0),
                CustomElevatedButton(
                  text: "Submit",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      addOneRecipe();
                    }
                  },
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
      mainIngredients = mainIng.map((mainIng) => mainIng.mname).toList();
      print(mainIngredients);
    });
  }

  Future<void> fetchIngredients() async {
    List<Ingredient> fetchedIngredients = await Api.fetchIngredients();
    setState(() {
      ingredientsList2 = fetchedIngredients;
      // Build a map from ingredient names to their quantity types
      ingredientNameToTypeMap = {
        for (Ingredient ing in fetchedIngredients) ing.name: ing.quantityType
      };
      // Only extract names for the DropdownSearch
      ingredients = fetchedIngredients.map((ing) => ing.name).toList();
    });
  }

  // Future<void> fetchIngredients() async {
  //   List<Ingredient> Ing = await Api.fetchIngredients();
  //   setState(() {
  //     ingredients = Ing.map((ing) => ing.name).toList();
  //     print(ingredients);
  //   });
  // }

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
