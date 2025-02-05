import 'package:flutter/material.dart';
import 'pages/loading_screen.dart'; // Import LoadingScreen

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
      ),
      home: const LoadingScreen(), // ✅ Set LoadingScreen as the first screen
    );
  }
}
