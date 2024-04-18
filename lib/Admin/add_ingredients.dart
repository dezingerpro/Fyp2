import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../API/api.dart';
import '../Models/ingredients_model.dart';
import '../Others/custom_text_fields.dart';

class AddIngredientPage extends StatefulWidget {
  const AddIngredientPage({super.key});

  @override
  _AddIngredientPageState createState() => _AddIngredientPageState();
}

class _AddIngredientPageState extends State<AddIngredientPage> {
  final _formKey = GlobalKey<FormState>();
  final String _id = const Uuid().v4();
  String _name = '';
  String _image = '';
  num _stock = 0;
  num _price = 0.0;
  String _quantityType = 'Pieces';
  final List<String> _quantityTypes = ['Pieces', 'Kilograms', 'Liters', 'Packets'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Ingredient', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple, // Feel free to adjust the color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                labelText: 'Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the ingredient name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              CustomTextField(
                labelText: 'Image URL',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the image URL';
                  }
                  return null;
                },
                onSaved: (value) => _image = value!,
              ),
              CustomTextField(
                labelText: 'Stock',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Please enter a valid stock number';
                  }
                  return null;
                },
                onSaved: (value) => _stock = int.parse(value!),
              ),
              CustomTextField(
                labelText: 'Price',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
                onSaved: (value) => _price = double.parse(value!),
              ),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: 'Quantity Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: _quantityType,
                items: _quantityTypes.map((String type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _quantityType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple, // Adjust the button color
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Add Ingredient', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Create an Ingredient instance from the form data
                    Ingredient newIngredient = Ingredient(
                      id: _id,
                      name: _name,
                      image: _image,
                      stock: _stock,
                      price: _price,
                      quantityType: _quantityType,
                    );

                    // Call the addIngredient function and await its result
                    bool success = await Api.addIngredient(newIngredient);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ingredient added successfully!')),
                      );
                      // Optionally clear the form or navigate away after a successful addition
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to add ingredient')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
