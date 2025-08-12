// lib/viewmodels/auth_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:mescolis/services/auth_service.dart';
import 'package:mescolis/models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  
  bool _isLoading = false;
  bool _isLoggedIn = false;
  User? _currentUser;
  String? _errorMessage;

  AuthViewModel(this._authService) {
    _checkLoginStatus();
  }

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  Future<void> _checkLoginStatus() async {
    _isLoggedIn = await _authService.isLoggedIn();
    if (_isLoggedIn) {
      _currentUser = await _authService.getCurrentUser();
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      _errorMessage = 'Veuillez remplir tous les champs';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    //ajbouni
    // _isLoading = false;
    // notifyListeners();
    // return true;

    try {
      await _authService.login(username, password);
      _isLoggedIn = true;
      _currentUser = await _authService.getCurrentUser();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Identifiants incorrects ou problème de connexion';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
