import 'package:flutter/material.dart';
import 'package:fyp2/provider/cart_provider.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: cartProvider.itemCount == 0
          ? Center(
        child: Text('Your cart is empty'),
      )
          : ListView.builder(
        itemCount: cartProvider.items.length,
        itemBuilder: (context, index) {
          final cartItemKey = cartProvider.items.keys.elementAt(index);
          final cartItem = cartProvider.items[cartItemKey];
          return ListTile(
            leading: Image.network(cartItem!.item.image, width: 50, height: 50, errorBuilder: (context, error, stackTrace) => Icon(Icons.error)),
            title: Text(cartItem.item.name),
            subtitle: Text("Quantity: ${cartItem.quantity}"),
            trailing: IconButton(
              icon: Icon(Icons.remove_shopping_cart),
              onPressed: () => cartProvider.removeItem(cartItemKey),
            ),
          );
        },
      ),
      // Optionally, display the total amount in the cart
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
