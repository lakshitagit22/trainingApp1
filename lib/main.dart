import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trainingapp1/pages/login_page.dart';
// Update to your actual import
import 'package:trainingapp1/pages/success_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('email');

  runApp(MyApp(initialRoute: email != null ? '/details' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  MyApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Training App',
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => LoginPage(),
        '/details': (context) => DetailsPage(email: 'default_email'), // Handle this accordingly
      },
    );
  }
}
