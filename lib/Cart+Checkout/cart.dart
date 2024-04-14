import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fyp2/provider/cart_provider.dart';
import 'checkout_page.dart'; // Ensure this is correctly imported

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  "Cart",
                  style: TextStyle(
                    fontSize: 32,  // Large font size for emphasis
                    fontWeight: FontWeight.bold,  // Bold for visual impact
                    color: Colors.black,  // Thematic color consistency
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: 0.5, // As step 2 of 3, Menu (1) -> Cart (2) -> Checkout (3)
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Menu'),
                      Text('Cart'),
                      Text('Checkout'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: cartProvider.itemCount == 0
                  ? const Center(
                child: Text('Your cart is empty'),
              )
                  : ListView.builder(
                itemCount: cartProvider.items.length,
                itemBuilder: (context, index) {
                  final cartItemKey = cartProvider.items.keys.elementAt(index);
                  final cartItem = cartProvider.items[cartItemKey];
                  return ListTile(
                    leading: Image.network(
                      cartItem!.item.image,
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                    ),
                    title: Text(cartItem.item.name),
                    subtitle: Text("\$${cartItem.item.price} x ${cartItem.quantity}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                          onPressed: () => cartProvider.decreaseItemQuantity(cartItemKey),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                          onPressed: () => cartProvider.increaseItemQuantity(cartItemKey),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.blueGrey[50],
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Estimated Delivery Time:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '30 - 45 min', // Example time, adjust based on your app's logic
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: \$${cartProvider.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: cartProvider.itemCount > 0
                    ? () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutPage()));
                }
                    : null, // Disable if cart is empty
                icon: const Icon(Icons.payment),
                label: const Text('Checkout'),
                style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

