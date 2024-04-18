import 'package:flutter/material.dart';
import 'package:fyp2/provider/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../API/api.dart';
import 'order_summary.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // List of products
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
                  subtitle: Text('\$${cartItem.item.price} x ${cartItem.quantity}'),
                  trailing: Text('\$${(cartItem.item.price * cartItem.quantity).toStringAsFixed(2)}'),
                );
              },
            ),
            const Divider(),
            // Summary
            ListTile(
              title: const Text('Total'),
              trailing: Text('\$${cartProvider.totalAmount.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: const Text('Discount'),
              // Assuming you have a method to calculate discount
              trailing: Text('-\$${cartProvider.discountAmount.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: const Text('Delivery Charges'),
              // Assuming a flat rate or calculated based on items/location
              trailing: Text('\$${cartProvider.deliveryCharge.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: const Text('Final Price'),
              trailing: Text('\$${cartProvider.finalPrice.toStringAsFixed(2)}'),
            ),
            const Divider(),
            // Payment Method
            const ListTile(
              title: Text('Mode of Payment'),
              subtitle: Text('Cash On Delivery (COD)'),
            ),
            // Voucher/Coupon
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Add Voucher/Coupon',
                ),
              ),
            ),
            // Customer Details
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Phone Number',
                ),
                keyboardType: TextInputType.phone,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Address',
                ),
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _confirmOrder(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // double.infinity is the width and 50 is the height
              ),
              child: const Text('Confirm Order'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmOrder(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') as String;
    //String userId = ; // Assume you have a way to obtain the user's ID, e.g., from SharedPreferences

    List<Map<String, dynamic>> items = cartProvider.items.entries.map((entry) {
      return {
        'itemName': entry.value.item.name,
        'quantity': entry.value.quantity,
        'price': entry.value.item.price, // If you want to include price
      };
    }).toList();

    bool success = await Api.placeOrder(userId, items);
    print(success);
    if (success) {
      // Clear the cart
      cartProvider.clear();
      // Navigate to the OrderSummaryPage
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: OrderSummaryPage(
            orderItems: items,
            totalPrice: cartProvider.totalAmount,
            orderStatus: 'Processing',
          ),
        ),
      ));
    } else {
      // Handle failure
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to place order')));
    }
  }

}
