import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:fyp2/glasseff.dart';
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
    recipeRatingController =
        TextEditingController(text: widget.recipe.rratings.toString());
    recipeImageController = TextEditingController(text: widget.recipe.rimage);
    recipeLinkController = TextEditingController(text: widget.recipe.rlink);

    // Initialize ingredient text controllers and populate with existing values
    ingredientNameControllers = widget.recipe.ringredients
        .map((ingredient) =>
        TextEditingController(text: ingredient['ingredientName']))
        .toList();
    ingredientQtyControllers = widget.recipe.ringredients
        .map((ingredient) =>
        TextEditingController(text: ingredient['quantity']))
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
        title: Text('Alert'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.purple.shade200,
        title: Text('Update Recipe'),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe Name
                _buildTextFormField(
                  controller: recipeNameController,
                  labelText: 'Recipe Name',
                ),
                SizedBox(height: 20),

                // Recipe Main Ingredient
                _buildMainIngredientDropdown(),

                SizedBox(height: 20),

                // Recipe Rating
                _buildTextFormField(
                  controller: recipeRatingController,
                  labelText: 'Recipe Rating',
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),

                // Recipe Image Link
                _buildTextFormField(
                  controller: recipeImageController,
                  labelText: 'Recipe Image Link',
                ),
                SizedBox(height: 20),

                // Recipe Link
                _buildTextFormField(
                  controller: recipeLinkController,
                  labelText: 'Recipe Link',
                ),
                SizedBox(height: 20),

                // Ingredients section
                Text(
                  'Ingredients:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Column(
                  children: List.generate(
                    ingredientNameControllers.length,
                        (index) => Row(
                      children: [
                        Column(
                          children: [
                            const Text("Ingredient: "),
                            SizedBox(
                              width: 180,
                              child: DropdownSearch(
                                items: ingredients,
                                dropdownBuilder: (context, selectedItem) {
                                  return Text(
                                    selectedItem ?? ingredientNameControllers[index].text,
                                    style: TextStyle(fontSize: 16),
                                  );
                                },
                                compareFn: (item1, item2) {
                                  return true;
                                },
                                onChanged: (value){
                                  ingredientNameControllers[index].text = value;
                                },
                                popupProps: const PopupProps.menu(
                                  isFilterOnline: true,
                                  showSearchBox: true,
                                  showSelectedItems: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _buildTextFormField(
                            controller: ingredientQtyControllers[index],
                            labelText: 'Quantity',
                          ),
                        ),
                      ],
                    ),
                  ).toList(),
                ),

                // Update and Cancel buttons
                SizedBox(height: 20),
                Row(
                  children: [
                    _buildElevatedButton(
                      onPressed: updateRecipe,
                      label: 'Update',
                    ),
                    SizedBox(width: 20),
                    _buildElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Navigate back without updating
                      },
                      label: 'Cancel',
                    ),
                  ],
                ),
              ],
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
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
      ),
      validator: validator,
      keyboardType: keyboardType,
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
                selectedItem ?? recipeMainIngController.text,
                style: TextStyle(fontSize: 16),
              );
            },
            compareFn: (item1, item2) {
              return true;
            },
            onChanged: (value){
              recipeMainIngController.text = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Main Ingredient is required';
              }
              return null;
            },
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

  Future<void> fetchIngredients() async {
    List<Ingredient> Ing = await Api.fetchIngredients();
    setState(() {
      ingredients = Ing.map((ing) => ing.name).toList();
      print(ingredients);
    });
  }
}
