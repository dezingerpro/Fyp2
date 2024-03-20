import 'package:flutter/material.dart';
import 'package:fyp2/Authentication/forgot_password.dart';
import 'package:fyp2/Authentication/signup_screen.dart';
import 'package:fyp2/landing_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/api.dart';
import '../Admin CRUD/admin_page.dart';

class signInScreen extends StatefulWidget {
  signInScreen({Key? key}) : super(key: key);

  @override
  State<signInScreen> createState() => _signInScreenState();
}

class _signInScreenState extends State<signInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  bool _obscuredconfirmpwd = true;
  final _emailcontroller = TextEditingController();
  final _passcontroller = TextEditingController();
  String error_message = "";
  String error_pwd = "";
  String? errorMessage;
  bool isLoading = false;
  bool? adminStatus;

  @override
  void initState() {
    checkLoginStatus();
    super.initState();
  }

  void checkLoginStatus() async {
    adminStatus = Api.adminStatus;
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    print("IS LOGGED IN IS $isLoggedIn");

    if (isLoggedIn) {
      saveLoginState();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MyHomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/login.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50), topRight: Radius.circular(50)),
            ),
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.3,
              left: MediaQuery.of(context).size.width * 0.03,
              right: MediaQuery.of(context).size.width * 0.03,
            ),
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.04,
                left: MediaQuery.of(context).size.width * 0.04,
                right: MediaQuery.of(context).size.width * 0.04,
              ),
              child: Form(
                key: _formSignInKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          fontSize: 24,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        "  Enter your login credentials",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _emailcontroller,
                        decoration: InputDecoration(
                            labelText: "Enter Email",
                            hintText: "Enter Email",
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(25.0),
                              borderSide: new BorderSide(),
                            ),
                            //fillColor: Colors.green
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.black,
                            )),
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          fontFamily: "Poppins",
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return ("Please Enter Your Email");
                          }
                          // reg expression for email validation
                          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                              .hasMatch(value)) {
                            return ("Please Enter a valid email");
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _emailcontroller.text = value!;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _passcontroller,
                        obscureText: _obscuredconfirmpwd,
                        obscuringCharacter: '*',
                        decoration: InputDecoration(
                          labelText: "Password",
                          hintText: "Enter Password",
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(25.0),
                            borderSide: new BorderSide(),
                          ),
                          //fillColor: Colors.green
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.black,
                          ),
                          suffixIcon: IconButton(
                            // Eye icon button for password visibility toggle
                            icon: Icon(_obscuredconfirmpwd
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscuredconfirmpwd = !_obscuredconfirmpwd;
                              });
                            },
                          ),
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        style: TextStyle(
                          fontFamily: "Poppins",
                        ),
                        validator: (value) {
                          RegExp regex = RegExp(r'^.{6,}$');
                          if (value!.isEmpty) {
                            return ("Password is required for login");
                          }
                          if (!regex.hasMatch(value)) {
                            return ("Enter Valid Password(Min. 6 Character)");
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _passcontroller.text = value!;
                        },
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => forgotPassword(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(150, 107, 241, 39),
                            minimumSize: Size(200, 40),
                          ),
                          onPressed: () {
                            signIn(_emailcontroller.text, _passcontroller.text);
                          },
                          child: isLoading
                              ? CircularProgressIndicator()
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Center(
                        child: Text(
                          'Or Login with',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color.fromRGBO(0, 49, 67, 100),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setBool('isAdmin', false);
                            prefs.setBool('isGuest',true); // Default to true if not set

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyHomePage(),
                              ),
                            );
                          },
                          child: Text("Login as a Guest"),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 80,
                          ),
                          const Text(
                            'Dont have a account',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(0, 49, 67, 100),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => signUpScreen(),
                                    ));
                              },
                              child: const Text(
                                "Sign up here",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

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
      bool checkStatus = await Api.getUser(data);

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
              builder: (context) => AdminPage(),

            ),(Route<dynamic> route) => false,
          );
        } else {
          saveLoginState();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isGuest',false);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(),
            ),(Route<dynamic> route) => false,
          );
        }
      } else {
        // Handle login failure
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Login Failed"),
              content: Text("Invalid email or password. Please try again."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
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
