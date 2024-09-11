import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trainingapp1/pages/login_page.dart';
import 'package:trainingapp1/pages/success_page.dart'; // Update import as needed

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('email');

  // Run the app with the appropriate initial route
  runApp(MyApp(initialRoute:'/login'));
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
        '/details': (context) => DetailsPage(email: 'exmaple@gmail.com'), // Ensure to handle email correctly in DetailsPage
      },
    );
  }
}
