// lib/services/car_service.dart
import 'dart:convert';
import 'package:mescolis/models/car_model.dart';
import 'package:mescolis/services/api_service.dart.dart';
import 'package:mescolis/services/auth_service.dart';

class CarService {
  final ApiService _apiService;
  final AuthService _authService;

  CarService(this._apiService, this._authService);

  // Future<Map<String, dynamic>> getCars() async {
  //   print("Debug321");
  //   try {
  //     final user = await _authService.getCurrentUser();
  //     if (user == null || user.agencyId == null) {
  //       return {
  //         'status': 'error',
  //         'message': 'User not authenticated or missing agency ID',
  //       };
  //     }

  //     final response = await _apiService.post('/car/find', {
  //       'filter': [
  //         {
  //           'operator': 'and',
  //           'conditions': [
  //             {
  //               'field': 'agency_id',
  //               'operator': 'eq',
  //               'value': user.agencyId,
  //             }
  //           ]
  //         }
  //       ]
  //     });

  //       print("----- getCars ---------- result = jsonDecode(response.body) ----------------------");
  //       print("status ${response.statusCode}");
  //       print(jsonDecode(response.body));

  //     if (response.statusCode == 200) {
  //       final result = jsonDecode(response.body);
  //       print("Debug321 : ${jsonDecode(response.body)}");
  //       if (result['success'] == true) {
  //         final carsData = result['data'] as List;
  //         final cars = carsData.map((json) => Car.fromJson(json)).toList();
  //         print('viewModel Cars fetched: ${cars.length}'); // Debug line
  //         return {
  //           'status': 'success',
  //           'cars': cars,
  //         };
  //       } else {
  //         return {
  //           'status': 'error',
  //           'message': result['message'] ?? 'Failed to fetch cars',
  //         };
  //       }
  //     } else {
  //       return {
  //         'status': 'error',
  //         'message': 'Erreur , Veuillez réessayer !',
  //       };
  //     }
  //   } catch (e) {
  //     print("Error in getCars: $e");
  //     return {
  //       'status': 'error',
  //       'message': 'Erreur , Veuillez réessayer !',
  //     };
  //   }
  // }
  Future<Map<String, dynamic>> getCars() async {
  print("Debug321");
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
      print("Debug321 : ${jsonDecode(response.body)}");
      
      // FIXED: The API response doesn't have a 'success' field
      // Instead, check if 'data' exists and is a List
      if (result['data'] != null && result['data'] is List) {
        final carsData = result['data'] as List;
        final cars = carsData.map((json) => Car.fromJson(json)).toList();
        print('viewModel Cars fetched: ${cars.length}'); // Debug line
        return {
          'status': 'success',
          'cars': cars,
        };
      } else {
        return {
          'status': 'error',
          'message': 'No car data found in response',
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
