import 'package:flutter/material.dart';
import '../db_helper.dart';
class DetailsPage extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final String country;

  DetailsPage({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('First Name: $firstName', style: TextStyle(fontSize: 18)),
            Text('Last Name: $lastName', style: TextStyle(fontSize: 18)),
            Text('Email: $email', style: TextStyle(fontSize: 18)),
            Text('Gender: $gender', style: TextStyle(fontSize: 18)),
            Text('Country: $country', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
