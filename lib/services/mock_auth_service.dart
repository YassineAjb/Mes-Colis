// lib/services/mock_auth_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mescolis/models/user_model.dart';

class MockAuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Mock login response data
  final Map<String, dynamic> _mockLoginResponse = {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c",
    "user": {
      "id": "courier_001",
      "username": "ahmed.ben.ali",
      "name": "Ahmed Ben Ali",
      "email": "ahmed.benali@mescolis.com"
    }
  };

  // Test credentials
  final Map<String, String> _validCredentials = {
    'ahmed.ben.ali': 'password123',
    'test.courier': 'test123',
  };

  Future<bool> login(String username, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Check credentials
    if (_validCredentials[username] != password) {
      throw Exception('Invalid credentials');
    }

    // Simulate successful login
    final token = _mockLoginResponse['token'];
    final user = User.fromJson(_mockLoginResponse['user']);
    
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
    
    return true;
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<User?> getCurrentUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}