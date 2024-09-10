import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trainingapp1/database/db_helper.dart'; // Update to your actual DB helper import
import 'package:trainingapp1/pages/success_page.dart';
import 'package:trainingapp1/pages/form_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart'; //generates unique token for the user
import 'package:crypto/crypto.dart';
import 'dart:convert'; // for utf8.encode
import 'package:bcrypt/bcrypt.dart';
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _emailError;
  String? _passwordError;
  bool _isPasswordVisible = false;

  bool _validatePassword(String password) {
    // Implement your actual password validation logic
    return password.isNotEmpty; // Placeholder validation
  }
  String hashPassword(String password) {
    return md5.convert(utf8.encode(password)).toString();
  }
  Future<void> _loginUser() async {
    setState(() {
      _emailError = _emailController.text.isEmpty ? 'Email is required' : null;
      _passwordError = _passwordController.text.isEmpty
          ? 'Password is required'
          : (!_validatePassword(_passwordController.text)
          ? 'Invalid password'
          : null);
    });

    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;

      try {
        final dbHelper = DatabaseHelper();
        final user = await dbHelper.getUserByEmail(email);

        if (user != null) {
          print('Fetched user: $user'); // Debugging

          // Verify the password using BCrypt
          final hashedPassword = user['password'];
          if (BCrypt.checkpw(password, hashedPassword)) {
            // Store user details in SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('email', user['email']);
            await prefs.setString('firstName', user['firstName']); // Ensure this key matches your DB field
            await prefs.setString('lastName', user['lastName']); // Ensure this key matches your DB field

            // Generate and store token
            final uuid = Uuid();
            await prefs.setString('token', uuid.v4());

            // Navigate to the details page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsPage(
                  email: user['email'],
                ),
              ),
            );
            _emailController.clear();
            _passwordController.clear();
          } else {
            Fluttertoast.showToast(
              msg: "Invalid email or password",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: "User not found",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (e) {
        print('Error logging in: $e');
        Fluttertoast.showToast(
          msg: "An error occurred. Please try again.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            // Unfocus text fields when tapping outside
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/login_background.png',
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(25.0,50.0,25.0,25.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 30),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText: 'Email Address *',
                                      errorText: _emailError,
                                      border: UnderlineInputBorder(),
                                      labelStyle: TextStyle(color: Colors.black),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(color: Colors.black),
                                    validator: (value) => value!.isEmpty ? 'Email is required' : null,
                                  ),
                                  SizedBox(height: 16),
                                  TextFormField(
                                    controller: _passwordController,
                                    decoration: InputDecoration(
                                      labelText: 'Password *',
                                      errorText: _passwordError,
                                      border: UnderlineInputBorder(),
                                      labelStyle: TextStyle(color: Colors.black),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: _passwordError == null
                                              ? Colors.orange
                                              : Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordVisible = !_isPasswordVisible;
                                          });
                                        },
                                      ),
                                    ),
                                    obscureText: !_isPasswordVisible,
                                    style: TextStyle(color: Colors.black),
                                    validator: (value) => value!.isEmpty ? 'Password is required' : null,
                                  ),
                                  SizedBox(height: 50),
                                  ElevatedButton(
                                    onPressed: _loginUser,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      minimumSize: Size(double.infinity, 48),
                                    ),
                                    child: Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 80),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => FormPage()),
                                      );
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Don\'t have an account?\n',
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '\n',
                                          ),
                                          TextSpan(
                                            text: 'Register',
                                            style: TextStyle(
                                              color: Colors.lightBlueAccent,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
