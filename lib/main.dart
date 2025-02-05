import 'package:flutter/material.dart';
import 'pages/loading_screen.dart'; // Import LoadingScreen
import 'pages/home_page.dart'; // Import HomePage (if needed for navigation)

void main() => runApp(const LangLensApp());

class LangLensApp extends StatelessWidget {
  const LangLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LangLens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        // Add more theme customizations if needed
      ),
      // Set LoadingScreen as the first screen
      home: const LoadingScreen(),
      // Define routes for navigation (optional)
      routes: {
        '/home': (context) => const HomePage(), // Add HomePage route
      },
    );
  }
}