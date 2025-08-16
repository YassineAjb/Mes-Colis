// lib/services/package_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mescolis/models/package_model.dart';
import 'package:mescolis/models/dashboard_stats.dart';
import 'package:mescolis/services/auth_service.dart';

class PackageService {
  static const String _baseUrl = 'https://api-staging.mescolis.tn/api';
  final AuthService _authService;

  // Constructor - inject AuthService dependency
  PackageService(this._authService);

  Future<Map<String, dynamic>> getProgressOrder({String metaKey = ""}) async {
    try {
      final token = await _authService.getToken();
      final currentUser = await _authService.getCurrentUser();
      
      if (token == null || currentUser == null) {
        return {
          'status': 'error',
          'message': 'User not authenticated',
        };
      }

      print("----- getProgressOrder ---------- Request ----------------------");
      print("Token: $token");
      print("User ID: ${currentUser.id}");
      print("Meta Key: $metaKey");

      final response = await http.post(
        Uri.parse('$_baseUrl/order/progressOrder'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'deliveryman_id': currentUser.id,
          'meta_key': metaKey,
        }),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print("----- getProgressOrder ---------- result = jsonDecode(response.body) ----------------------");
        print(result);
        return {
          'status': 'success',
          'data': result,
        };
      } else {
        return {
          'status': 'error',
          'message': 'Erreur , Veuillez réessayer !',
        };
      }
    } catch (e) {
      print("getProgressOrder error: $e");
      return {
        'status': 'error',
        'message': 'Erreur , Veuillez réessayer !',
      };
    }
  }




  Future<List<Package>> getPackages(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/packages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => Package.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load packages');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<DashboardStats> getDashboardStats(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/dashboard/stats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DashboardStats.fromJson(data);
      } else {
        throw Exception('Failed to load dashboard stats');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<bool> updatePackageStatus(
    String token,
    String packageId,
    PackageStatus status, {
    FailureReason? failureReason,
    DateTime? postponedDate,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/packages/$packageId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': status.name,
          'failureReason': failureReason?.name,
          'postponedDate': postponedDate?.toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }


}