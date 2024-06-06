import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // For formatting date
import '../../API/api.dart'; // Adjust import path to your Api class
import '../../Models/order_model.dart'; // Adjust import path to your Order model

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> with SingleTickerProviderStateMixin {
  Future<List<Order>>? futureOrders; // Allow futureOrders to be nullable
  bool isLoading = true;
  late TabController _tabController;
  late int lastUsedCode;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    initializeLastUsedCode();
    fetchOrders();
  }

  Future<void> initializeLastUsedCode() async {
    final prefs = await SharedPreferences.getInstance();
    lastUsedCode = prefs.getInt('lastUsedCode') ?? 9999;
  }

  String generateUniqueCode(String orderId) {
    final hash = orderId.hashCode;
    final code = hash % 10000; // Ensure it stays within 4 digits
    return code.abs().toString().padLeft(4, '0'); // Ensure it's 4 digits, and handle negative hashes
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Order> filterOrders(List<Order> orders, String status) {
    return orders.where((order) => order.orderStatus == status).toList();
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  Widget buildOrderCard(Order order) {
    final orderId = 'FS${generateUniqueCode(order.id)}';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: $orderId',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Status: ${order.orderStatus}',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Date: ${formatDate(order.createdAt)}',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
        children: [
          ...order.items.map<Widget>((item) {
            return ListTile(
              title: Text(
                item.itemName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              trailing: Text(
                'Quantity: ${item.quantity}',
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          const Divider(),
          ListTile(
            title: const Text('Total Price', style: TextStyle(fontWeight: FontWeight.bold)),
            //trailing: Text('\$${order.price}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Completed'),
            Tab(text: 'Processing'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Order>>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("An error occurred: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No orders found"));
          }
          List<Order> completedOrders = filterOrders(snapshot.data!, 'Completed');
          List<Order> processingOrders = filterOrders(snapshot.data!, 'Pending');
          List<Order> cancelledOrders = filterOrders(snapshot.data!, 'Cancelled');

          return TabBarView(
            controller: _tabController,
            children: [
              buildOrderList(completedOrders),
              buildOrderList(processingOrders),
              buildOrderList(cancelledOrders),
            ],
          );
        },
      ),
    );
  }

  Widget buildOrderList(List<Order> orders) {
    if (orders.isEmpty) {
      return const Center(child: Text("No orders found"));
    }
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return buildOrderCard(orders[index]);
      },
    );
  }
}
