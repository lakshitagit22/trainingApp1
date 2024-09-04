import 'package:flutter/material.dart';
import 'package:trainingapp1/pages/form_page.dart';

// This is the entry point of the application
void main() {
  runApp(const MyApp());
}

// This class represents the main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Build the user interface (UI) of the app
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Disable the debug banner in the top left corner
      debugShowCheckedModeBanner: false,

      // Set the home screen of the app to the FormPage widget
      home: FormPage(),
    );
  }
}