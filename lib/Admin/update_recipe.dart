import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import '../API/api.dart';
import '../Models/ingredients_model.dart';
import '../Models/main_ingredient_model.dart';
import '../Models/recipe_model.dart';

class UpdateRecipe extends StatefulWidget {
  final Recipe recipe;

  const UpdateRecipe({Key? key, required this.recipe}) : super(key: key);

  @override
  State<UpdateRecipe> createState() => _UpdateRecipeState();
}

class _UpdateRecipeState extends State<UpdateRecipe> {
  late TextEditingController recipeNameController;
  late TextEditingController recipeRatingController;
  late TextEditingController recipeImageController;
  late TextEditingController recipeLinkController;
  late TextEditingController recipeMainIngController;
  late List<TextEditingController> ingredientNameControllers;
  late List<TextEditingController> ingredientQtyControllers;
  List<String> mainIngredients = [];
  List<String> ingredients = [];

  @override
  void initState() {
    super.initState();
    fetchIngredients();
    fetchMainIngredients();
    recipeNameController = TextEditingController(text: widget.recipe.rname);
    recipeMainIngController = TextEditingController(text: widget.recipe.rmainingredient);
    recipeRatingController = TextEditingController(text: widget.recipe.rratings.toString());
    recipeImageController = TextEditingController(text: widget.recipe.rimage);
    recipeLinkController = TextEditingController(text: widget.recipe.rlink);

    // Initialize ingredient text controllers and populate with existing values
    ingredientNameControllers = widget.recipe.ringredients
        .map((ingredient) => TextEditingController(text: ingredient['ingredientName']))
        .toList();
    ingredientQtyControllers = widget.recipe.ringredients
        .map((ingredient) => TextEditingController(text: ingredient['quantity']))
        .toList();
  }

  @override
  void dispose() {
    recipeNameController.dispose();
    recipeRatingController.dispose();
    recipeImageController.dispose();
    recipeLinkController.dispose();
    recipeMainIngController.dispose();

    // Dispose ingredient text controllers
    ingredientNameControllers.forEach((controller) => controller.dispose());
    ingredientQtyControllers.forEach((controller) => controller.dispose());

    super.dispose();
  }

  void updateRecipe() {
    // Validate if all fields are filled
    if (!validateFields()) {
      // If any field is empty, show an alert
      showAlert('Please fill in all fields.');
      return;
    }

    List<Map<String, String>> updatedIngredients = [];

    for (int i = 0; i < ingredientNameControllers.length; i++) {
      updatedIngredients.add({
        'ingredientName': ingredientNameControllers[i].text,
        'quantity': ingredientQtyControllers[i].text,
      });
    }

    String ringredientsString = jsonEncode(updatedIngredients);

    var data = {
      "rname": recipeNameController.text,
      "rratings": double.tryParse(recipeRatingController.text)?.toString() ?? "0.0",
      "rlink": recipeLinkController.text,
      "rimage": recipeImageController.text,
      "rmainingredient": recipeMainIngController.text,
      "ringredients": ringredientsString,
      "_id": widget.recipe.id
    };

    Api.updateRecipe(data);

    // Show success alert
    showAlert('Recipe updated successfully!');
  }

  bool validateFields() {
    return recipeNameController.text.isNotEmpty &&
        recipeRatingController.text.isNotEmpty &&
        recipeImageController.text.isNotEmpty &&
        recipeLinkController.text.isNotEmpty &&
        !ingredientNameControllers.any((controller) => controller.text.isEmpty) &&
        !ingredientQtyControllers.any((controller) => controller.text.isEmpty);
  }

  void showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alert'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> fetchMainIngredients() async {
    List<MainIngredient> mainIng = await Api.fetchMainIngredients();
    setState(() {
      mainIngredients = mainIng.map((main_ing) => main_ing.mname).toList();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        title: const Text(
          "Update Recipe",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Name
                  TextFormField(
                    controller: recipeNameController,
                    decoration: const InputDecoration(
                      labelText: 'Recipe Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Recipe Main Ingredient
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 350,
                        child: DropdownSearch<String>(
                          items: mainIngredients,
                          dropdownBuilder: (context, selectedItem) {
                            return Text(
                              selectedItem ?? recipeMainIngController.text,
                              style: const TextStyle(fontSize: 16),
                            );
                          },
                          onChanged: (value) {
                            recipeMainIngController.text = value!;
                          },
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: "Select Main Ingredient",
                              contentPadding: const EdgeInsets.fromLTRB(12, 12, 0, 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          popupProps: PopupProps.menu(
                            isFilterOnline: true,
                            showSearchBox: true,
                            showSelectedItems: true,
                            searchFieldProps: TextFieldProps(
                              controller: recipeMainIngController,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Recipe Rating
                  TextFormField(
                    controller: recipeRatingController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Recipe Rating',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Recipe Image Link
                  TextFormField(
                    controller: recipeImageController,
                    decoration: const InputDecoration(
                      labelText: 'Recipe Image Link',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Recipe Link
                  TextFormField(
                    controller: recipeLinkController,
                    decoration: const InputDecoration(
                      labelText: 'Recipe Link',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Ingredients section
                  const Text(
                    'Ingredients:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Column(
                    children: List.generate(
                      ingredientNameControllers.length,
                          (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownSearch<String>(
                                items: ingredients,
                                dropdownBuilder: (context, selectedItem) {
                                  return Text(
                                    selectedItem ?? ingredientNameControllers[index].text,
                                    style: const TextStyle(fontSize: 16),
                                  );
                                },
                                onChanged: (value) {
                                  ingredientNameControllers[index].text = value!;
                                },
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    labelText: "Ingredient",
                                    contentPadding: const EdgeInsets.fromLTRB(12, 12, 0, 0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                popupProps: PopupProps.menu(
                                  isFilterOnline: true,
                                  showSearchBox: true,
                                  showSelectedItems: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: ingredientQtyControllers[index],
                                decoration: const InputDecoration(
                                  labelText: 'Quantity',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).toList(),
                  ),

                  // Update and Cancel buttons
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: updateRecipe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Update',style: TextStyle(
                          color: Colors.white
                        ),),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Navigate back without updating
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
