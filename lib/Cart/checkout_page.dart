import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/api.dart';
import '../Authentication/signin_screen.dart';
import '../Others/notifications.dart';
import '../main.dart';
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
  String? _savedCard; // Variable to store saved card details
  String _cardType = ''; // Move cardType to the state class
  String _paymentMethod = 'COD'; // Default payment method
  late double totalPrice;
  final Map<String, TextEditingController> _controllers = {
    'name': TextEditingController(),
    'phoneNumber': TextEditingController(),
    'address': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _checkLoginStatusAndFetchUserDetails();
    _loadSavedCardDetails(); // Load saved card details
  }



  void _loadSavedCardDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedCard = prefs.getString('savedCard');
    });
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
          String street = userData['ustreet'] ?? '';
          String city = userData['ucity'] ?? '';
          String house = userData['uhouse'] ?? '';
          if (street.isEmpty || city.isEmpty || house.isEmpty) {
            _controllers['address']?.text = '';
          } else {
            _controllers['address']?.text = "$street, $city, $house";
          }
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

  void _removeSavedCard() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('savedCard'); // Remove saved card from SharedPreferences

    setState(() {
      _savedCard = null; // Update the state to reflect that no card is saved
      _paymentMethod = 'COD'; // Reset payment method to COD or default
    });

    // Show a snackbar or toast to inform the user that the card has been removed
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved card removed successfully.')),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isLoggedIn
              ? buildCheckoutForm()
              : _buildSignInPrompt(),
    );
  }

  Widget buildCheckoutForm() {
    final cartProvider = Provider.of<CartProvider>(context);
    totalPrice = cartProvider.totalAmount;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                        ),
                      ),
                      title: Text(cartItem.item.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text(
                          'Rs ${cartItem.item.price} x ${cartItem.quantity}',
                          style: const TextStyle(fontSize: 14)),
                      trailing: Text(
                          'Rs ${(cartItem.item.price * cartItem.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  );
                },
              ),
              const Divider(),
              // Summary
              _buildSummaryTile(context, 'Total',
                  'Rs ${cartProvider.totalAmount.toStringAsFixed(2)}'),
              _buildSummaryTile(context, 'Discount',
                  '-Rs ${cartProvider.discountAmount.toStringAsFixed(2)}'),
              _buildSummaryTile(context, 'Delivery Charges',
                  'Rs ${cartProvider.deliveryCharge.toStringAsFixed(2)}'),
              _buildSummaryTile(context, 'Final Price',
                  'Rs ${cartProvider.finalPrice.toStringAsFixed(2)}'),
              const Divider(),
              // Payment Method
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile<String>(
                    title: const Text('Cash On Delivery (COD)'),
                    value: 'COD',
                    groupValue: _paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _paymentMethod = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _savedCard != null
                                ? 'Pay with Card (Saved: **** **** **** $_savedCard)'
                                : 'Pay with Card',
                          ),
                        ),
                        if (_savedCard != null) // Show delete icon only if a card is saved
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: _removeSavedCard, // Function to remove saved card
                          ),
                      ],
                    ),
                    value: 'Card',
                    groupValue: _paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _paymentMethod = value!;
                      });
                    },
                  ),
                ],
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
              _buildTextField('Name', _controllers['name']!, TextInputType.text,
                  editable: false),
              _buildTextField('Phone Number', _controllers['phoneNumber']!,
                  TextInputType.phone,
                  editable: false),
              _buildTextField(
                  'Address', _controllers['address']!, TextInputType.text,
                  maxLines: 3, editable: false),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _confirmOrder1(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity,
                      50), // double.infinity is the width and 50 is the height
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: const Text('Confirm Order',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSummaryTile(BuildContext context, String title, String value) {
    return ListTile(
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      trailing: Text(value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      TextInputType keyboardType,
      {int maxLines = 1, bool editable = true}) {
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
        style: const TextStyle(fontSize: 16),
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
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const signInScreen()), // Replace with your sign-in screen
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmOrder1(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedCard = prefs.getString('savedCard');

    if (_paymentMethod == 'Card') {
      if (savedCard == null) {
        // No card is saved, prompt the user to enter card details
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => _buildCardDetailsDialog(context),
        );

        // Check the result from the dialog
        if (result == true) {
          // Card details saved; update UI to show saved card but do not proceed with order
          setState(() {
            _savedCard = prefs.getString('savedCard');
          });
          // Show a snackbar or toast to inform the user that the card has been saved
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Card details saved. Please confirm your order again.')),
          );
        }
      } else {
        // Card is saved, proceed with the order
        if (mounted) {
          await _confirmOrder(context);
        }
      }
    } else if (_paymentMethod == 'COD') {
      // If COD is selected, proceed with the order
      if (mounted) {
        await _confirmOrder(context);
      }
    }
  }





  Widget _buildCardDetailsDialog(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController _cardNumberController = TextEditingController();
    final TextEditingController _expiryDateController = TextEditingController();
    final TextEditingController _cvvController = TextEditingController();

    // Automatically add slash to expiry date
    void onExpiryChange(String input) {
      if (input.length == 2 && !_expiryDateController.text.contains('/')) {
        _expiryDateController.text = '$input/';
        _expiryDateController.selection = TextSelection.fromPosition(
          TextPosition(offset: _expiryDateController.text.length),
        );
      }
    }


    void updateCardType(String input) {
      // Remove any spaces for matching
      input = input.replaceAll(' ', '');

      String detectedCardType = ''; // Temporary variable to detect card type

      if (RegExp(r'^4[0-9]{0,15}$').hasMatch(input)) {
        detectedCardType = 'Visa';
      } else if (RegExp(r'^(?:5[1-5][0-9]{0,14}|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{0,2}|27[01][0-9]|2720)[0-9]{0,}$').hasMatch(input)) {
        detectedCardType = 'MasterCard';
      } else if (RegExp(r'^62[0-9]{0,17}$').hasMatch(input)) {
        detectedCardType = 'UnionPay';
      }

      // Use setState to update the card type and trigger rebuild
      setState(() {
        _cardType = detectedCardType;
      });
    }


    // Format card number and detect type
    void formatCardNumber(String input, StateSetter setState) {
      // Save the previous cursor position before formatting
      int previousCursorPosition = _cardNumberController.selection.baseOffset;

      // Remove all non-digit characters
      String cleaned = input.replaceAll(RegExp(r'\D'), '');

      // Insert spaces after every 4 digits
      String formatted = '';
      for (int i = 0; i < cleaned.length; i++) {
        if (i > 0 && i % 4 == 0) {
          formatted += ' ';
          if (i < previousCursorPosition) {
            previousCursorPosition++; // Adjust cursor position for each space added
          }
        }
        formatted += cleaned[i];
      }

      // Ensure cursor doesn't go out of bounds
      if (previousCursorPosition > formatted.length) {
        previousCursorPosition = formatted.length;
      }

      // Update the controller's value and set the adjusted cursor position
      _cardNumberController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: previousCursorPosition),
      );

      // Update card type based on formatted input
      setState(() {
        updateCardType(formatted.replaceAll(' ', ''));
      });
    }

    return AlertDialog(
      title: const Text("Enter Card Details"),
      content: SingleChildScrollView(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  // Card Type Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Visa Icon
                      ColorFiltered(
                        colorFilter: _cardType == 'Visa'
                            ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                            : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                        child: Image.asset(
                          'assets/visa.jpg',
                          width: 40,
                          height: 40,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // MasterCard Icon
                      ColorFiltered(
                        colorFilter: _cardType == 'MasterCard'
                            ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                            : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                        child: Image.asset(
                          'assets/mastercard.jpg',
                          width: 40,
                          height: 40,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // UnionPay Icon
                      ColorFiltered(
                        colorFilter: _cardType == 'UnionPay'
                            ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                            : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                        child: Image.asset(
                          'assets/unionpay.jpg',
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Card Number Input
                  TextFormField(
                    controller: _cardNumberController,
                    decoration: InputDecoration(
                      labelText: "Card Number",
                      hintText: "1234 5678 9012 3456",
                      suffixText: _cardType,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      formatCardNumber(value, setState);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your card number';
                      }
                      if (!RegExp(r'^[0-9]{16}$').hasMatch(value.replaceAll(' ', ''))) {
                        return 'Enter a valid 16-digit card number';
                      }
                      return null;
                    },
                  ),
                  // Expiry Date Input
                  TextFormField(
                    controller: _expiryDateController,
                    decoration: const InputDecoration(
                      labelText: "Expiry Date",
                      hintText: "MM/YY",
                    ),
                    keyboardType: TextInputType.datetime,
                    onChanged: onExpiryChange,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the expiry date';
                      }
                      if (!RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$').hasMatch(value)) {
                        return 'Enter a valid expiry date (MM/YY)';
                      }
                      return null;
                    },
                  ),
                  // CVV Input
                  TextFormField(
                    controller: _cvvController,
                    decoration: const InputDecoration(
                      labelText: "CVV",
                      hintText: "123",
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the CVV';
                      }
                      if (!RegExp(r'^[0-9]{3}$').hasMatch(value)) {
                        return 'Enter a valid 3-digit CVV';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(false); // Return false when "Cancel" is pressed
          },
        ),
        TextButton(
          child: const Text('Confirm'),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              // Save the last 4 digits of the card number as saved card details
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String cardNumber = _cardNumberController.text.replaceAll(' ', '');
              await prefs.setString('savedCard', cardNumber.substring(cardNumber.length - 4));

              // Update the saved card state
              setState(() {
                _savedCard = cardNumber.substring(cardNumber.length - 4);
              });

              Navigator.of(context).pop(true); // Close the dialog and return true
            }
          },
        ),
      ],
    );
  }

  void showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'high_importance_channel', // Make sure this matches your channel ID
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID (you can use different IDs to handle multiple notifications)
      title, // Dynamic notification title
      body, // Dynamic notification body
      platformChannelSpecifics,
      payload: 'item x', // Optional payload
    );
  }



  Future<void> _confirmOrder(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    if (_controllers['name']!.text.isEmpty ||
        _controllers['phoneNumber']!.text.isEmpty ||
        _controllers['address']!.text.isEmpty ||
        _controllers['address']!.text == '\'\'') {
      _showProfileIncompleteDialog();
      return;
    }

    String paymentStatus = _paymentMethod == 'Card' ? 'Paid' : 'Unpaid';


    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') as String;

    List<Map<String, dynamic>> items = cartProvider.items.entries.map((entry) {
      return {
        'itemName': entry.value.item.name,
        'quantity': entry.value.quantity,
        'price': entry.value.item.price,
      };
    }).toList();

    bool success = await Api.placeOrder(
        userId, items, cartProvider.totalAmount.toString(),paymentStatus);
    if (success) {
      showNotification('Order Placed', 'Your order has been placed successfully.');
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
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to place order')));
    }
  }

  void _showProfileIncompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Complete Your Profile'),
          content: const Text(
              'Please complete your profile to proceed with the checkout.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                Navigator.pop(context); // Go back to the previous screen (cart page)
              },child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                // Navigate to the profile completion page or make the fields editable
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}