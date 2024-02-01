import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:fyp2/Models/main_ingredient_model.dart';
import 'package:fyp2/colors.dart';
import 'package:fyp2/glasseff.dart';
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

    recipeIngredientNameController.clear();
    recipeIngredientQtyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        backgroundColor: Colors.purple.shade200,
        elevation: 0,
        title: Text("Add Recipe"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GlassContainer(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        borderRadius: BorderRadius.circular(0),
        blur: 10,
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextFormField(
                    controller: recipeNameController,
                    labelText: "Recipe Name",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Recipe Name is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  _buildTextFormField(
                    controller: recipeRatingController,
                    labelText: "Recipe Rating",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Recipe Rating is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  _buildMainIngredientDropdown(),
                  SizedBox(height: 16.0),
                  _buildTextFormField(
                    controller: recipeImageController,
                    labelText: "Recipe Image Link",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Recipe Image Link is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  _buildTextFormField(
                    controller: recipeLinkController,
                    labelText: "Recipe Link",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Recipe Link is required';
                      }
                      return null;
                    },
                  ),
                  // Ingredient input fields
                  _buildIngredientsList(),
                  SizedBox(height: 16.0),
                  _buildIngredientDropdown(),
                  _buildTextFormField(
                    controller: recipeIngredientQtyController,
                    labelText: "Ingredient Qty",
                  ),
                  SizedBox(height: 16.0),
                  Align(
                    alignment: Alignment.center,
                    child: _buildElevatedButton(
                      onPressed: () {
                        addIngredient();
                      },
                      label: "Add Ingredient",
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Align(alignment: Alignment.center,
                  child: _buildElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        addOneRecipe();
                      }
                    },
                    label: "Submit",
                  ),),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
      ),
      validator: validator,
    );
  }

  Widget _buildMainIngredientDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Main Ingredient"),
        SizedBox(
          width: 200,
          child: DropdownSearch(
            items: mainIngredients,
            dropdownBuilder: (context, selectedItem) {
              return Text(
                selectedItem ?? "Select Ingredient",
                style: TextStyle(fontSize: 16),
              );
            },
            compareFn: (item1, item2) {
              return true;
            },
            onChanged: (value) {
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
                  borderRadius: BorderRadius.circular(10.0),
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
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                cursorColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text("Ingredient: "),
        SizedBox(
          width: 250,
          child: DropdownSearch(
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
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            compareFn: (item1, item2) {
              return true;
            },
            onChanged: (value) {
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
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                cursorColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsList() {
    return Column(
      children: ingredientsList.map((ingredient) {
        return Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Ingredient Name: ${ingredient['ingredientName']}"),
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
    );
  }

  Widget _buildElevatedButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
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
            title: Text("Minimum 3 Ingredients Required"),
            content: Text("Please add at least 3 ingredients to submit."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
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
      "rratings": double.tryParse(recipeRatingController.text)?.toString() ?? "0.0",
      "rlink": recipeLinkController.text,
      "rimage": recipeImageController.text,
      "ringredients": ringredientsString,
    };

    Api.addRecipe(data);
  }
}
