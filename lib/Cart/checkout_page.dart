import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/api.dart';
import '../Authentication/signin_screen.dart';
import '../Others/bottom_tabs.dart';
import '../provider/cart_provider.dart';
import 'order_summary.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isLoggedIn = false;
  late double totalPrice;
  Map<String, TextEditingController> _controllers = {
    'name': TextEditingController(),
    'phoneNumber': TextEditingController(),
    'address': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _checkLoginStatusAndFetchUserDetails();
  }

  void _checkLoginStatusAndFetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (_isLoggedIn) {
      var userData = await Api.fetchUser(); // Assume this returns a Map<String, dynamic> of user data
      if (userData != null) {
        setState(() {
          _controllers['name']?.text = userData['uname'] ?? '';
          _controllers['phoneNumber']?.text = userData['umobile'] ?? '';
          _controllers['address']?.text = "${userData['ustreet'] ?? ''}, ${userData['ucity'] ?? ''}, ${userData['uhouse'] ?? ''}";
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout',style: TextStyle(
          fontSize: 28,fontWeight: FontWeight.bold
        ),),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : _isLoggedIn ? buildCheckoutForm() : _buildSignInPrompt(),
    );
  }

  Widget buildCheckoutForm() {
    final cartProvider = Provider.of<CartProvider>(context);
    totalPrice = cartProvider.totalAmount;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // List of products
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cartProvider.items.length,
              itemBuilder: (context, index) {
                final cartItemKey = cartProvider.items.keys.elementAt(index);
                final cartItem = cartProvider.items[cartItemKey];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        cartItem!.item.image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                      ),
                    ),
                    title: Text(cartItem.item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text('Rs ${cartItem.item.price} x ${cartItem.quantity}', style: const TextStyle(fontSize: 14)),
                    trailing: Text('Rs ${(cartItem.item.price * cartItem.quantity).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                );
              },
            ),
            const Divider(),
            // Summary
            _buildSummaryTile(context, 'Total', 'Rs ${cartProvider.totalAmount.toStringAsFixed(2)}'),
            _buildSummaryTile(context, 'Discount', '-Rs ${cartProvider.discountAmount.toStringAsFixed(2)}'),
            _buildSummaryTile(context, 'Delivery Charges', 'Rs ${cartProvider.deliveryCharge.toStringAsFixed(2)}'),
            _buildSummaryTile(context, 'Final Price', 'Rs ${cartProvider.finalPrice.toStringAsFixed(2)}'),
            const Divider(),
            // Payment Method
            const ListTile(
              title: Text('Mode of Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text('Cash On Delivery (COD)', style: TextStyle(fontSize: 14)),
            ),
            // Voucher/Coupon
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Add Voucher/Coupon',
                  prefixIcon: Icon(Icons.card_giftcard),
                ),
              ),
            ),
            // Customer Details
            _buildTextField('Name', _controllers['name']!, TextInputType.text, editable: !_isLoggedIn),
            _buildTextField('Phone Number', _controllers['phoneNumber']!, TextInputType.phone, editable: !_isLoggedIn),
            _buildTextField('Address', _controllers['address']!, TextInputType.text, maxLines: 3, editable: !_isLoggedIn),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _confirmOrder(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // double.infinity is the width and 50 is the height
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: const Text('Confirm Order', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTile(BuildContext context, String title, String value) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType keyboardType, {int maxLines = 1, bool editable = true}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: editable,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: label,
        ),
        style: TextStyle(fontSize: 16),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your $label';
          }
          if (label == 'Phone Number' && value.length != 10) {
            return 'Phone Number must be 10 digits';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSignInPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You need to sign in to proceed with the checkout.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const signInScreen()));
              },
              child: const Text('Sign In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmOrder(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') as String;

    List<Map<String, dynamic>> items = cartProvider.items.entries.map((entry) {
      return {
        'itemName': entry.value.item.name,
        'quantity': entry.value.quantity,
        'price': entry.value.item.price,
      };
    }).toList();

    bool success = await Api.placeOrder(userId, items,cartProvider.totalAmount.toString());
    if (success) {
      cartProvider.clear();
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: OrderSummaryPage(
            orderItems: items,
            totalPrice: totalPrice,
            orderStatus: 'Processing',
          ),
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to place order')));
    }
  }

}
