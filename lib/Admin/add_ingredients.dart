import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../Others/custom_text_fields.dart';

class AddIngredientPage extends StatefulWidget {
  const AddIngredientPage({Key? key}) : super(key: key);

  @override
  _AddIngredientPageState createState() => _AddIngredientPageState();
}

class _AddIngredientPageState extends State<AddIngredientPage> {
  final _formKey = GlobalKey<FormState>();
  String _id = Uuid().v4();
  String _name = '';
  String _image = '';
  num _stock = 0;
  num _price = 0.0;
  String _quantityType = 'Pieces';
  List<String> _quantityTypes = ['Pieces', 'Kilograms', 'Liters', 'Packets'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Ingredient', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple, // Feel free to adjust the color
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
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
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple, // Adjust the button color
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Add Ingredient', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Handle your ingredient addition logic here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ingredient Added')),
                    );
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
