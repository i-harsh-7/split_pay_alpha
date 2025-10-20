import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';


class AuthService {
  static const _base = 'https://split-pay-q4wa.onrender.com/api/v1';
  static User? _cachedUser;

  /// Sign up with name, email, phone and password.
  /// Returns the stored token on success.
  static Future<String> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final uri = Uri.parse('$_base/signUp');
    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'phone': phone, 'password': password}));

    final Map<String, dynamic> body = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      final token = body['token'] ?? body['data']?['token'];
      if (token != null && token is String) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
        } on MissingPluginException {
          _inMemory['auth_token'] = token;
        }
        
        // Cache user from signup response
        try {
          final Map<String, dynamic>? userMap = body['user'] is Map<String, dynamic> 
              ? body['user'] as Map<String, dynamic>
              : null;
          if (userMap != null) {
            _cachedUser = User(
              name: userMap['name']?.toString() ?? 'User',
              email: userMap['email']?.toString() ?? '',
            );
          }
        } catch (_) {}
        
        return token;
      }
      throw Exception(body['message'] ?? 'Sign up succeeded but no token returned');
    }
    throw Exception(body['message'] ?? 'Sign up failed');
  }

  /// Login with email and password. Returns token on success.
  static Future<String> login({
    required String email,
    required String password,
  }) async {
    // Clear cached user on new login
    _cachedUser = null;
    
    final uri = Uri.parse('$_base/login');
    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}));

    final Map<String, dynamic> body = jsonDecode(res.body);
    if (res.statusCode == 200) {
      final token = body['token'] ?? body['data']?['token'];
      if (token != null && token is String) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
        } on MissingPluginException {
          _inMemory['auth_token'] = token;
        }
        
        // Cache user if available in login payload
        try {
          final Map<String, dynamic>? userMap =
              (body['user'] is Map<String, dynamic>) ? body['user'] as Map<String, dynamic> :
              (body['data'] is Map<String, dynamic> && body['data']['user'] is Map<String, dynamic>)
                  ? body['data']['user'] as Map<String, dynamic>
                  : null;
          if (userMap != null) {
            _cachedUser = User(
              name: userMap['name']?.toString() ?? 'User',
              email: userMap['email']?.toString() ?? '',
            );
          }
        } catch (_) {
          // ignore user caching errors
        }
        return token;
      }
      throw Exception(body['message'] ?? 'Login succeeded but no token returned');
    }
    throw Exception(body['message'] ?? 'Login failed');
  }

  static Future<void> logout() async {
    // Clear cached user
    _cachedUser = null;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    } on MissingPluginException {
      // Tests or some dev environments may not have the plugin registered.
      _inMemory.remove('auth_token');
    }
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } on MissingPluginException {
      return _inMemory['auth_token'];
    }
  }

  /// Try to fetch user profile from common endpoints. Returns null if not available.
  static Future<User?> getProfile() async {
    if (_cachedUser != null) return _cachedUser;
    final token = await getToken();
    if (token == null) return null;

    final endpoints = ['/me', '/profile', '/users/me', '/user'];
    for (final ep in endpoints) {
      final uri = Uri.parse('$_base$ep');
      try {
        final res = await http.get(uri, headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        });
        if (res.statusCode == 200) {
          final Map<String, dynamic> body = jsonDecode(res.body);
          Map<String, dynamic>? payload = body;
          if (body['data'] is Map) payload = body['data'];
          if (body['user'] is Map) payload = body['user'];

          final name = payload?['name'] ?? payload?['fullName'] ?? payload?['username'] ?? payload?['firstName'];
          final email = payload?['email'] ?? payload?['emailId'];

          if ((name != null && name.toString().isNotEmpty) || (email != null && email.toString().isNotEmpty)) {
            final finalName = (name ?? email ?? 'User').toString();
            final finalEmail = (email ?? '').toString();
            _cachedUser = User(name: finalName, email: finalEmail);
            return _cachedUser;
          }
        }
      } catch (e) {
        // ignore and try next endpoint
      }
    }
    return null;
  }
  
  /// Clear the cached user (useful on logout)
  static void clearCache() {
    _cachedUser = null;
  }
}

class User {
  final String name;
  final String email;

  User({required this.name, required this.email});
}


// simple in-memory fallback for environments without shared_preferences plugin
final Map<String, String> _inMemory = {};