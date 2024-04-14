import 'package:flutter/material.dart';
import 'package:fyp2/Authentication/forgot_password.dart';
import 'package:fyp2/Authentication/signup_screen.dart';
import 'package:fyp2/landing_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/api.dart';
import '../Admin/admin_page.dart';
import '../Others/bottom_tabs.dart';

class signInScreen extends StatefulWidget {
  const signInScreen({super.key});

  @override
  State<signInScreen> createState() => _signInScreenState();
}

class _signInScreenState extends State<signInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  bool _obscuredconfirmpwd = true;
  final _emailcontroller = TextEditingController();
  final _passcontroller = TextEditingController();
  bool isLoading = false;
  bool? adminStatus;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopSection(context),
            _buildFormSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: const BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle, size: 80, color: Colors.white),
            SizedBox(height: 10),
            Text(
              "Welcome Back!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formSignInKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _emailcontroller,
              hintText: "Enter Email",
              icon: Icons.email,
              validator: _emailValidator,
            ),
            const SizedBox(height: 20),
            _buildPasswordField(),
            _buildForgotPasswordButton(context),
            _buildSignInButton(),
            _buildDivider(),
            _buildLoginAsGuestButton(context),
            _buildSignUpPrompt(context),
          ],
        ),
      ),
    );
  }

  TextFormField _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.purple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      validator: validator,
    );
  }

  String? _emailValidator(String? value) {
    if (value!.isEmpty) {
      return "Please enter your email";
    }
    if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
      return "Please enter a valid email";
    }
    return null;
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passcontroller,
      obscureText: _obscuredconfirmpwd,
      decoration: InputDecoration(
        hintText: "Password",
        prefixIcon: const Icon(Icons.lock, color: Colors.purple),
        suffixIcon: IconButton(
          icon: Icon(
            _obscuredconfirmpwd ? Icons.visibility_off : Icons.visibility,
            color: Colors.purple,
          ),
          onPressed: () {
            setState(() {
              _obscuredconfirmpwd = !_obscuredconfirmpwd;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return "Password is required for login";
        }
        if (value.length < 6) {
          return "Enter valid password (Min. 6 characters)";
        }
        return null;
      },
    );
  }

  Widget _buildForgotPasswordButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const forgotPassword()));
        },
        child: const Text('Forgot Password?', style: TextStyle(color: Colors.purple)),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (_formSignInKey.currentState!.validate()) {
            signIn(_emailcontroller.text, _passcontroller.text);
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: Colors.purple, // This is the text color
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Login", style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildDivider() {
    return const Column(
      children: [
        SizedBox(height: 20),
        Row(
          children: <Widget>[
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text("OR"),
            ),
            Expanded(child: Divider()),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLoginAsGuestButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MyHomePage()));
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black, backgroundColor: Colors.grey,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text("Login as a Guest", style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildSignUpPrompt(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text("Don't have an account?"),
        TextButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const signUpScreen()));
          },
          child: const Text("Sign up", style: TextStyle(color: Colors.purple)),
        ),
      ],
    );
  }

// Other methods...

  Future<void> checkAdminStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isAdmin') == true) {
      adminStatus = true;
    } else {
      adminStatus = false;
    }
  }

  void signIn(String email, String password) async {
    if (_formSignInKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      String uemail = _emailcontroller.text;
      String upass = _passcontroller.text;

      var data = {"uemail": uemail, "upass": upass};
      bool checkStatus = await Api.getUser(data,context);

      setState(() {
        isLoading = false;
      });
      if (checkStatus) {
        await checkAdminStatus();
        bool checkStatus1 = adminStatus as bool;
        print("ADMIN STATUS IS $adminStatus");
        if (checkStatus1) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isGuest',false);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminPage(),

            ),(Route<dynamic> route) => false,
          );
        } else {
          saveLoginState();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isGuest',false);
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainScreen())); // Navigate to MainScreen if logged in
        }
      } else {
        // Handle login failure
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Login Failed"),
              content: const Text("Invalid email or password. Please try again."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void saveLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
  }
}
