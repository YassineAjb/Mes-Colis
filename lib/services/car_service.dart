// lib/services/car_service.dart
import 'dart:convert';
import 'package:mescolis/models/car_model.dart';
import 'package:mescolis/services/api_service.dart.dart';
import 'package:mescolis/services/auth_service.dart';

class CarService {
  final ApiService _apiService;
  final AuthService _authService;

  CarService(this._apiService, this._authService);

  Future<Map<String, dynamic>> getCars() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null || user.agencyId == null) {
        return {
          'status': 'error',
          'message': 'User not authenticated or missing agency ID',
        };
      }

      final response = await _apiService.post('/car/find', {
        'filter': [
          {
            'operator': 'and',
            'conditions': [
              {
                'field': 'agency_id',
                'operator': 'eq',
                'value': user.agencyId,
              }
            ]
          }
        ]
      });

        print("----- getCars ---------- result = jsonDecode(response.body) ----------------------");
        print("status ${response.statusCode}");
        print(jsonDecode(response.body));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          final carsData = result['data'] as List;
          final cars = carsData.map((json) => Car.fromJson(json)).toList();
          
          return {
            'status': 'success',
            'cars': cars,
          };
        } else {
          return {
            'status': 'error',
            'message': result['message'] ?? 'Failed to fetch cars',
          };
        }
      } else {
        return {
          'status': 'error',
          'message': 'Erreur , Veuillez réessayer !',
        };
      }
    } catch (e) {
      print("Error in getCars: $e");
      return {
        'status': 'error',
        'message': 'Erreur , Veuillez réessayer !',
      };
    }
  }
}
