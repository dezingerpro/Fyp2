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
    bool isExpanded = false;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  'Order ID: $orderId',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: ${order.orderStatus}',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    Text(
                      'Date: ${formatDate(order.createdAt)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    Text(
                      'Payment Status: ${order.paidStatus}', // Add payment status
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: isExpanded
                    ? Column(
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
                    ListTile(
                      title: const Text('Total Price', style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text('\$${order.orderTotal}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    if (order.orderStatus == 'Pending')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            await _cancelOrder(order.id);
                          },
                          child: const Text('Cancel Order'),
                        ),
                      ),
                  ],
                )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _cancelOrder(String orderId) async {
    bool success = await Api.updateOrderStatus(orderId, 'Cancelled');
    if (success) {
      setState(() {
        fetchOrders(); // Refetch the orders
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order has been cancelled.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to cancel order. Please try again.')),
      );
    }
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

          // Sort orders by date (latest first)
          List<Order> sortedOrders = snapshot.data!
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          List<Order> completedOrders = filterOrders(sortedOrders, 'Completed');
          List<Order> processingOrders = filterOrders(sortedOrders, 'Pending');
          List<Order> cancelledOrders = filterOrders(sortedOrders, 'Cancelled');

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
