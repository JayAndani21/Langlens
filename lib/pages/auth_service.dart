import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class AuthService with ChangeNotifier {
  String? _token;
  String? get token => _token;
  static const String _baseUrl = 'http://10.0.2.2:5000';
  final Logger _logger = Logger();

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
      _logger.e('Signup error: $e');
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> login(String email, String password) async {
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
        await _saveUserData(responseData); // Save user data
        notifyListeners();
        return _token;
      } else {
        throw responseData['message'] ?? 'Login failed';
      }
    } catch (e) {
      _logger.e('Login error: $e');
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);

    // Add null checks and explicit key names
    await prefs.setString('name', data['name']?.toString() ?? 'No Name');
    await prefs.setString('email', data['email']?.toString() ?? 'No Email');

  
  }

  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');

    if (storedToken != null) {
      _token = storedToken;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _token = null;
    notifyListeners();
  }

  Future<void> _saveToken() async {
    if (_token == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null;
  }

  Future<void> fetchUserData() async {
    if (!await isAuthenticated()) {
      _logger.w('Unauthorized access attempt');
      throw 'User is not authenticated';
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$_baseUrl/user/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      _logger.i('User data fetched: $userData');
    } else {
      _logger.e('Failed to load user data');
      throw 'Failed to load user data';
    }
  }

  Future<void> deleteAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw 'User is not authenticated';
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/user/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.headers['content-type']?.contains('application/json') ==
          true) {
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          await prefs.clear();
          _token = null;
          notifyListeners();
        } else {
          throw responseData['message'] ?? 'Failed to delete account';
        }
      } else {
        throw 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _logger.e('Delete account error: $e');
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw 'User is not authenticated';
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/user/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );
// Check if the response is JSON
      if (response.headers['content-type']?.contains('application/json') ==
          true) {
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          _logger.i('Password changed successfully');
        } else {
          throw responseData['message'] ?? 'Failed to change password';
        }
      } else {
        // Handle HTML response (e.g., 404 or 500 error)
        throw 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _logger.e('Change password error: $e');
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> changeEmail(String newEmail, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw 'User is not authenticated';
      }
      final response = await http.post(
        Uri.parse('$_baseUrl/user/change-email'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'newEmail': newEmail,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        await prefs.setString('email',
            responseData['email']); // Update email in SharedPreferences
        _logger.i('Email changed successfully');
      } else {
        final responseData = jsonDecode(response.body);
        throw responseData['message'] ?? 'Failed to change email';
      }
    } catch (e) {
      _logger.e('Change email error: $e');
      throw e.toString().replaceAll('Exception: ', '');
    }
  }
}
