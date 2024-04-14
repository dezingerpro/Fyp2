import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fyp2/provider/cart_provider.dart';
import 'package:fyp2/provider/grocery_provider.dart';
import '../Models/ingredients_model.dart';
import 'Cart+Checkout/cart.dart'; // Ensure correct import path

class GroceryItemsPage extends StatefulWidget {
  @override
  _GroceryItemsPageState createState() => _GroceryItemsPageState();
}

class _GroceryItemsPageState extends State<GroceryItemsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshGroceries());
  }

  void _refreshGroceries() {
    final groceryProvider = Provider.of<GroceryProvider>(context, listen: false);
    groceryProvider.fetchGroceries();
  }

  @override
  Widget build(BuildContext context) {
    final groceryProvider = Provider.of<GroceryProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Shop Groceries",
                  style: TextStyle(
                    fontSize: 32,  // Large font size for emphasis
                    fontWeight: FontWeight.bold,  // Bold for visual impact
                    color: Colors.black,  // Thematic color consistency
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: groceryProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = groceryProvider.items[index];
                    return Container(
                      height: 140, // Fixed height for each item
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
                                border: Border.all(color: Colors.grey.shade300, width: 1), // Thin outline
                              ),
                              clipBehavior: Clip.antiAlias, // Ensure the image respects the container's rounded corners
                              child: Image.network(
                                item.image,
                                fit: BoxFit.cover,
                                height: double.infinity,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "\$${item.price.toStringAsFixed(2)}",
                                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight, // Center the button horizontally in the available space
                                    child: GestureDetector(
                                      onTap: () => _showQuantityDialog(context, item, cartProvider),
                                      child: Container(
                                        padding: EdgeInsets.all(8), // Increase padding for a larger touch area
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.add_shopping_cart, color: Colors.white, size: 24), // Larger icon size
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuantityDialog(BuildContext context, Ingredient item, CartProvider cartProvider) {
    int currentQuantity = cartProvider.items.containsKey(item.id)
        ? cartProvider.items[item.id]!.quantity
        : 0;
    int quantity = currentQuantity;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: currentQuantity > 0 ? 250 : 200,
              // Adjust height if item is already in the cart
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Adjust Quantity",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 0) {
                            setState(() {
                              quantity--;
                            });
                          }
                        },
                      ),
                      Text(quantity.toString(),
                          style: const TextStyle(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                  ElevatedButton(
                    child: const Text('Confirm'),
                    onPressed: () {
                      if (quantity == 0) {
                        cartProvider.removeItem(item.id);
                      } else {
                        cartProvider.addItem(item, quantity - currentQuantity);
                      }
                      cartProvider.updateCart();
                      Navigator.pop(context); // Close the bottom sheet
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

}
