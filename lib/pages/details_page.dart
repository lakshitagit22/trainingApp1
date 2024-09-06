import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  final Map<String, dynamic> user;

  DetailsPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('First Name: ${user['firstName']}'),
            Text('Last Name: ${user['lastName']}'),
            Text('Email: ${user['email']}'),
            Text('Contact Number: ${user['contactNumber']}'),
            Text('Date of Birth: ${user['dateOfBirth']}'),
            Text('Gender: ${user['gender']}'),
            Text('Country: ${user['country']}'),
            Text('Terms Accepted: ${user['termsAccepted'] == 1 ? "Yes" : "No"}'),
          ],
        ),
      ),
    );
  }
}
