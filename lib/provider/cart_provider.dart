import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/api.dart';
import '../Models/ingredients_model.dart';

class CartItem {
  final Ingredient item;
  final int quantity;

  CartItem({required this.item, this.quantity = 1});

}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};
  Map<String, CartItem> get items => _items;
  int get itemCount => _items.length;

  // Method to get quantity of an item
  int getItemQuantity(String itemId) {
    if (items.containsKey(itemId)) {
      return items[itemId]!
          .quantity; // Assuming your CartItem has a quantity field
    }
    return 0;
  }

  int get totalItemCount {
    return items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  // Adjust this method to accept a List<CartItem> and convert it to a Map<String, CartItem>
  void setCartItems(List<CartItem> newItems) {
    // Clear existing items
    _items.clear();
    // Convert list to map, assuming 'id' is a unique identifier in CartItem or its Ingredient
    for (var item in newItems) {
      _items[item.item.id] = item; // Assuming 'item.item.id' accesses the unique id of the ingredient. Adjust accordingly.
    }
    notifyListeners(); // Notify listeners of the update
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

  Future<void> updateCart() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') as String;
    Api.saveCartToDatabase(items,userId);
  }

  // Assuming a fixed delivery charge for demonstration. Adjust as needed.
  double get deliveryCharge => 10.00;

  // Mockup calculation for discount amount
  double get discountAmount {
    double total = totalAmount;
    // Apply a 10% discount for demonstration purposes
    if (total > 100) {
      // Example condition for discount
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
