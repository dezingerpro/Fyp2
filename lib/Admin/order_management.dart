import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../API/api.dart';
import '../Models/order_model.dart';
import 'order_detail.dart';

class OrderManage extends StatefulWidget {
  const OrderManage({super.key});

  @override
  _OrderManageState createState() => _OrderManageState();
}

class _OrderManageState extends State<OrderManage> with SingleTickerProviderStateMixin {
  late Future<List<Order>> futureOrders;
  late TabController _tabController;
  String _selectedSortOption = 'Date';
  String _selectedSortType = 'Ascending';

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
      setState(() {
        futureOrders = Api.fetchOrders();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update order status')),
      );
    }
  }

  void _sortOrders(List<Order> orders) {
    if (_selectedSortOption == 'Date') {
      orders.sort((a, b) => _selectedSortType == 'Ascending'
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt));
    } else if (_selectedSortOption == 'Total Price') {
      orders.sort((a, b) => _selectedSortType == 'Ascending'
          ? double.parse(a.orderTotal).compareTo(double.parse(b.orderTotal))
          : double.parse(b.orderTotal).compareTo(double.parse(a.orderTotal)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 28)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.deepPurple,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepPurple,
          tabs: const [
            Tab(text: 'All Orders'),
            Tab(text: 'Processing'),
            Tab(text: 'Shipping'),
            Tab(text: 'Delivered'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _selectedSortOption,
                  icon: const Icon(Icons.sort, color: Colors.deepPurple),
                  items: <String>['Date', 'Total Price'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSortOption = newValue!;
                      futureOrders = Api.fetchOrders();
                    });
                  },
                ),
                DropdownButton<String>(
                  value: _selectedSortType,
                  icon: const Icon(Icons.swap_vert, color: Colors.deepPurple),
                  items: <String>['Ascending', 'Descending'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSortType = newValue!;
                      futureOrders = Api.fetchOrders();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList('All'),
                _buildOrderList('Processing'),
                _buildOrderList('Shipping'),
                _buildOrderList('Delivered'),
              ],
            ),
          ),
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

        _sortOrders(orders);

        return ListView.separated(
          itemCount: orders.length,
          separatorBuilder: (context, index) => const Divider(color: Colors.transparent),
          itemBuilder: (context, index) {
            Order order = orders[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OrderDetailsPage(order: order, onStatusChange: _updateOrderStatus),
                  ),
                );
              },
              child: Container(
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
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order ID: ${order.id}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text('User: ${order.userId}', style: TextStyle(fontSize: 14, color: Colors.black54)),
                        ),
                        Text('Total: \$${order.orderTotal}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text('Date Placed: ${DateFormat('dd MMM yyyy').format(order.createdAt)}', style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 5),
                    _statusDropdown(order),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _statusDropdown(Order order) {
    String dropdownValue = ['Processing', 'Shipping', 'Delivered', 'Cancelled'].contains(order.orderStatus)
        ? order.orderStatus
        : 'Processing';

    return DropdownButton<String>(
      value: dropdownValue,
      underline: Container(),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
      items: <String>['Processing', 'Shipping', 'Delivered', 'Cancelled']
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
