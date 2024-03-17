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
}
