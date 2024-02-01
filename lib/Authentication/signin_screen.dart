import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../API/api.dart';
import '../Admin CRUD/admin_page.dart';
import '../colors.dart';
import '../glasseff.dart';
import '../landing_page.dart';
import 'forgot_password.dart';
import 'signup_screen.dart';

class signInScreen extends StatefulWidget {
  signInScreen({Key? key}) : super(key: key);

  @override
  State<signInScreen> createState() => _signInScreenState();
}

class _signInScreenState extends State<signInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  bool _obscuredConfirmPwd = true;
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
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
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body:  GlassContainer(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width ,
            borderRadius: BorderRadius.circular(0),
            blur: 5.0,
            alignment: Alignment.center,
            child: Container(
              margin: EdgeInsets.all(16.0),
              child: Form(
                key: _formSignInKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [const Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          fontSize: 24,
                          letterSpacing: 2,
                        ),
                      ),
                        Image(image: AssetImage('assets/welcome.png'), width: 130, height: 150,)
                      ],),
                      const SizedBox(
                        height: 5,
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
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Enter Email",
                          hintText: "Enter Email",
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(),
                          ),
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.black,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          fontFamily: "Poppins",
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return ("Please Enter Your Email");
                          }
                          if (!RegExp(
                              "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                              .hasMatch(value)) {
                            return ("Please Enter a valid email");
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _emailController.text = value!;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _passController,
                        obscureText: _obscuredConfirmPwd,
                        obscuringCharacter: '*',
                        decoration: InputDecoration(
                          labelText: "Password",
                          hintText: "Enter Password",
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(),
                          ),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.black,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(_obscuredConfirmPwd
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscuredConfirmPwd =
                                !_obscuredConfirmPwd;
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
                          _passController.text = value!;
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
                            backgroundColor: Colors.purple.shade300,
                            minimumSize: Size(200, 40),
                          ),
                          onPressed: () {
                            signIn(
                                _emailController.text, _passController.text);
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
                          'Or Login as',
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade300,
                            minimumSize: Size(200, 40),
                          ),
                          onPressed: () async {

                            final prefs =
                            await SharedPreferences.getInstance();
                            prefs.setBool('isAdmin', false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyHomePage(),
                              ),
                            );
                          },
                          child: Text("Guest",
                            style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 80,
                          ),
                          const Text(
                            'Dont have an account',
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
                                ),
                              );
                            },
                            child: const Text(
                              "Sign up here",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

      String uemail = _emailController.text;
      String upass = _passController.text;

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
          print("HELLO");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminPage(),
            ),
          );
        } else {
          saveLoginState();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(),
            ),
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
