// lib/services/package_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mescolis/models/package_model.dart';
import 'package:mescolis/models/dashboard_stats.dart';

class PackageService {
  static const String _baseUrl = 'https://api.mescolis.com'; // Replace with actual API URL

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
