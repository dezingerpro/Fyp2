import 'package:flutter/material.dart';

import 'landing_page.dart';

class OrderSummaryPage extends StatelessWidget {
  final List<Map<String, dynamic>> orderItems;
  final double totalPrice;
  final String orderStatus;

  const OrderSummaryPage({
    super.key,
    required this.orderItems,
    required this.totalPrice,
    required this.orderStatus
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: orderItems.length,
              itemBuilder: (context, index) {
                var item = orderItems[index];
                return ListTile(
                  title: Text(item['itemName']),
                  subtitle: Text('Quantity: ${item['quantity']}'),
                  trailing: Text('\$${item['price']}'),
                );
              },
            ),

          ),
          ListTile(
            title: const Text('Order Status'),
            subtitle: Text(orderStatus),
          ),
          Text('Total Price: \$${totalPrice.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyHomePage(),
                ),(Route<dynamic> route) => false,
              );
            },
            child: const Text('Continue Shopping'),
          )
        ],
      ),
    );
  }
}
