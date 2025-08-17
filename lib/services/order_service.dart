// lib/services/order_service.dart
import 'dart:convert';
import 'package:mescolis/models/order_model.dart';
import 'package:mescolis/services/api_service.dart.dart';
import 'package:mescolis/services/auth_service.dart';

class OrderService {
  final ApiService _apiService;
  final AuthService _authService;

  OrderService(this._apiService, this._authService);

  Future<Map<String, dynamic>> getProgressOrders() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        return {
          'status': 'error',
          'message': 'User not authenticated',
        };
      }

      final response = await _apiService.post('/order/progressOrder', {
        'deliveryman_id': user.userId,
        'meta_key': '',
      });

      print("----- getProgressOrders ---------- result = jsonDecode(response.body) ----------------------");
      print("status ${response.statusCode}");
      print(jsonDecode(response.body));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          final ordersData = result['data'] as List;
          final orders = ordersData.map((json) => Order.fromJson(json)).toList();
          
          return {
            'status': 'success',
            'orders': orders,
          };
        } else {
          return {
            'status': 'error',
            'message': result['message'] ?? 'Failed to fetch orders',
          };
        }
      } else {
        return {
          'status': 'error',
          'message': 'Erreur , Veuillez réessayer !',
        };
      }
    } catch (e) {
      print("Error in getProgressOrders: $e");
      return {
        'status': 'error',
        'message': 'Erreur , Veuillez réessayer !',
      };
    }
  }

  Future<Map<String, dynamic>> getOrderByBarcode(String barcode) async {
    try {
      final response = await _apiService.post('/order/getOrderByBarCode', {
        'barcode': barcode,
        'console_type': 'to-be-picked_up',
      });

      print("----- getOrderByBarcode ---------- result = jsonDecode(response.body) ----------------------");
      print("getOrderByBarcode ${response.statusCode}");
      print(jsonDecode(response.body));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          final order = Order.fromJson(result['data']);
          return {
            'status': 'success',
            'order': order,
          };
        } else {
          return {
            'status': 'error',
            'message': result['message'] ?? 'Order not found',
          };
        }
      } else {
        return {
          'status': 'error',
          'message': 'Erreur , Veuillez réessayer !',
        };
      }
    } catch (e) {
      print("Error in getOrderByBarcode: $e");
      return {
        'status': 'error',
        'message': 'Erreur , Veuillez réessayer !',
      };
    }
  }

  Future<Map<String, dynamic>> submitScannedOrders(List<int> orderIds) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        return {
          'status': 'error',
          'message': 'User not authenticated',
        };
      }

      final response = await _apiService.post('/order/submitScannedOrders', {
        'agency_id': user.agencyId,
        'deliveryman_id': user.userId,
        'order_ids': orderIds,
      });

      print("----- submitScannedOrders ---------- result = jsonDecode(response.body) ----------------------");
      print("status ${response.statusCode}");
      print(jsonDecode(response.body));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          return {
            'status': 'success',
            'message': result['message'] ?? 'Orders submitted successfully',
          };
        } else {
          return {
            'status': 'error',
            'message': result['message'] ?? 'Failed to submit orders',
          };
        }
      } else {
        return {
          'status': 'error',
          'message': 'Erreur , Veuillez réessayer !',
        };
      }
    } catch (e) {
      print("Error in submitScannedOrders: $e");
      return {
        'status': 'error',
        'message': 'Erreur , Veuillez réessayer !',
      };
    }
  }
}

