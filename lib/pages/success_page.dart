import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trainingapp1/database/db_helper.dart';

class DetailsPage extends StatefulWidget {
  final String email;

  DetailsPage({required this.email}) {
    print('DetailsPage constructor email: $email'); // Debugging
  }

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late Future<Map<String, dynamic>?> userDetails;
  late Future<String?> firstName;
  late Future<String?> lastName;

  @override
  void initState() {
    super.initState();
    print('DetailsPage initState email: ${widget.email}'); // Debugging
    userDetails = _fetchUserDetails();
    firstName = _fetchFirstName();
    lastName = _fetchLastName();
  }

  Future<String?> _fetchFirstName() async {
    final prefs= await SharedPreferences.getInstance();
    final firstName = prefs.getString('firstName');
    print('Fetched first name: $firstName'); // Debugging
    return firstName;
  }

  Future<String?> _fetchLastName() async {
    final prefs = await SharedPreferences.getInstance();
    final lastName = prefs.getString('lastName');
    print('Fetched last name: $lastName'); // Debugging
    return lastName;
  }

  Future<Map<String, dynamic>?> _fetchUserDetails() async {
    try {
      final dbHelper = DatabaseHelper();
      final email = widget.email.trim();
      if (email.isEmpty) {
        print('Email is empty');
        return null;
      }

      print('Fetching user with email: $email'); // Debugging
      final user = await dbHelper.getUserByEmail(email);
      if (user == null) {
        print('No user found with email: $email');
      } else {
        print('User found: $user');
      }

      return user;
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('firstName');
    await prefs.remove('lastName');
    await prefs.remove('token');
    Navigator.pushReplacementNamed(context, '/login'); // Navigate back to login page
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              constraints: BoxConstraints.expand(),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade100, Colors.orange.shade600],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: FutureBuilder<Map<String, dynamic>?>(
                future: userDetails,
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (userSnapshot.hasError) {
                    return Center(child: Text('Error: ${userSnapshot.error}'));
                  } else if (!userSnapshot.hasData || userSnapshot.data == null) {
                    return Center(child: Text('No user data found.'));
                  } else {
                    final user = userSnapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<String?>(
                            future: firstName,
                            builder: (context, nameSnapshot) {
                              if (nameSnapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              } else if (nameSnapshot.hasError) {
                                return Center(child: Text('Error: ${nameSnapshot.error}'));
                              } else if (!nameSnapshot.hasData || nameSnapshot.data == null) {
                                return Text('Hi, Guest');
                              } else {
                                final firstName = nameSnapshot.data!;
                                return FutureBuilder<String?>(
                                  future: lastName,
                                  builder: (context, lastNameSnapshot) {
                                    if (lastNameSnapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    } else if (lastNameSnapshot.hasError) {
                                      return Center(child: Text('Error: ${lastNameSnapshot.error}'));
                                    } else if (!lastNameSnapshot.hasData || lastNameSnapshot.data == null) {
                                      return Text('Hi, $firstName');
                                    } else {
                                      final lastName = lastNameSnapshot.data!;
                                      return Text(
                                        'Hi, $firstName $lastName',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      );
                                    }
                                  },
                                );
                              }
                            },
                          ),
                          SizedBox(height: 20),

                          // Centered green tick image
                          Center(
                            child: Image.asset(
                              'assets/images/green_tick.png', // Ensure this image is in your assets
                              width: 300,
                              height: 300,
                            ),
                          ),
                          SizedBox(height: 20),

                          // Logged in successfully message
                          Center(
                            child: Text(
                              'Logged in Successfully',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          // User details on the left side
                          Text(
                            'My Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Email: ${user['email']}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Gender: ${user['gender']}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Country: ${user['country']}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
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
                      content: Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white, // Grey background for 'No'
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(); // Dismiss dialog
                          },
                          child: Text(
                            'No',
                            style: TextStyle(
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.orange, // Orange background for 'Yes'
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            await _logout();
                          },
                          child: Text(
                            'Yes',
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
            ),
          ],
        ),
      ),
    );
  }
}
