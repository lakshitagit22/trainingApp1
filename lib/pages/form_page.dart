import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import fluttertoast
import 'package:trainingapp1/database/db_helper.dart'; // Import the database helper
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trainingapp1/pages/login_page.dart';
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    // Removing all non-digit characters
    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');

    // Formatting the digits as dd/mm/yyyy
    String formattedText = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2 || i == 4) {
        formattedText += '/';
      }
      formattedText += digitsOnly[i];
    }

    // Ensuring the formatted text has at most 10 characters
    if (formattedText.length > 10) {
      formattedText = formattedText.substring(0, 10);
    }

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dobController = TextEditingController();
  String? _selectedGender;
  String? _country;
  bool _termsAccepted = false;
  bool _isPasswordVisible=false;
  bool _isConfirmPasswordVisible=false;
  String? _termsError;
  String? _genderError;
  String? _passwordError;
  String? _confirmPasswordError;

  List<String> _countries = ['USA', 'Canada', 'India', 'UK'];
  late SharedPreferences _prefs;
  bool _validatePassword(String password) {
    final RegExp regex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@&$^]).{6,}$');
    return regex.hasMatch(password);
  }
  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  void _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }
  Future<String?> _fetchUserData(String email) async {
    try {
      final dbHelper = DatabaseHelper();
      final user = await dbHelper.getUserByEmail(email);
      if (user != null) {
        // Extract and return the email from the user data
        print('User found: ${user['firstName']} ${user['lastName']}');
        return user['email']; // Return the email
      } else {
        print('No user found with that email.');
        return null; // Return null if no user is found
      }
    } catch (e) {
      print('Error fetching user: $e');
      return null; // Return null in case of an error
    }
  }

  Future<void> _selectedDate() async {
    final DateTime today = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: today.subtract(Duration(days: 365 * 18)), // Set an initial date to 18 years ago
      firstDate: DateTime(1900),
      lastDate: today.subtract(Duration(days: 1)), // Restrict selection to dates before today
    );
    if (pickedDate != null && pickedDate.isBefore(today)) {
      final DateFormat dateFormat=DateFormat('dd/MM/yyyy');
      setState(() {
        _dobController.text = dateFormat.format(pickedDate);
      });
    }
  }
  String hashPassword(String password){
    return md5.convert(utf8.encode(password)).toString();
  }
  Future<void> _registerUser() async {
    print('Register button pressed');

    setState(() {
      _termsError = _termsAccepted ? null : 'You must accept the terms and conditions';
      _genderError = _selectedGender == null ? 'Please select your gender' : null;
      _passwordError = _passwordController.text.isEmpty
          ? 'Password is required'
          : (!_validatePassword(_passwordController.text)
          ? 'Password must be at least 6 characters long and include an uppercase letter, a lowercase letter, a digit, and a special character'
          : null);

      _confirmPasswordError = _confirmPasswordController.text.isEmpty
          ? 'Confirm password is required'
          : _confirmPasswordController.text != _passwordController.text
          ? 'Passwords do not match'
          : null;
    });

    if (_formKey.currentState!.validate()) {
      print('Form is valid');

      if (_genderError == null && _termsError == null && _passwordError == null && _confirmPasswordError == null) {
        final user = {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'email': _emailController.text,
          'contactNumber': _contactNumberController.text,
          'password': _passwordController.text, // Consider hashing/encrypting this
          'dateOfBirth': _dobController.text,
          'gender': _selectedGender,
          'country': _country,
          'termsAccepted': _termsAccepted ? 1 : 0,
        };
        final email=_emailController.text;
        final password=_passwordController.text;
        final hashedPassword=hashPassword(password);
        try {
          final dbHelper = DatabaseHelper();

          final existingUser = await dbHelper.getUserByEmail(_emailController.text);
          if (existingUser != null) {
            Fluttertoast.showToast(
              msg: "User already registered",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            return;
          }

          await dbHelper.insertUser(user);
          print(_firstNameController.text);
          print(_lastNameController.text);
          print(_emailController.text);

          Fluttertoast.showToast(
            msg: "Registration Successful",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          _firstNameController.clear();
          _lastNameController.clear();
          _emailController.clear();
          _contactNumberController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
          _dobController.clear();
          setState(() {
            _selectedGender = null;
            _country = null;
            _termsAccepted = false;
            _termsError = null;
            _genderError = null;
            _passwordError = null;
            _confirmPasswordError = null;
          });

          await Future.delayed(Duration(seconds: 4));
          // Fetch the user data and store the email
          String? emaill = await _fetchUserData(_emailController.text);
          if (emaill != null) {
            print('Fetched email: $emaill');
          } else {
            print('Failed to fetch email.');
          }

          // Navigate to DetailsPage with the fetched email
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
          );

          // Clear the form fields
          // _firstNameController.clear();
          // _lastNameController.clear();
          // _emailController.clear();
          // _contactNumberController.clear();
          // _passwordController.clear();
          // _confirmPasswordController.clear();
          // _dobController.clear();
          // setState(() {
          //   _selectedGender = null;
          //   _country = null;
          //   _termsAccepted = false;
          //   _termsError = null;
          //   _genderError = null;
          //   _passwordError = null;
          //   _confirmPasswordError = null;
          // });
        } catch (e) {
          print('Error: $e');
        }
      }
    } else {
      print('Form is not valid');
      setState(() {});
    }
  }





  Widget radioWidget(String value) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = value;
            _genderError = null; // Clear gender error when selected
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            RadioTheme(
              data: RadioThemeData(
                fillColor: MaterialStateProperty.resolveWith((states) {
                  return Colors.orange;
                }),
                overlayColor: MaterialStateProperty.resolveWith((states) {
                  return Colors.orange.withOpacity(0.2);
                }),
              ),
              child: Radio<String>(
                value: value,
                groupValue: _selectedGender,
                onChanged: (val) {
                  setState(() {
                    _selectedGender = val;
                    _genderError = null; // Clear gender error when selected
                  });
                },
              ),
            ),
            SizedBox(width: 5),
            Text(
              value,
              style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        _dobController.text = "${pickedDate.toLocal()}".split(' ')[0]; // Format YYYY-MM-DD
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // print('First Name: $firstName');
    // print('Last Name: $lastName');
    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard when tapping outside of text fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.35,
                pinned: false,
                floating: true,
                snap: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/form_background.png',
                        fit: BoxFit.cover,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Create your account',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First Name
                          TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              labelText: 'First Name *',
                              errorStyle: TextStyle(color: Colors.red),
                              border: UnderlineInputBorder(),
                            ),
                            validator: (value) => value!.isEmpty ? 'First name is required' : null,
                          ),
                          SizedBox(height: 10),

                          // Last Name
                          TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: 'Last Name ',
                              border: UnderlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),

                          // Email Address
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email Address *',
                              errorStyle: TextStyle(color: Colors.red),
                              border: UnderlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Email is required';
                              }
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                              if (!emailRegex.hasMatch(value)) {
                                return 'Invalid email format';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10),

                          // Contact Number
                          TextFormField(
                            controller: _contactNumberController,
                            decoration: InputDecoration(
                              labelText: 'Contact Number',
                              border: UnderlineInputBorder(),
                              errorStyle: TextStyle(color: Colors.red),
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (value){
                              if(value!.isEmpty){
                                return null;
                              }

                              if(value.length!=10) return 'Contact number must be 10 digits long';
                              return null;
                            },
                          ),
                          SizedBox(height: 10),

                          // Date of Birth
                          // Date of Birth
                          TextFormField(
                            controller: _dobController,
                            decoration: InputDecoration(
                              labelText: 'Date of Birth',
                              border: UnderlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.calendar_today),
                                onPressed: _selectedDate,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              DateInputFormatter(),  // Use the custom date input formatter
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return null;
                              }

                              try {
                                // Parse the date using the correct format
                                final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
                                final DateTime selectedDate = dateFormat.parseStrict(value);
                                final DateTime currentDate = DateTime.now();

                                // Check if the date is not today or in the future
                                if (selectedDate.isAfter(currentDate) || selectedDate.isAtSameMomentAs(currentDate)) {
                                  return 'Date of birth cannot be today or a future date';
                                }

                                // Calculate age
                                int age = currentDate.year - selectedDate.year;
                                final bool isBeforeBirthday = currentDate.month < selectedDate.month ||
                                    (currentDate.month == selectedDate.month && currentDate.day < selectedDate.day);

                                if (isBeforeBirthday) {
                                  // Adjust age if the birthday hasn't occurred yet this year
                                  age--;
                                }

                                // Ensure the user is at least 18 years old
                                if (age < 18) {
                                  return 'You must be at least 18 years old';
                                }
                              } catch (e) {
                                // If parsing fails, return an error message for invalid date format
                                return 'Invalid date format';
                              }

                              return null; // Return null if validation passes
                            },
                          ),

                          SizedBox(height: 10),

                          // Country
                          DropdownButtonFormField<String>(
                            value: _country,
                            hint: Text('Select Country'),
                            items: _countries.map((String country) {
                              return DropdownMenuItem<String>(
                                value: country,
                                child: Text(country),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _country = value;
                              });
                            },
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),

                          // Gender
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Gender *',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.04,
                                  color: _genderError != null ? Colors.red : Colors.black,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: _genderError != null ? Colors.red : Colors.transparent,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    radioWidget('Male'),
                                    radioWidget('Female'),
                                    radioWidget('Other'),
                                  ],
                                ),
                              ),
                              if (_genderError != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 1, top: 4),
                                  child: Text(
                                    _genderError!,
                                    style: TextStyle(color: Colors.red, fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 10),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                                labelText: 'Password *',
                                errorText: _passwordError,
                                errorStyle: TextStyle(color: Colors.red),
                                border: UnderlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible? Icons.visibility : Icons.visibility_off,
                                    color: _passwordError==null? Colors.orange:Colors.grey,
                                  ),
                                  onPressed: (){
                                    setState(() {
                                      _isPasswordVisible =!_isPasswordVisible;
                                    });
                                  },
                                )
                            ),
                            obscureText: !_isPasswordVisible,
                            validator: (value) => _passwordError,
                          ),
                          SizedBox(height: 10),

                          // Confirm Password
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                                labelText: 'Confirm Password *',
                                errorText: _confirmPasswordError,
                                errorStyle: TextStyle(color: Colors.red),
                                border: UnderlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible? Icons.visibility:Icons.visibility_off,
                                    color: _confirmPasswordError==null ? Colors.orange:Colors.grey,
                                  ),
                                  onPressed: (){
                                    setState(() {
                                      _isConfirmPasswordVisible= !_isConfirmPasswordVisible;
                                    });
                                  },
                                )
                            ),
                            obscureText: !_isConfirmPasswordVisible,
                            validator: (value) => _confirmPasswordError,
                          ),
                          SizedBox(height: 10),

                          // Terms and Conditions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _termsAccepted,
                                onChanged: (value) {
                                  setState(() {
                                    _termsAccepted = value!;
                                    _termsError = null; // Clear error when checkbox is checked
                                  });
                                },
                              ),
                              Expanded(
                                child: Text('I accept the terms and conditions'),
                              ),
                            ],
                          ),
                          if (_termsError != null) // Display error message if terms not accepted
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text(
                                _termsError!,
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                          SizedBox(height: 20),

                          // Register Button
                          Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: ElevatedButton(
                                onPressed: _registerUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(
                                  'Register',
                                  style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.05),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}