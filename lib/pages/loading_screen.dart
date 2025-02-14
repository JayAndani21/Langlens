import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home_page.dart'; // Import HomePage

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();

    // Delay for 3 seconds before navigating to HomePage
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) { // ✅ Check if widget is still in the widget tree
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(onLoginSuccess: () {  },)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'LangLens',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Welcome To LangLens',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            
            
            const CupertinoActivityIndicator(
              radius: 12, // Adjust the size to match the second image
            ),
          ],
        ),
      ),
    );
  }
}
