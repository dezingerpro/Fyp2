import 'package:flutter/material.dart';
import '../API/api.dart';
import '../Models/order_model.dart'; // Adjust import to your Order model

class orderManage extends StatefulWidget {
  const orderManage({super.key});

  @override
  _orderManageState createState() => _orderManageState();
}

class _orderManageState extends State<orderManage> {
  late Future<List<Order>> futureOrders;

  @override
  void initState() {
    super.initState();
    futureOrders = Api.fetchOrders();
  }

  void _updateOrderStatus(String orderId, String newStatus) async {
    bool success = await Api.updateOrderStatus(orderId, newStatus);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $newStatus')),
      );
      // Refresh the orders list to reflect the update
      setState(() {
        futureOrders = Api.fetchOrders();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update order status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        backgroundColor: Colors.deepPurple, // Improved app bar look
      ),
      body: FutureBuilder<List<Order>>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("An error occurred"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No orders found"));
          }

          return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.grey),
            itemBuilder: (context, index) {
              Order order = snapshot.data![index];
              return ListTile(
                title: Text('Order ID: ${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Status: ${order.orderStatus}'),
                trailing: _statusDropdown(order), // Extracted widget for better readability
              );
            },
          );
        },
      ),
    );
  }

  Widget _statusDropdown(Order order) {
    return DropdownButton<String>(
      value: order.orderStatus,
      underline: Container(), // Removes underline for a cleaner look
      icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
      items: <String>['Pending', 'Processing', 'Shipped', 'Delivered']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: Colors.black)),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          _updateOrderStatus(order.id, newValue);
        }
      },
    );
  }
}
