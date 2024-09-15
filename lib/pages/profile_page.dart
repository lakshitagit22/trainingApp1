import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trainingapp1/database/db_helper.dart'; // Update to your actual DB helper import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
// Import login page if needed
import 'package:permission_handler/permission_handler.dart';

import '../../flutter/packages/flutter/lib/material.dart';
enum AppState{
  free,
  picked,
  cropped,
}
class ProfilePage extends StatefulWidget {
  final String email;

  ProfilePage({required this.email});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
   File? _profileImage;
   late AppState state;
  bool _isChangePassword = false;
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _contactNumberController;
  late TextEditingController _dobController;
  late TextEditingController _genderController;
  late TextEditingController _countryController;
  String _selectedCountry = ''; // Default country
  String? _selectedGender;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _genderError;
  late Future<void> _initializeFuture;

  final List<String> _countries = [
    'United States',
    'Canada',
    'United Kingdom',
    'Australia',
    'India',
    'America',
  ];
  final ImagePicker _picker=ImagePicker();

  @override
  void initState() {
    super.initState();
    state=AppState.free;
    _initializeFuture = _initializeFields();
  }
   Future<void> _initializeFields() async {
     final dbHelper = DatabaseHelper();
     final user = await dbHelper.getUserByEmail(widget.email);

     if (user != null) {

       var profileImagePath = user['profileImagePath'];
       print('Loaded profile image: $profileImagePath');

       if (profileImagePath != null && profileImagePath.isNotEmpty) {

         setState(() {
           _profileImage = File(profileImagePath);
         });
       } else {
         //default image if user has not uploaded image
         setState(() {
           _profileImage = File('assets/images/default_image.png');
         });
       }

       _firstNameController = TextEditingController(text: user['firstName']);
       _lastNameController = TextEditingController(text: user['lastName']);
       _contactNumberController = TextEditingController(text: user['contactNumber']);
       _dobController = TextEditingController(text: user['dateOfBirth']);
       _genderController = TextEditingController(text: user['gender']);
       _countryController = TextEditingController(text: user['country']);
       _selectedCountry = user['country'] ?? ''; // Set selected country
       _selectedGender = user['gender'];
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
   }

  Future<void> requestPermissions() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      print("Camera permission granted");
    } else if (status.isDenied) {
      print("Camera permission denied");
    } else if (status.isPermanentlyDenied) {
      print("Camera permission permanently denied");
      // Open app settings for the user to grant permissions
      openAppSettings();
    }
  }
   Future<void> _chooseImageSource() async {
     final status = await Permission.camera.status;
     if (!status.isGranted) {
       await Permission.camera.request();
     }

     final pickedFile = await showModalBottomSheet<ImageSource>(
       context: context,
       builder: (context) => BottomSheet(
         onClosing: () {},
         builder: (context) => Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             ListTile(
               leading: Icon(Icons.camera_alt),
               title: Text('Take a photo'),
               onTap: () => Navigator.pop(context, ImageSource.camera),
             ),
             ListTile(
               leading: Icon(Icons.image),
               title: Text('Choose from gallery'),
               onTap: () => Navigator.pop(context, ImageSource.gallery),
             ),
           ],
         ),
       ),
     );

     if (pickedFile != null) {
       final pickedFilePath = (await ImagePicker().pickImage(source: pickedFile))?.path;

       if (pickedFilePath != null) {
         final croppedFile = await ImageCropper().cropImage(
           sourcePath: pickedFilePath,
           aspectRatioPresets: [
             CropAspectRatioPreset.square,
             CropAspectRatioPreset.ratio3x2,
             CropAspectRatioPreset.ratio4x3,
             CropAspectRatioPreset.ratio16x9
           ],
           androidUiSettings: AndroidUiSettings(
             toolbarTitle: 'Crop Image',
             toolbarColor: Colors.deepOrange,
             toolbarWidgetColor: Colors.white,
             initAspectRatio: CropAspectRatioPreset.square,
             lockAspectRatio: false,
           ),
           iosUiSettings: IOSUiSettings(
             minimumAspectRatio: 1.0,
           ),
         );

         if (croppedFile != null) {
           setState(() {
             _profileImage = File(croppedFile.path);
           });
         }
       }
     }
   }


   Future<void> _updateProfileImage(File image) async {
    final dbHelper = DatabaseHelper();
    try {
      print('Saving profile image :${image.path}');
      await dbHelper.updateUserProfileImage(widget.email, image.path);
      setState(() {
        _profileImage = image;
      });
      Fluttertoast.showToast(
        msg: "Profile image updated successfully",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error updating profile image",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
  String? _validateDOB(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date of Birth is required';
    }

    final dob = DateTime.tryParse(value);
    if (dob == null) {
      return 'Invalid Date of Birth format';
    }

    final age = DateTime.now().difference(dob).inDays ~/ 365;
    if (age < 18) {
      return 'You must be at least 18 years old';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required';
    }
    final RegExp regex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@&$^]).{6,}$');
    if (!regex.hasMatch(password)) {
      return 'Password must be at least 6 characters long, include an uppercase letter, a lowercase letter, a number, and a special character';
    }
    return null;
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_isChangePassword) {
        final newPassword = _passwordController.text;
        final confirmPassword = _confirmPasswordController.text;

        if (newPassword != confirmPassword) {
          Fluttertoast.showToast(
            msg: "Passwords do not match",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return;
        }

        final passwordValidationError = _validatePassword(newPassword);
        if (passwordValidationError != null) {
          Fluttertoast.showToast(
            msg: passwordValidationError,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return;
        }

        final hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

        final dbHelper = DatabaseHelper();
        try {
          await dbHelper.updateUserPassword(widget.email, hashedPassword);
          Fluttertoast.showToast(
            msg: "Password updated successfully",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } catch (e) {
          Fluttertoast.showToast(
            msg: "Error updating password",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }

      final updatedUser = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'contactNumber': _contactNumberController.text,
        'dateOfBirth': _dobController.text,
        'gender': _selectedGender ?? '',
        'country': _selectedCountry,
      };

      final dbHelper = DatabaseHelper();
      try {
        await dbHelper.updateUser(widget.email, updatedUser);
        Fluttertoast.showToast(
          msg: "Profile updated successfully",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Error updating profile",
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

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('firstName');
    await prefs.remove('lastName');
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _contactNumberController.dispose();
    _dobController.dispose();
    _genderController.dispose();
    _countryController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  content: Text('Are you sure you want to logout? '),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'NO',
                        style: TextStyle(
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await _logout();
                      },
                      child: Text(
                        'YES',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _initializeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: _profileImage==null ? AssetImage('assets/images/default_image.png') :FileImage(_profileImage!) as ImageProvider, // Placeholder image
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  _chooseImageSource();
                                  // Implement image picker
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.orange,
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField('First Name *', _firstNameController, isMandatory: true),
                            _buildTextField('Last Name', _lastNameController),
                            TextFormField(
                              initialValue: widget.email,
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'Email Address *',
                                border: UnderlineInputBorder(),
                                labelStyle: TextStyle(color: Colors.blue),
                              ),
                              style: TextStyle(color: Colors.black54),
                              validator: (value) => value!.isEmpty ? 'Email is required' : null,
                            ),
                            SizedBox(height: 20),
                            // _buildTextField('Contact Number', _contactNumberController),
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
                            TextFormField(
                              controller: _dobController,
                              decoration: InputDecoration(
                                labelText: 'Date of Birth',
                                border: UnderlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.calendar_today),
                                  onPressed: _selectDate, // Use the date picker method
                                ),
                              ),
                              validator: _validateDOB,
                            ),
                            SizedBox(height: 5),
                            DropdownButtonFormField<String>(
                              value: _selectedCountry,
                              items: _countries.map((country) {
                                return DropdownMenuItem<String>(
                                  value: country,
                                  child: Text(country),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCountry = value!;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Country',
                                border: UnderlineInputBorder(),
                                labelStyle: TextStyle(color: Colors.blue),
                              ),
                            ),
                            SizedBox(height: 5),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gender *',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.04,
                                    color: _genderError != null ? Colors.red : Colors.black,
                                  ),
                                ),
                                SizedBox(height: 3),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _isChangePassword,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _isChangePassword = value ?? false;
                                    });
                                  },
                                ),
                                Text(
                                  'Change Password',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            if (_isChangePassword) ...[
                              SizedBox(height: 10),
                              _buildPasswordField('Password *', _passwordController),
                              SizedBox(height: 10),
                              _buildPasswordField('Confirm Password *', _confirmPasswordController),
                              SizedBox(height: 20),
                            ],
                            ElevatedButton(
                              onPressed: _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                minimumSize: Size(double.infinity, 48),
                              ),
                              child: Text(
                                'Update Profile',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
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
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isMandatory = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blue),
          border: UnderlineInputBorder(),
        ),
        validator: (value) {
          if (isMandatory && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        border: UnderlineInputBorder(),
        labelStyle: TextStyle(color: Colors.black),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color:_passwordError==null? Colors.orange:Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        if (label.contains('Confirm') && _passwordController.text != _confirmPasswordController.text) {
          return 'Passwords do not match';
        }
        return _validatePassword(value);
      },
    );
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
                fillColor: WidgetStateProperty.resolveWith((states) {
                  return Colors.orange;
                }),
                overlayColor: WidgetStateProperty.resolveWith((states) {
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
}
