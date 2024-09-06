import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    print('DetailsPage initState email: ${widget.email}'); // Debugging
    userDetails = _fetchUserDetails();
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
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
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return Center(child: Text('No user data found.'));
              } else {
                final user = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting text at the top left
                      Text(
                        'Hi, ${user['firstName']} ${user['lastName']}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Centered green tick image
                      Center(
                        child: Image.asset(
                          'assets/images/green_tick.png', // Make sure to add the image to your assets
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
                            // fontWeight: FontWeight.bold,
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
                        'Email:            ${user['email']}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Gender:         ${user['gender']}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Country:        ${user['country']}',
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
      ),
    );
  }
}
