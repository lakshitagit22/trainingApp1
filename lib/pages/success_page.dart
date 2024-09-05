import 'package:flutter/material.dart';
import '../db_helper.dart';
import 'form_page.dart';

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
        // Use a gradient background that changes color from light orange to dark orange
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Center image
                      Image.asset(
                        'assets/images/green_tick.png', // Make sure to add the image to your assets
                        width: 350,
                        height:350,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Registered Successfully',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Hi, ${user['firstName']} ${user['lastName']}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
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
