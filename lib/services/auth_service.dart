// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mescolis/models/user_model.dart';

class AuthService {
  static const String _baseUrl = 'https://api-staging.mescolis.tn/api';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

        print("----- login ---------- result = jsonDecode(response.body) ----------------------");
        print("status ${response.statusCode}");
        print(jsonDecode(response.body));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        
        if (result['success'] == true) {
          // Store token and user data
          final token = result['token'];
          final user = User.fromJson(result['user']);
          
          await _storage.write(key: _tokenKey, value: token);
          await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
          
          print("----- Stored user data ----------------------");
          print("User ID: ${user.userId}");
          print("Agency ID: ${user.agencyId}");
          print("Username: ${user.username}");
          
          return {
            'status': 'success',
            'data': result,
          };
        } else {
          // API returned success: false (incorrect credentials)
          return {
            'status': 'error',
            'message': result['message'] ?? 'identifiant et/ou mot de passe invalides',
          };
        }
      } else {
        // Database error or other server issues
        return {
          'status': 'error',
          'message': 'Erreur , Veuillez réessayer !',
        };
      }
    } catch (e) {
      print("Error in login: $e");
      // Network error or other exceptions
      return {
        'status': 'error',
        'message': 'Erreur , Veuillez réessayer !',
      };
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<User?> getCurrentUser() async {
    try {
      final userJson = await _storage.read(key: _userKey);
      if (userJson != null) {
        final userData = jsonDecode(userJson);
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      print("Error getting current user: $e");
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final user = await getCurrentUser();
    return token != null && user != null;
  }
}