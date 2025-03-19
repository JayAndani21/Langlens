import 'package:flutter/material.dart';
import 'package:langlens/pages/auth_service.dart';
import 'package:provider/provider.dart';
import 'pages/loading_screen.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'services/ocr_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        Provider(create: (_) => OCRService()), 
      ],
      child: const LangLensApp(),
    ),
  );
}

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
      home: const LoadingScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(builder: (_) => HomePage(onLoginSuccess: () {}));
          case '/login':
            return MaterialPageRoute(builder: (_) => LoginPage(onLoginSuccess: () {}));
          default:
            return MaterialPageRoute(builder: (_) => const LoadingScreen());
        }
      },
    );
  }
}
