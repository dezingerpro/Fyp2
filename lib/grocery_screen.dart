import 'package:flutter/material.dart';
import 'package:fyp2/provider/cart_provider.dart';
import 'package:fyp2/provider/grocery_provider.dart';
import 'package:provider/provider.dart';
import '../Models/ingredients_model.dart';
import 'cart.dart'; // Ensure correct import path

class GroceryItemsPage extends StatefulWidget {
  @override
  _GroceryItemsPageState createState() => _GroceryItemsPageState();
}

class _GroceryItemsPageState extends State<GroceryItemsPage> {
  @override
  void initState() {
    super.initState();
    // Ensures the page content is refreshed when navigated back to this page.
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshGroceries());
  }

  void _refreshGroceries() {
    // Dummy method to simulate refreshing groceries. Implement your actual refresh logic here.
    final groceryProvider = Provider.of<GroceryProvider>(context, listen: false);
    groceryProvider.fetchGroceries(); // This method should be implemented in your GroceryProvider.
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
              padding: EdgeInsets.all(16),
              height: currentQuantity > 0 ? 250 : 200, // Adjust height if item is already in the cart
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Adjust Quantity",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 0) {
                            setState(() {
                              quantity--;
                            });
                          }
                        },
                      ),
                      Text(quantity.toString(), style: TextStyle(fontSize: 18)),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                  ElevatedButton(
                    child: Text('Confirm'),
                    onPressed: () {
                      if (quantity == 0) {
                        cartProvider.removeItem(item.id);
                      } else {
                        cartProvider.addItem(item, quantity - currentQuantity);
                      }
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

  @override
  Widget build(BuildContext context) {
    final groceryProvider = Provider.of<GroceryProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Shop Grocery'),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => CartPage())),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, color: Colors.black),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Consumer<CartProvider>(
                      builder: (context, cart, child) {
                        return Container(
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            '${cart.totalItemCount}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: groceryProvider.items.length,
        itemBuilder: (context, index) {
          final item = groceryProvider.items[index];
          int itemQuantity = cartProvider.getItemQuantity(item.id);

          return ListTile(
            leading: Image.network(item.image, width: 50, height: 50, errorBuilder: (context, error, stackTrace) => Icon(Icons.error)),
            title: Text(item.name),
            subtitle: Text("\$${item.price.toStringAsFixed(2)}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (itemQuantity > 0) Text('$itemQuantity x '),
                IconButton(
                  icon: Icon(Icons.add_shopping_cart),
                  onPressed: () => _showQuantityDialog(context, item, cartProvider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
