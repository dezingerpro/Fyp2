import 'package:flutter/material.dart';
import '../Models/order_model.dart';
import '../Models/user_model.dart';
import '../API/api.dart';
import 'package:intl/intl.dart';

class OrderDetailsPage extends StatefulWidget {
  final Order order;
  final Function(String, String) onStatusChange;

  const OrderDetailsPage({Key? key, required this.order, required this.onStatusChange}) : super(key: key);

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late Future<User> futureUser;

  @override
  void initState() {
    super.initState();
    futureUser = Api.fetchUserById(widget.order.userId);
  }

  void _showUpdateStatusDialog(BuildContext context, String orderId, String currentStatus) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newStatus = currentStatus;
        return AlertDialog(
          title: const Text('Update Order Status'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<String>(
                value: newStatus,
                items: <String>['Processing', 'Shipping', 'Delivered', 'Cancelled', 'Pending']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      newStatus = value;
                    });
                  }
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                widget.onStatusChange(orderId, newStatus);
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details', style: TextStyle(color: Colors.black,fontSize: 28,fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildOrderInfo(),
            const SizedBox(height: 20),
            FutureBuilder<User>(
              future: futureUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Error loading user information"));
                } else if (snapshot.hasData) {
                  User user = snapshot.data!;
                  return _buildUserInfo(user);
                } else {
                  return const Center(child: Text("User information not available"));
                }
              },
            ),
            const SizedBox(height: 20),
            _buildOrderItems(),
            const SizedBox(height: 20),
            _buildOrderActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${widget.order.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text('User: ${widget.order.userId}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                ),
                Text('Total: \$${widget.order.orderTotal}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 10),
            Text('Date Placed: ${DateFormat('dd MMM yyyy').format(widget.order.createdAt)}', style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Status: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                Text(widget.order.orderStatus, style: const TextStyle(fontSize: 16, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(User user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('User Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 10),
            Text('Username: ${user.username}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 10),
            Text('Contact: ${user.mobileNumber}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 10),
            Text('Address: ${user.streetAddress}, ${user.houseDetails}, ${user.city}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 10),
            ...widget.order.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Text('${item.quantity} x ${item.itemName}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderActions(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _showUpdateStatusDialog(context, widget.order.id, widget.order.orderStatus),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Update Order Status', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
