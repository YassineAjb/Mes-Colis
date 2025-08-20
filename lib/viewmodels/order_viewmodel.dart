// lib/viewmodels/order_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:mescolis/models/order_model.dart';
import 'package:mescolis/models/user_model.dart';
import 'package:mescolis/services/order_service.dart';
import 'package:mescolis/services/car_service.dart';
import 'package:mescolis/services/runsheet_service.dart.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderService _orderService;

  OrderViewModel(this._orderService);

  bool _isLoading = false;
  List<Order> _orders = [];
  List<Order> _scannedOrders = [];
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  List<Order> get orders => _orders;
  List<Order> get scannedOrders => _scannedOrders;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> fetchProgressOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _orderService.getProgressOrders();
      
      if (result['status'] == 'success') {
        _orders = result['orders'] as List<Order>;
        // print("Debug569 : $_orders. ");
        print("Debug569 : ${_orders.map((order) => order.status).toList()}");

      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'Erreur , Veuillez réessayer !';
    }

    _isLoading = false;
    notifyListeners();
  }

Future<bool> scanOrder(String barcode) async {
  _errorMessage = null;
  _successMessage = null;
  notifyListeners();

  try {
    final result = await _orderService.getOrderByBarcode(barcode);

if (result['status'] == 'success' && result['order'] != null) {
  final orderData = result['order'] as Map<String, dynamic>;
  final order = Order.fromJson(orderData);

  if (!_scannedOrders.any((o) => o.orderId == order.orderId)) {
    _scannedOrders.add(order);
    _successMessage = 'Commande ajoutée avec succès';
    notifyListeners();
    return true;
  } else {
    _errorMessage = 'Cette commande a déjà été scannée';
    notifyListeners();
    return false;
  }
} else {
  _errorMessage = result['message'] ?? 'Commande introuvable';
  notifyListeners();
  return false;
}

  } catch (e) {
    print('Error in scanOrder: $e'); // Keep this for debugging
    _errorMessage = 'Erreur de traitement des données';
    notifyListeners();
    return false;
  }
}
  void removeScannedOrder(int orderId) {
    _scannedOrders.removeWhere((order) => order.orderId == orderId);
    notifyListeners();
  }

  void clearScannedOrders() {
    _scannedOrders.clear();
    notifyListeners();
  }

  Future<bool> submitScannedOrders() async {
    if (_scannedOrders.isEmpty) {
      _errorMessage = 'Aucune commande à soumettre';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final orderIds = _scannedOrders.map((order) => order.orderId).toList();
      final result = await _orderService.submitScannedOrders(orderIds);
      
      if (result['status'] == 'success') {
        _successMessage = result['message'];
        _scannedOrders.clear();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur , Veuillez réessayer !';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}

