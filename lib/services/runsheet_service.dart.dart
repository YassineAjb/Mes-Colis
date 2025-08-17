import 'dart:convert';
import 'package:mescolis/models/user_model.dart';
import 'package:mescolis/services/api_service.dart.dart';
import 'package:mescolis/services/auth_service.dart';

class RunsheetService {
  final ApiService _apiService;
  final AuthService _authService;

  RunsheetService(this._apiService, this._authService);

  Future<Map<String, dynamic>> getDeliveryRunsheets({
    int? carId,
    String? fromDate,
    String? toDate,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null || user.agencyId == null) {
        return {
          'status': 'error',
          'message': 'User not authenticated or missing agency ID',
        };
      }

      // Build filter object
      final Map<String, dynamic> filter = {
        'deliveryman_id': user.userId,
      };

      // Only add filters if they have values
      if (carId != null) filter['car_id'] = carId;
      if (fromDate != null && fromDate.isNotEmpty) filter['from_date'] = fromDate;
      if (toDate != null && toDate.isNotEmpty) filter['to_date'] = toDate;

      final requestBody = {
        'agency_id': user.agencyId,
        'filter': filter,
        'limit': limit,
        'meta_key': '',
        'page': page,
      };

      print("Request body: $requestBody");

      final response = await _apiService.post('/runsheet/getDeliveryRunsheets', requestBody);

      print("API Response Status: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        
        if (result['success'] == true) {
          final runsheetsData = result['data'] as List;
          final runsheets = <Runsheet>[];
          
          for (var json in runsheetsData) {
            try {
              final runsheet = Runsheet.fromJson(json);
              runsheets.add(runsheet);
            } catch (e) {
              print("Error parsing individual runsheet: $e");
              print("Problematic runsheet data: $json");
              // Continue with other runsheets instead of failing completely
            }
          }
          
          return {
            'status': 'success',
            'runsheets': runsheets,
            'pagination': {
              'current_page': page,
              'total_pages': result['pages'] ?? 1,
              'total_count': int.tryParse(result['countAll']?.toString() ?? '0') ?? 0,
            },
          };
        } else {
          return {
            'status': 'error',
            'message': result['message'] ?? 'Failed to fetch runsheets',
          };
        }
      } else {
        return {
          'status': 'error',
          'message': 'Server error (${response.statusCode}). Please try again.',
        };
      }
    } catch (e) {
      print("Exception in getDeliveryRunsheets: $e");
      return {
        'status': 'error',
        'message': 'Network error. Please check your connection and try again.',
      };
    }
  }

  // Method to get all runsheets without filters first, then apply client-side filtering
  Future<Map<String, dynamic>> getAllDeliveryRunsheets({
    int page = 1,
    int limit = 50, // Get more data to have enough for filtering
  }) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null || user.agencyId == null) {
        return {
          'status': 'error',
          'message': 'User not authenticated or missing agency ID',
        };
      }

      final requestBody = {
        'agency_id': user.agencyId,
        'filter': {
          'deliveryman_id': user.userId,
        },
        'limit': limit,
        'meta_key': '',
        'page': page,
      };

      final response = await _apiService.post('/runsheet/getDeliveryRunsheets', requestBody);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        
        if (result['success'] == true) {
          final runsheetsData = result['data'] as List;
          final runsheets = runsheetsData
              .map((json) => Runsheet.fromJson(json))
              .toList();
          
          return {
            'status': 'success',
            'runsheets': runsheets,
            'pagination': {
              'current_page': page,
              'total_pages': result['pages'] ?? 1,
              'total_count': int.tryParse(result['countAll']?.toString() ?? '0') ?? 0,
            },
          };
        } else {
          return {
            'status': 'error',
            'message': result['message'] ?? 'Failed to fetch runsheets',
          };
        }
      } else {
        return {
          'status': 'error',
          'message': 'Server error (${response.statusCode}). Please try again.',
        };
      }
    } catch (e) {
      print("Exception in getAllDeliveryRunsheets: $e");
      return {
        'status': 'error',
        'message': 'Network error. Please check your connection and try again.',
      };
    }
  }
}



// // lib/services/runsheet_service.dart
// import 'dart:convert';
// import 'package:mescolis/models/user_model.dart';
// import 'package:mescolis/services/api_service.dart.dart';
// import 'package:mescolis/services/auth_service.dart';

// class RunsheetService {
//   final ApiService _apiService;
//   final AuthService _authService;

//   RunsheetService(this._apiService, this._authService);

//   Future<Map<String, dynamic>> getDeliveryRunsheets({
//     int? carId,
//     String? fromDate,
//     String? toDate,
//     int page = 1,
//     int limit = 10,
//   }) async {
//     try {
//       final user = await _authService.getCurrentUser();
//       if (user == null || user.agencyId == null) {
//         return {
//           'status': 'error',
//           'message': 'User not authenticated or missing agency ID',
//         };
//       }

//       final Map<String, dynamic> filter = {
//         'deliveryman_id': user.userId,
//       };

//       if (carId != null) filter['car_id'] = carId;
//       if (fromDate != null) filter['from_date'] = fromDate;
//       if (toDate != null) filter['to_date'] = toDate;

//       final response = await _apiService.post('/runsheet/getDeliveryRunsheets', {
//         'agency_id': user.agencyId,
//         'filter': filter,
//         'limit': limit,
//         'meta_key': '',
//         'page': page,
//       });

//       print("----- getDeliveryRunsheets ---------- result = jsonDecode(response.body) ----------------------");
//       print("status ${response.statusCode}");
//       print(jsonDecode(response.body));

//       if (response.statusCode == 200) {
//         final result = jsonDecode(response.body);
//         if (result['success'] == true) {
//           final runsheetsData = result['data'] as List;
//           final runsheets = runsheetsData.map((json) {
//             try {
//               return Runsheet.fromJson(json);
//             } catch (e) {
//               print("Error parsing runsheet: $e");
//               print("Runsheet data: $json");
//               // Return a default runsheet in case of error
//               return Runsheet(
//                 runsheetId: json['runsheet_id'] ?? 0,
//                 runsheetNumber: json['runsheet_number']?.toString() ?? 'N/A',
//                 carId: json['car_id'],
//                 carName: json['car_name']?.toString(),
//                 deliverymanId: json['deliveryman_id'],
//                 deliverymanName: json['deliveryman_name']?.toString(),
//                 date: json['date']?.toString(),
//                 status: json['status']?.toString() ?? 'Inconnu',
//                 ordersCount: json['orders_count'],
//               );
//             }
//           }).toList();
          
//           return {
//             'status': 'success',
//             'runsheets': runsheets,
//             'pagination': result['pagination'] ?? {},
//           };
//         } else {
//           return {
//             'status': 'error',
//             'message': result['message'] ?? 'Failed to fetch runsheets',
//           };
//         }
//       } else {
//         return {
//           'status': 'error',
//           'message': 'Erreur , Veuillez réessayer !',
//         };
//       }
//     } catch (e) {
//       print("Error in getDeliveryRunsheets: $e");
//       return {
//         'status': 'error',
//         'message': 'Erreur , Veuillez réessayer !',
//       };
//     }
//   }
// }
