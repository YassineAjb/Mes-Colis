// lib/viewmodels/order_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:mescolis/models/order_model.dart';
import 'package:mescolis/models/orderstatus_model.dart';
import 'package:mescolis/services/order_service.dart';
import 'package:mescolis/services/status_service.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderService _orderService;
  final OrderStatusService _orderStatusService;

  OrderViewModel(this._orderService, this._orderStatusService);

  bool _isLoading = false;
  bool _isLoadingStatuses = false;
  bool _isUpdatingStatus = false;
  List<Order> _orders = [];
  List<Order> _scannedOrders = [];
  List<OrderStatus> _orderStatuses = [];
  String? _errorMessage;
  String? _successMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingStatuses => _isLoadingStatuses;
  bool get isUpdatingStatus => _isUpdatingStatus;
  List<Order> get orders => _orders;
  List<Order> get scannedOrders => _scannedOrders;
  List<OrderStatus> get orderStatuses => _orderStatuses;
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
        print("Debug569 : ${_orders.map((order) => order.status).toList()}");
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      print("Error in fetchProgressOrders: $e");
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
      print('Error in scanOrder: $e');
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
      print("Error in submitScannedOrders: $e");
      _errorMessage = 'Erreur , Veuillez réessayer !';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fetch available order statuses
  Future<void> fetchOrderStatuses() async {
    _isLoadingStatuses = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _orderStatusService.getOrderStatuses();
      
      if (result['status'] == 'success') {
        final statusesData = result['statuses'] as List;
        _orderStatuses = statusesData.map((json) => OrderStatus.fromJson(json)).toList();
        
        // Sort statuses to prioritize common ones
        _orderStatuses.sort((a, b) {
          // Priority order: delivered, cancelled-by-sender, unreachable, etc.
          final priorityOrder = {
            'delivered': 1,
            'cancelled-by-sender': 2,
            'unreachable': 3,
            '3-attempts-done': 4,
            'rescheduled-dated': 5,
            'rescheduled-tomorrow': 6,
            'no-answer': 7,
            'wrong-address': 8,
          };
          
          final aPriority = priorityOrder[a.status.toLowerCase()] ?? 999;
          final bPriority = priorityOrder[b.status.toLowerCase()] ?? 999;
          
          if (aPriority != bPriority) {
            return aPriority.compareTo(bPriority);
          }
          
          return a.displayName.compareTo(b.displayName);
        });
        
        print("Fetched ${_orderStatuses.length} order statuses");
        print("Status IDs: ${_orderStatuses.map((s) => '${s.status}: ${s.orderStatusId}').join(', ')}");
        
        // Find and log the delivered status ID for debugging
        final deliveredStatus = _orderStatuses.firstWhere(
          (status) => status.status.toLowerCase() == 'delivered',
          orElse: () => OrderStatus(
            orderStatusId: 0,
            status: 'not-found',
            active: 'N',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            type: 1,
          ),
        );
        
        print("Delivered status ID: ${deliveredStatus.orderStatusId}");
        
      } else {
        _errorMessage = result['message'];
        print("Error fetching order statuses: ${result['message']}");
      }
    } catch (e) {
      print("Error fetching order statuses: $e");
      _errorMessage = 'Erreur lors du chargement des statuts';
    }

    _isLoadingStatuses = false;
    notifyListeners();
  }

  // Update order qualification/status
  Future<bool> updateOrderStatus({
    required int orderEventId,
    required int statusId,
  }) async {
    _isUpdatingStatus = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      print("Updating order event $orderEventId to status $statusId");
      
      // Find the status being applied for logging
      final selectedStatus = _orderStatuses.firstWhere(
        (status) => status.orderStatusId == statusId,
        orElse: () => OrderStatus(
          orderStatusId: statusId,
          status: 'unknown',
          active: 'Y',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          type: 1,
        ),
      );
      
      print("Applying status: ${selectedStatus.status} (${selectedStatus.displayName})");
      
      final result = await _orderStatusService.updateOrderQualification(
        orderEventId: orderEventId,
        statusId: statusId,
      );
      
      if (result['status'] == 'success') {
        _successMessage = result['message'] ?? 'Statut mis à jour avec succès';
        print("Status update successful: ${_successMessage}");
        
        _isUpdatingStatus = false;
        notifyListeners();
        
        // Refresh orders to get updated status
        await fetchProgressOrders();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Erreur lors de la mise à jour du statut';
        print("Status update failed: ${_errorMessage}");
        _isUpdatingStatus = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("Error updating order status: $e");
      _errorMessage = 'Erreur lors de la mise à jour du statut: ${e.toString()}';
      _isUpdatingStatus = false;
      notifyListeners();
      return false;
    }
  }

  // Quick method to mark order as delivered (status_id: 8)
  Future<bool> markOrderAsDelivered(int orderEventId) async {
    const int deliveredStatusId = 8;
    return await updateOrderStatus(
      orderEventId: orderEventId,
      statusId: deliveredStatusId,
    );
  }

  // Get status display name by status string
  String getStatusDisplayName(String statusString) {
    final orderStatus = _orderStatuses.firstWhere(
      (status) => status.status.toLowerCase() == statusString.toLowerCase(),
      orElse: () => OrderStatus(
        orderStatusId: 0,
        status: statusString,
        active: 'Y',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        type: 1,
      ),
    );
    return orderStatus.displayName.isNotEmpty ? orderStatus.displayName : _getDefaultDisplayName(statusString);
  }

  // Default display names if not found in fetched statuses
  String _getDefaultDisplayName(String statusString) {
    switch (statusString.toLowerCase()) {
      case 'delivered':
        return 'Livrée';
      case 'closed':
        return 'Fermée';
      case 'to-be-checked-with-sender':
        return 'À vérifier avec expéditeur';
      case '3-attempts-done':
        return '3 tentatives effectuées';
      case 'unreachable':
        return 'Injoignable';
      case 'cancelled-by-sender':
        return 'Annulé par expéditeur';
      case 'rescheduled-dated':
        return 'Reprogrammé (daté)';
      case 'rescheduled-tomorrow':
        return 'Reprogrammé demain';
      case 'no-answer':
        return 'Pas de réponse';
      case 'wrong-address':
        return 'Mauvaise adresse';
      case 'invalid-number':
        return 'Numéro invalide';
      case 'duplicate-package':
        return 'Colis dupliqué';
      case 'wrong-amount':
        return 'Montant incorrect';
      case 'order-not-conformed':
        return 'Commande non conforme';
      case 'client-not-serious':
        return 'Client non sérieux';
      case 'number-in-blacklist':
        return 'Numéro en liste noire';
      case 'cancled-by-sender-client':
        return 'Annulé par expéditeur/client';
      default:
        return statusString;
    }
  }

  // Get status by ID
  OrderStatus? getStatusById(int statusId) {
    try {
      return _orderStatuses.firstWhere((status) => status.orderStatusId == statusId);
    } catch (e) {
      return null;
    }
  }

  // Get delivered status (should have ID 8 according to your requirement)
  OrderStatus? getDeliveredStatus() {
    try {
      return _orderStatuses.firstWhere(
        (status) => status.status.toLowerCase() == 'delivered',
      );
    } catch (e) {
      // Return a default delivered status if not found
      return OrderStatus(
        orderStatusId: 8, // As per your requirement
        status: 'delivered',
        active: 'Y',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        type: 1,
      );
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}


// // lib/viewmodels/order_viewmodel.dart
// import 'package:flutter/foundation.dart';
// import 'package:mescolis/models/order_model.dart';
// import 'package:mescolis/models/orderstatus_model.dart';
// import 'package:mescolis/services/order_service.dart';
// import 'package:mescolis/services/status_service.dart';

// class OrderViewModel extends ChangeNotifier {
//   final OrderService _orderService;
//   final OrderStatusService _orderStatusService;

//   OrderViewModel(this._orderService, this._orderStatusService);

//   bool _isLoading = false;
//   bool _isLoadingStatuses = false;
//   bool _isUpdatingStatus = false;
//   List<Order> _orders = [];
//   List<Order> _scannedOrders = [];
//   List<OrderStatus> _orderStatuses = [];
//   String? _errorMessage;
//   String? _successMessage;

//   // Getters
//   bool get isLoading => _isLoading;
//   bool get isLoadingStatuses => _isLoadingStatuses;
//   bool get isUpdatingStatus => _isUpdatingStatus;
//   List<Order> get orders => _orders;
//   List<Order> get scannedOrders => _scannedOrders;
//   List<OrderStatus> get orderStatuses => _orderStatuses;
//   String? get errorMessage => _errorMessage;
//   String? get successMessage => _successMessage;

//   // Existing methods remain the same...
//   Future<void> fetchProgressOrders() async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       final result = await _orderService.getProgressOrders();
      
//       if (result['status'] == 'success') {
//         _orders = result['orders'] as List<Order>;
//         print("Debug569 : ${_orders.map((order) => order.status).toList()}");
//       } else {
//         _errorMessage = result['message'];
//       }
//     } catch (e) {
//       _errorMessage = 'Erreur , Veuillez réessayer !';
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   Future<bool> scanOrder(String barcode) async {
//     _errorMessage = null;
//     _successMessage = null;
//     notifyListeners();

//     try {
//       final result = await _orderService.getOrderByBarcode(barcode);

//       if (result['status'] == 'success' && result['order'] != null) {
//         final orderData = result['order'] as Map<String, dynamic>;
//         final order = Order.fromJson(orderData);

//         if (!_scannedOrders.any((o) => o.orderId == order.orderId)) {
//           _scannedOrders.add(order);
//           _successMessage = 'Commande ajoutée avec succès';
//           notifyListeners();
//           return true;
//         } else {
//           _errorMessage = 'Cette commande a déjà été scannée';
//           notifyListeners();
//           return false;
//         }
//       } else {
//         _errorMessage = result['message'] ?? 'Commande introuvable';
//         notifyListeners();
//         return false;
//       }
//     } catch (e) {
//       print('Error in scanOrder: $e');
//       _errorMessage = 'Erreur de traitement des données';
//       notifyListeners();
//       return false;
//     }
//   }

//   void removeScannedOrder(int orderId) {
//     _scannedOrders.removeWhere((order) => order.orderId == orderId);
//     notifyListeners();
//   }

//   void clearScannedOrders() {
//     _scannedOrders.clear();
//     notifyListeners();
//   }

//   Future<bool> submitScannedOrders() async {
//     if (_scannedOrders.isEmpty) {
//       _errorMessage = 'Aucune commande à soumettre';
//       notifyListeners();
//       return false;
//     }

//     _isLoading = true;
//     _errorMessage = null;
//     _successMessage = null;
//     notifyListeners();

//     try {
//       final orderIds = _scannedOrders.map((order) => order.orderId).toList();
//       final result = await _orderService.submitScannedOrders(orderIds);
      
//       if (result['status'] == 'success') {
//         _successMessage = result['message'];
//         _scannedOrders.clear();
//         _isLoading = false;
//         notifyListeners();
//         return true;
//       } else {
//         _errorMessage = result['message'];
//         _isLoading = false;
//         notifyListeners();
//         return false;
//       }
//     } catch (e) {
//       _errorMessage = 'Erreur , Veuillez réessayer !';
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   // NEW: Fetch available order statuses
//   Future<void> fetchOrderStatuses() async {
//     _isLoadingStatuses = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       final result = await _orderStatusService.getOrderStatuses();
      
//       if (result['status'] == 'success') {
//         final statusesData = result['statuses'] as List;
//         _orderStatuses = statusesData.map((json) => OrderStatus.fromJson(json)).toList();
//         print("Fetched ${_orderStatuses.length} order statuses");
//       } else {
//         _errorMessage = result['message'];
//       }
//     } catch (e) {
//       print("Error fetching order statuses: $e");
//       _errorMessage = 'Erreur lors du chargement des statuts';
//     }

//     _isLoadingStatuses = false;
//     notifyListeners();
//   }

//   // NEW: Update order qualification
//   Future<bool> updateOrderStatus({
//     required int orderEventId,
//     required int statusId,
//   }) async {
//     _isUpdatingStatus = true;
//     _errorMessage = null;
//     _successMessage = null;
//     notifyListeners();

//     try {
//       final result = await _orderStatusService.updateOrderQualification(
//         orderEventId: orderEventId,
//         statusId: statusId,
//       );
//       print("debug999 $orderEventId $statusId ");
//       if (result['status'] == 'success') {
//         _successMessage = result['message'];
//         _isUpdatingStatus = false;
//         notifyListeners();
        
//         // Refresh orders to get updated status
//         await fetchProgressOrders();
//         return true;
//       } else {
//         _errorMessage = result['message'];
//         _isUpdatingStatus = false;
//         notifyListeners();
//         return false;
//       }
//     } catch (e) {
//       print("Error updating order status: $e");
//       _errorMessage = 'Erreur lors de la mise à jour du statut';
//       _isUpdatingStatus = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   // NEW: Get status display name by status string
//   String getStatusDisplayName(String statusString) {
//     final orderStatus = _orderStatuses.firstWhere(
//       (status) => status.status == statusString,
//       orElse: () => OrderStatus(
//         orderStatusId: 0,
//         status: statusString,
//         active: 'Y',
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//         type: 1,
//       ),
//     );
//     return orderStatus.displayName;
//   }

//   void clearMessages() {
//     _errorMessage = null;
//     _successMessage = null;
//     notifyListeners();
//   }
// }