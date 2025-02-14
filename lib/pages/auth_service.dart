import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  String? _token;
  String? get token => _token;

  // Use 10.0.2.2 for Android emulator or your actual IP for real devices
  static const String _baseUrl = 'https://langlens-2.onrender.com';

  Future<void> signup(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _token = responseData['token'];
        await _saveToken();
        notifyListeners();
      } else {
        throw responseData['message'] ?? 'Registration failed';
      }
    } catch (e) {
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _token = responseData['token'];
        await _saveToken();
        notifyListeners();
      } else {
        throw responseData['message'] ?? 'Login failed';
      }
    } catch (e) {
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');
    
    if (storedToken != null) {
      _token = storedToken;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  Future<void> _saveToken() async {
    if (_token == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);
  }
}