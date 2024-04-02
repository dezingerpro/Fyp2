import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/api.dart'; // Adjust import path to your Api class
import '../Models/order_model.dart'; // Adjust import path to your Order model

class MyOrdersPage extends StatefulWidget {
  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  Future<List<Order>>? futureOrders; // Allow futureOrders to be nullable
  bool isLoading = true;

  @override
  initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId')!;
    setState(() {
      futureOrders = Api.fetchUserOrders(userId);
      isLoading = false; // Set loading to false after futureOrders is initialized
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Show a loading spinner while waiting for initialization
      return Scaffold(
        appBar: AppBar(title: Text('My Orders')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // Once initialized, futureOrders is non-null and can safely be used
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      body: FutureBuilder<List<Order>>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("An error occurred: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No orders found"));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Order order = snapshot.data![index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ExpansionTile(
                  title: Text('Order ID: ${order.id}'),
                  subtitle: Text('Status: ${order.orderStatus}'),
                  children: order.items.map<Widget>((item) {
                    return ListTile(
                      title: Text(item.itemName),
                      trailing: Text('Quantity: ${item.quantity}'),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
