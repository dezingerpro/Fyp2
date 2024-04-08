import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../Models/ingredients_model.dart';

class CartItem {
  final Ingredient item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};
  Map<String, CartItem> get items => _items;
  int get itemCount => _items.length;

  // Method to get quantity of an item
  int getItemQuantity(String itemId) {
    if (items.containsKey(itemId)) {
      return items[itemId]!.quantity; // Assuming your CartItem has a quantity field
    }
    return 0;
  }

  int get totalItemCount {
    return items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  void addItem(Ingredient item, int quantity) {
    if (_items.containsKey(item.id)) {
      // Update the quantity if item already exists
      _items.update(
        item.id,
            (existingCartItem) => CartItem(
          item: existingCartItem.item,
          quantity: existingCartItem.quantity + quantity,
        ),
      );
    } else {
      // Add item if it does not exist
      _items.putIfAbsent(
        item.id,
            () => CartItem(
          item: item,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.item.price * cartItem.quantity;
    });
    return total;
  }

  Future<void> saveCartToDatabase(String userId) async {
    final url = Uri.parse('http://18.142.186.38:2000/api/saveUserCart');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'userId': userId,
          'ucart': _items.entries.map((item) => {
            'ingredientName': item.value.item.name,
            'quantity': item.value.quantity,
          }).toList(),
        }),
      );
      if (response.statusCode == 200) {
        print("Cart saved successfully");
      } else {
        print("Failed to save cart, Status Code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error saving cart: $error");
    }
  }

  // Assuming a fixed delivery charge for demonstration. Adjust as needed.
  double get deliveryCharge => 10.00;

  // Mockup calculation for discount amount
  double get discountAmount {
    double total = totalAmount;
    // Apply a 10% discount for demonstration purposes
    if (total > 100) { // Example condition for discount
      return total * 0.1;
    }
    return 0.0;
  }

  // Calculates the final price after applying discounts and adding delivery charges
  double get finalPrice {
    return totalAmount - discountAmount + deliveryCharge;
  }

  void increaseItemQuantity(String productId) {
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
              (existingCartItem) => CartItem(
            item: existingCartItem.item,
            quantity: existingCartItem.quantity + 1,
          ));
      notifyListeners();
    }
  }

  void decreaseItemQuantity(String productId) {
    if (_items.containsKey(productId) && _items[productId]!.quantity > 1) {
      _items.update(
          productId,
              (existingCartItem) => CartItem(
            item: existingCartItem.item,
            quantity: existingCartItem.quantity - 1,
          ));
    } else {
      removeItem(productId); // Remove the item if quantity reaches 0
    }
    notifyListeners();
  }

}
