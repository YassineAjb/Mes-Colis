// lib/services/order_status_service.dart
import 'dart:convert';

import 'package:mescolis/services/api_service.dart.dart';

class OrderStatusService {
  final ApiService _apiService;

  OrderStatusService(this._apiService);

  // Get all available order statuses
  Future<Map<String, dynamic>> getOrderStatuses() async {
    try {
      final response = await _apiService.post('/order_status/find', {
        'filter': [
          {
            'operator': 'and',
            'conditions': [
              {
                'field': 'type',
                'operator': 'eq',
                'value': '1'
              }
            ]
          }
        ]
      });

      print("getOrderStatuses - Status: ${response.statusCode}");
      print("getOrderStatuses - Response: ${response.body}");

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['data'] != null) {
          return {
            'status': 'success',
            'statuses': result['data'] as List,
          };
        } else {
          return {
            'status': 'error',
            'message': 'No status data found',
          };
        }
      } else {
        return {
          'status': 'error',
          'message': 'Failed to fetch order statuses',
        };
      }
    } catch (e) {
      print("Error in getOrderStatuses: $e");
      return {
        'status': 'error',
        'message': 'Network error occurred',
      };
    }
  }

  // Update order qualification/status
  Future<Map<String, dynamic>> updateOrderQualification({
    required int orderEventId,
    required int statusId,
  }) async {
    try {
      final response = await _apiService.post('/order_events/update_qualification', {
        'order_event_id': orderEventId,
        'status_id': statusId,
      });

      print("updateOrderQualification - Status: ${response.statusCode}");
      print("updateOrderQualification - Response: ${response.body}");

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          return {
            'status': 'success',
            'message': result['message'] ?? 'Order qualification updated successfully',
            'data': result['data'],
          };
        } else {
          return {
            'status': 'error',
            'message': result['message'] ?? 'Failed to update order qualification',
          };
        }
      } else {
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("Error in updateOrderQualification: $e");
      return {
        'status': 'error',
        'message': 'Network error occurred',
      };
    }
  }
}