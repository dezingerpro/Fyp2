import 'package:flutter/material.dart';
import '../API/api.dart';
import '../Models/ingredients_model.dart';
import '../Others/custom_text_fields.dart';
import 'add_ingredients.dart';

class IngredientListPage extends StatefulWidget {
  const IngredientListPage({super.key});

  @override
  _IngredientListPageState createState() => _IngredientListPageState();
}

class _IngredientListPageState extends State<IngredientListPage>
    with SingleTickerProviderStateMixin {
  late Future<List<Ingredient>> futureIngredients;
  String? selectedQuantityType;
  late TabController _tabController;
  late List<Ingredient> allIngredients;
  late List<Ingredient> lowStockIngredients;
  late List<Ingredient> outOfStockIngredients;

  static const List<String> quantityTypes = [
    'Liters',
    'Milliliters',
    'Grams',
    'Kilograms',
    'Tablespoons',
    'Cups',
    'Pieces',
    'Others'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    futureIngredients = Api.fetchIngredients();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ingredient Inventory"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Ingredients'),
            Tab(text: 'Low Stock'),
            Tab(text: 'Out of Stock'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AddIngredientPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Ingredient>>(
        future: futureIngredients,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            // Assuming you have a way to categorize ingredients based on stock level
            var allIngredients = snapshot.data!;
            var lowStockIngredients = allIngredients
                .where((i) => i.stock < 10 && i.stock > 0)
                .toList(); // Example condition
            var outOfStockIngredients =
                allIngredients.where((i) => i.stock == 0).toList();

            return TabBarView(
              controller: _tabController,
              children: [
                ingredientListSection(allIngredients),
                ingredientListSection(lowStockIngredients),
                ingredientListSection(outOfStockIngredients),
              ],
            );
          } else {
            return const Center(child: Text("No Ingredients Found"));
          }
        },
      ),
    );
  }

  Widget ingredientListSection(List<Ingredient> ingredients) {
    return ListView.builder(
      itemCount: ingredients.length,
      itemBuilder: (BuildContext context, int index) {
        final ingredient = ingredients[index];

        IconData stockIcon = Icons.check_circle;
        Color iconColor = Colors.green;
        String stockStatus = "In Stock";

        if (ingredient.stock == 0) {
          stockIcon = Icons.cancel;
          iconColor = Colors.red;
          stockStatus = "Out of Stock";
        } else if (ingredient.stock > 0 && ingredient.stock <= 5) {
          stockIcon = Icons.warning_amber_rounded;
          iconColor = Colors.orange;
          stockStatus = "Low Stock";
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(ingredient.image),
            ),
            title: Text(ingredient.name),
            subtitle: Text(
                'Stock: ${ingredient.stock} | Price: \$${ingredient.price} | $stockStatus'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () =>
                      _showEditIngredientBottomSheet(context, ingredient),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      _showDeleteConfirmation(context, ingredient.id),
                ),
                Icon(stockIcon, color: iconColor),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditIngredientBottomSheet(
      BuildContext context, Ingredient ingredient) {
    // Local controllers for form fields.
    TextEditingController nameController =
        TextEditingController(text: ingredient.name);
    TextEditingController stockController =
        TextEditingController(text: ingredient.stock.toString());
    TextEditingController priceController =
        TextEditingController(text: ingredient.price.toString());

    // Local state for the selected quantity type.
    String? localSelectedQuantityType = ingredient.quantityType;

    // A separate form key for validation within the bottom sheet.
    final GlobalKey<FormState> bottomSheetFormKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        // Use StatefulBuilder to manage state within the modal bottom sheet.
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: bottomSheetFormKey,
                child: Wrap(
                  children: <Widget>[
                    CustomTextField(
                      labelText: 'Name',
                      controller: nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      labelText: 'Stock',
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      controller: stockController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter stock quantity';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      labelText: 'Price',
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      controller: priceController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        return null;
                      },
                    ),
                    CustomDropdownButtonFormField<String>(
                      value: localSelectedQuantityType,
                      labelText: 'Select Quantity Type',
                      items: _IngredientListPageState.quantityTypes.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) => setModalState(() => localSelectedQuantityType = value),
                      validator: (value) => value == null ? 'Please select a quantity type' : null,
                    ),
                    CustomElevatedButton(
                      text: 'Update Ingredient',
                      onPressed: () async {
                        if (bottomSheetFormKey.currentState!.validate()) {
                          // If the form is valid, proceed with updating the ingredient.
                          Ingredient updatedIngredient = Ingredient(
                            id: ingredient.id,
                            name: nameController.text,
                            image: ingredient.image, // Assuming no change to image.
                            stock: num.parse(stockController.text),
                            price: num.parse(priceController.text),
                            quantityType: localSelectedQuantityType!, // Use the selected quantity type.
                          );

                          // Assuming Api.updateIngredient is implemented to handle this update.
                          bool success = await Api.updateIngredient(ingredient.id, updatedIngredient);

                          if (success) {
                            // Refresh the ingredients list or update the UI accordingly.
                            Navigator.pop(context); // Close the modal bottom sheet.
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to update ingredient')),
                            );
                          }
                        }
                      },
                    ),

                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteIngredient(String id) async {
    bool success = await Api.deleteIngredient(id);
    if (success) {
      // Refresh the ingredient list
      setState(() {
        futureIngredients = Api.fetchIngredients();
      });
      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingredient successfully deleted')),
      );
    } else {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete ingredient')),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Ingredient"),
          content: const Text("Are you sure you want to delete this ingredient?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () async {
                Navigator.of(context).pop(); // Dismiss the dialog
                await _deleteIngredient(id); // Proceed with deletion
              },
            ),
          ],
        );
      },
    );
  }
}
