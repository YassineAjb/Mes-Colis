// lib/viewmodels/dashboard_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:mescolis/services/auth_service.dart';
import 'package:mescolis/services/package_service.dart';
import 'package:mescolis/models/dashboard_stats.dart';

class DashboardViewModel extends ChangeNotifier {
  final AuthService _authService;
  final PackageService _packageService = PackageService();

  bool _isLoading = false;
  DashboardStats? _stats;
  String? _errorMessage;

  DashboardViewModel(this._authService) {
    loadDashboardStats();
  }

  bool get isLoading => _isLoading;
  DashboardStats? get stats => _stats;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboardStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _authService.getToken();
      if (token != null) {
        _stats = await _packageService.getDashboardStats(token);
      }
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des statistiques';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshStats() async {
    await loadDashboardStats();
  }
}
