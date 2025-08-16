// lib/viewmodels/package_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:mescolis/models/package_model.dart';
import 'package:mescolis/services/package_service.dart';
import 'package:mescolis/services/auth_service.dart';

class PackageViewModel extends ChangeNotifier {
  final PackageService _packageService;
  final AuthService _authService;

  List<Package> _packages = [];
  List<Package> _filteredPackages = [];
  PackageStatus? _statusFilter;

  bool _isLoading = false;
  Map<String, dynamic>? _progressOrderData;
  String? _errorMessage;

  // Constructor takes both AuthService and PackageService
  PackageViewModel(this._authService, this._packageService);

  // Getters
  bool get isLoading => _isLoading;
  List<Package> get packages => _packages;
  List<Package> get filteredPackages => _filteredPackages;
  PackageStatus? get statusFilter => _statusFilter;
  Map<String, dynamic>? get progressOrderData => _progressOrderData;
  String? get errorMessage => _errorMessage;

  Future<void> loadPackages() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _authService.getToken();
      if (token != null) {
        // Assuming you have a method to load packages in PackageService
        // You'll need to implement this method in PackageService
        // _packages = await _packageService.getPackages(token);
        // _applyFilter();
      }
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des colis';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProgressOrder({String metaKey = ""}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _packageService.getProgressOrder(metaKey: metaKey);
      
      if (result['status'] == 'success') {
        _progressOrderData = result['data'];
        _errorMessage = null;
      } else {
        _errorMessage = result['message'];
        _progressOrderData = null;
      }
    } catch (e) {
      _errorMessage = 'Erreur , Veuillez réessayer !';
      _progressOrderData = null;
    }

    _isLoading = false;
    notifyListeners();
  }

//---------------------------------


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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearData() {
    _progressOrderData = null;
    _errorMessage = null;
    notifyListeners();
  }
}







//OLD
//// // lib/viewmodels/package_viewmodel.dart
// import 'package:flutter/foundation.dart';
// import 'package:mescolis/services/auth_service.dart';
// import 'package:mescolis/services/package_service.dart';
// import 'package:mescolis/models/package_model.dart';

// class PackageViewModel extends ChangeNotifier {
//   final AuthService _authService;
//   final PackageService _packageService;

//   List<Package> _packages = [];
//   List<Package> _filteredPackages = [];
//   bool _isLoading = false;
//   String? _errorMessage;
//   PackageStatus? _statusFilter;

//   PackageViewModel(this._authService, this._packageService) {
//     loadPackages();
//   }

//   List<Package> get packages => _filteredPackages;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   PackageStatus? get statusFilter => _statusFilter;

//   Future<void> loadPackages() async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       final token = await _authService.getToken();
//       if (token != null) {
//         _packages = await _packageService.getPackages(token);
//         _applyFilter();
//       }
//     } catch (e) {
//       _errorMessage = 'Erreur lors du chargement des colis';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   void filterByStatus(PackageStatus? status) {
//     _statusFilter = status;
//     _applyFilter();
//   }

//   void _applyFilter() {
//     if (_statusFilter == null) {
//       _filteredPackages = List.from(_packages);
//     } else {
//       _filteredPackages = _packages.where((p) => p.status == _statusFilter).toList();
//     }
//     notifyListeners();
//   }

//   Future<bool> updatePackageStatus(
//     String packageId,
//     PackageStatus status, {
//     FailureReason? failureReason,
//     DateTime? postponedDate,
//   }) async {
//     try {
//       final token = await _authService.getToken();
//       if (token == null) return false;

//       final success = await _packageService.updatePackageStatus(
//         token,
//         packageId,
//         status,
//         failureReason: failureReason,
//         postponedDate: postponedDate,
//       );

//       if (success) {
//         // Update local package
//         final index = _packages.indexWhere((p) => p.id == packageId);
//         if (index != -1) {
//           _packages[index] = _packages[index].copyWith(
//             status: status,
//             failureReason: failureReason,
//             postponedDate: postponedDate,
//           );
//           _applyFilter();
//         }
//       }

//       return success;
//     } catch (e) {
//       _errorMessage = 'Erreur lors de la mise à jour du colis';
//       notifyListeners();
//       return false;
//     }
//   }

//   Future<void> refreshPackages() async {
//     await loadPackages();
//   }
// }














//mock data
/*
// lib/viewmodels/package_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:mescolis/services/mock_auth_service.dart'; // Using mock service
import 'package:mescolis/services/mock_package_service.dart'; // Using mock service
import 'package:mescolis/models/package_model.dart';

class PackageViewModel extends ChangeNotifier {
  final MockAuthService _authService; // Changed to MockAuthService
  final MockPackageService _packageService; // Changed to MockPackageService

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
*/