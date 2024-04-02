import 'package:flutter/material.dart';

class OrderSummaryPage extends StatelessWidget {
  final List<Map<String, dynamic>> orderItems;
  final double totalPrice;
  final String orderStatus;

  OrderSummaryPage({
    Key? key,
    required this.orderItems,
    required this.totalPrice,
    required this.orderStatus
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Summary'),
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
            title: Text('Order Status'),
            subtitle: Text(orderStatus),
          ),
          Text('Total Price: \$${totalPrice.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headline6),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/')); // Navigate back to the home page or another relevant page
            },
            child: Text('Continue Shopping'),
          )
        ],
      ),
    );
  }
}
