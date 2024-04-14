import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../API/api.dart';
import '../Models/order_model.dart'; // Adjust import to your Order model

class OrderManage extends StatefulWidget {
  const OrderManage({super.key});

  @override
  _OrderManageState createState() => _OrderManageState();
}

class _OrderManageState extends State<OrderManage> with SingleTickerProviderStateMixin {
  late Future<List<Order>> futureOrders;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    futureOrders = Api.fetchOrders();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        backgroundColor: Colors.white, // Improved app bar look
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Orders'),
            Tab(text: 'Processing'),
            Tab(text: 'Shipping'),
            Tab(text: 'Delivered'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList('All'), // Filtered list for all orders
          _buildOrderList('Processing'), // Only processing orders
          _buildOrderList('Shipping'), // Only shipping orders
          _buildOrderList('Delivered'), // Only delivered orders
        ],
      ),
    );
  }

  Widget _buildOrderList(String status) {
    return FutureBuilder<List<Order>>(
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

        List<Order> orders = snapshot.data!;
        if (status != 'All') {
          orders = orders.where((order) => order.orderStatus == status).toList();
        }

        return ListView.separated(
          itemCount: orders.length,
          separatorBuilder: (context, index) => const Divider(color: Colors.grey),
          itemBuilder: (context, index) {
            Order order = orders[index];
            //double totalValue = calculateTotal(order.items);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order ID: ${order.id}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('User: ${order.userId}', style: TextStyle(fontSize: 14, color: Colors.black54)),
                      ),
                      Text('50', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text('Date Placed: ${DateFormat('dd MMM yyyy').format(order.createdAt)}', style: TextStyle(color: Colors.black54)),
                  SizedBox(height: 5),
                  _statusDropdown(order),
                ],
              ),
            );
          },
        );

      },
    );
  }




  Widget _statusDropdown(Order order) {
    // Ensuring the dropdown value always has a valid value.
    String dropdownValue = ['Processing', 'Shipping', 'Delivered'].contains(order.orderStatus)
        ? order.orderStatus
        : 'Processing'; // Default to 'Pending' or choose a suitable default

    return DropdownButton<String>(
      value: dropdownValue,
      underline: Container(), // Removes underline for a cleaner look
      icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
      items: <String>['Processing', 'Shipping', 'Delivered']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: Colors.black)),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null && newValue != order.orderStatus) {
          _updateOrderStatus(order.id, newValue);
        }
      },
    );
  }

}
