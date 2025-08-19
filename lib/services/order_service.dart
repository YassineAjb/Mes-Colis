// lib/services/order_service.dart
import 'dart:convert';
import 'package:mescolis/models/order_model.dart';
import 'package:mescolis/services/api_service.dart.dart';
import 'package:mescolis/services/auth_service.dart';
import 'dart:math' as math;

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
    
    print('Response status: ${response.statusCode}');
    print('Response length: ${response.body.length}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      try {
        final result = jsonDecode(response.body);
        print('JSON decode successful');
        
        if (result['success'] == true) {
          // Check if the response structure matches what you expect
          if (result['order'] != null) {
            return {'status': 'success', 'order': result['order']};
          } else if (result['data'] != null) {
            // In case the API returns 'data' instead of 'order'
            return {'status': 'success', 'order': result['data']};
          } else {
            return {'status': 'error', 'message': 'Order data not found in response'};
          }
        } else {
          return {
            'status': 'error', 
            'message': result['message'] ?? 'Order not found'
          };
        }
      } catch (jsonError) {
        print('JSON decode error: $jsonError');
        print('Response body (first 500 chars): ${response.body.substring(0, math.min(500, response.body.length))}');
        return {'status': 'error', 'message': 'Invalid response format'};
      }
    } else {
      print('HTTP Error: ${response.statusCode}');
      return {
        'status': 'error',
        'message': 'Server error: ${response.statusCode}',
      };
    }
  } catch (e) {
    print('API Error: $e');
    return {
      'status': 'error',
      'message': 'Network error: ${e.toString()}',
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

