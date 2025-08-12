// lib/viewmodels/package_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:mescolis/services/auth_service.dart';
import 'package:mescolis/services/package_service.dart';
import 'package:mescolis/models/package_model.dart';

class PackageViewModel extends ChangeNotifier {
  final AuthService _authService;
  final PackageService _packageService;

  List<Package> _packages = [];
  List<Package> _filteredPackages = [];
  bool _isLoading = false;
  String? _errorMessage;
  PackageStatus? _statusFilter;

  PackageViewModel(this._authService, this._packageService) {
    loadPackages();
  }

  List<Package> get packages => _filteredPackages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PackageStatus? get statusFilter => _statusFilter;

  Future<void> loadPackages() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _authService.getToken();
      if (token != null) {
        _packages = await _packageService.getPackages(token);
        _applyFilter();
      }
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des colis';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterByStatus(PackageStatus? status) {
    _statusFilter = status;
    _applyFilter();
  }

  void _applyFilter() {
    if (_statusFilter == null) {
      _filteredPackages = List.from(_packages);
    } else {
      _filteredPackages = _packages.where((p) => p.status == _statusFilter).toList();
    }
    notifyListeners();
  }

  Future<bool> updatePackageStatus(
    String packageId,
    PackageStatus status, {
    FailureReason? failureReason,
    DateTime? postponedDate,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final success = await _packageService.updatePackageStatus(
        token,
        packageId,
        status,
        failureReason: failureReason,
        postponedDate: postponedDate,
      );

      if (success) {
        // Update local package
        final index = _packages.indexWhere((p) => p.id == packageId);
        if (index != -1) {
          _packages[index] = _packages[index].copyWith(
            status: status,
            failureReason: failureReason,
            postponedDate: postponedDate,
          );
          _applyFilter();
        }
      }

      return success;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour du colis';
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshPackages() async {
    await loadPackages();
  }
}
