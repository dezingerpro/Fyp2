import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';
import '../Others/bottom_tabs.dart';

class OrderSummaryPage extends StatelessWidget {
  final List<Map<String, dynamic>> orderItems;
  final double totalPrice;
  final String orderStatus;
  final VoidCallback onContinueShopping;

  const OrderSummaryPage({
    super.key,
    required this.orderItems,
    required this.totalPrice,
    required this.orderStatus,
    required this.onContinueShopping,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Order completion animation
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Lottie.asset(
              'assets/animations/order_success.json', // Make sure to have a Lottie animation file
              width: 200,
              height: 200,
              fit: BoxFit.fill,
              repeat: false, // Do not repeat the animation
            ),
          ),
          const Text(
            'Thank you for your order!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your order will be delivered in 30-45 mins.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: AnimationLimiter(
              child: ListView.builder(
                itemCount: orderItems.length,
                itemBuilder: (context, index) {
                  var item = orderItems[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: item['image'] != null
                                  ? Image.network(
                                item['image'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported),
                              ),
                            ),
                            title: Text(item['itemName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Quantity: ${item['quantity']}'),
                            trailing: Text('\$${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Order Status', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(orderStatus, style: const TextStyle(color: Colors.deepPurple)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Total Price', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('\$${totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, color: Colors.deepPurple)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onContinueShopping,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: const Text('Continue Shopping', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
