// lib/viewmodels/runsheet_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:mescolis/models/car_model.dart';
import 'package:mescolis/models/runsheet_model.dart';
import 'package:mescolis/services/car_service.dart';
import 'package:mescolis/services/runsheet_service.dart.dart';


class RunsheetViewModel extends ChangeNotifier {
  final RunsheetService _runsheetService;
  final CarService _carService;

  RunsheetViewModel(this._runsheetService, this._carService);

  bool _isLoading = false;
  bool _isLoadingCars = false;
  List<Runsheet> _allRunsheets = []; // Store all fetched runsheets
  List<Runsheet> _filteredRunsheets = []; // Store filtered results
  List<Car> _cars = [];
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMoreData = true;

  // Filters
  int? _selectedCarId;
  String? _fromDate;
  String? _toDate;
  String? _searchQuery;

  bool get isLoading => _isLoading;
  bool get isLoadingCars => _isLoadingCars;
  List<Runsheet> get runsheets => _filteredRunsheets.isNotEmpty ? _filteredRunsheets : _allRunsheets;
  List<Car> get cars => _cars;
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;
  int? get selectedCarId => _selectedCarId;
  String? get fromDate => _fromDate;
  String? get toDate => _toDate;
  String? get searchQuery => _searchQuery;

  Future<void> fetchCars() async {
    _isLoadingCars = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _carService.getCars();
      
      if (result['status'] == 'success') {
        _cars = result['cars'] as List<Car>;
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'Error loading cars. Please try again.';
      print("Error fetching cars: $e");
    }

    _isLoadingCars = false;
    notifyListeners();
  }

  Future<void> fetchRunsheets({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _allRunsheets.clear();
      _filteredRunsheets.clear();
      _hasMoreData = true;
    }

    if (!_hasMoreData || _isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _runsheetService.getDeliveryRunsheets(
        carId: _selectedCarId,
        fromDate: _fromDate,
        toDate: _toDate,
        page: _currentPage,
        limit: 20,
      );
      
      if (result['status'] == 'success') {
        final newRunsheets = result['runsheets'] as List<Runsheet>;
        
        if (refresh) {
          _allRunsheets = newRunsheets;
        } else {
          _allRunsheets.addAll(newRunsheets);
        }
        
        // Apply client-side filtering if needed
        _applyFilters();
        
        final pagination = result['pagination'] as Map<String, dynamic>?;
        if (pagination != null) {
          _currentPage = (pagination['current_page'] ?? 1) + 1;
          final totalPages = pagination['total_pages'] ?? 1;
          _hasMoreData = _currentPage <= totalPages && newRunsheets.isNotEmpty;
        } else {
          _currentPage++;
          _hasMoreData = newRunsheets.length >= 20;
        }
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'Error loading runsheets. Please try again.';
      print("Error fetching runsheets: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  void _applyFilters() {
    if (_searchQuery == null || _searchQuery!.isEmpty) {
      _filteredRunsheets = _allRunsheets;
      return;
    }

    final query = _searchQuery!.toLowerCase();
    _filteredRunsheets = _allRunsheets.where((runsheet) {
      return (runsheet.barcode?.toLowerCase().contains(query) ?? false) ||
             (runsheet.runsheetNumber?.toLowerCase().contains(query) ?? false) ||
             (runsheet.carName?.toLowerCase().contains(query) ?? false) ||
             (runsheet.deliverymanName?.toLowerCase().contains(query) ?? false) ||
             (runsheet.registrationNumber?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  void setFilters({
    int? carId, 
    String? fromDate, 
    String? toDate, 
    String? searchQuery,
  }) {
    bool shouldRefetch = false;
    
    // Check if API-level filters changed (require refetch)
    if (_selectedCarId != carId || _fromDate != fromDate || _toDate != toDate) {
      shouldRefetch = true;
    }
    
    _selectedCarId = carId;
    _fromDate = fromDate;
    _toDate = toDate;
    _searchQuery = searchQuery;

    if (shouldRefetch) {
      fetchRunsheets(refresh: true);
    } else {
      // Just apply client-side filtering
      _applyFilters();
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _selectedCarId = null;
    _fromDate = null;
    _toDate = null;
    _searchQuery = null;
    _filteredRunsheets.clear();
    fetchRunsheets(refresh: true);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
