// lib/services/mock_package_service.dart
import 'dart:convert';
import 'package:mescolis/models/package_model.dart';
import 'package:mescolis/models/dashboard_stats.dart';

class MockPackageService {
  // Mock packages data - stored as static to persist changes during session
  static List<Map<String, dynamic>> _mockPackagesData = [
    {
      "id": "PKG_001",
      "deliveryAddress": "123 Avenue Habib Bourguiba, Tunis 1000",
      "status": "pending",
      "description": "Colis fragile - Électronique",
      "clientContact": "+216 98 123 456",
      "scheduledDate": "2024-12-15T14:30:00Z",
      "failureReason": null,
      "postponedDate": null,
      "latitude": 36.8008,
      "longitude": 10.1817
    },
    {
      "id": "PKG_002",
      "deliveryAddress": "456 Rue de la République, Sfax 3000",
      "status": "inTransit",
      "description": "Vêtements",
      "clientContact": "+216 97 987 654",
      "scheduledDate": "2024-12-15T10:00:00Z",
      "failureReason": null,
      "postponedDate": null,
      "latitude": 34.7406,
      "longitude": 10.7603
    },
    {
      "id": "PKG_003",
      "deliveryAddress": "789 Boulevard de l'Environnement, Sousse 4000",
      "status": "delivered",
      "description": "Livres académiques",
      "clientContact": "+216 96 555 777",
      "scheduledDate": "2024-12-14T16:00:00Z",
      "failureReason": null,
      "postponedDate": null,
      "latitude": 35.8256,
      "longitude": 10.6364
    },
    {
      "id": "PKG_004",
      "deliveryAddress": "321 Rue Ibn Khaldoun, Monastir 5000",
      "status": "failed",
      "description": "Produits cosmétiques",
      "clientContact": "+216 95 444 888",
      "scheduledDate": "2024-12-14T11:30:00Z",
      "failureReason": "unreachable",
      "postponedDate": null,
      "latitude": 35.7772,
      "longitude": 10.8265
    },
    {
      "id": "PKG_005",
      "deliveryAddress": "567 Avenue Mohamed V, Nabeul 8000",
      "status": "pending",
      "description": "Médicaments",
      "clientContact": "+216 94 333 999",
      "scheduledDate": "2024-12-15T09:00:00Z",
      "failureReason": null,
      "postponedDate": null,
      "latitude": 36.4500,
      "longitude": 10.7333
    },
    {
      "id": "PKG_006",
      "deliveryAddress": "890 Rue de la Liberté, Gabès 6000",
      "status": "failed",
      "description": "Équipement sportif",
      "clientContact": "+216 93 222 111",
      "scheduledDate": "2024-12-13T15:45:00Z",
      "failureReason": "postponedWithDate",
      "postponedDate": "2024-12-16T15:45:00Z",
      "latitude": 33.8815,
      "longitude": 10.0982
    },
    {
      "id": "PKG_007",
      "deliveryAddress": "234 Rue El Jazira, Bizerte 7000",
      "status": "inTransit",
      "description": "Pièces automobiles",
      "clientContact": "+216 92 111 222",
      "scheduledDate": "2024-12-15T13:15:00Z",
      "failureReason": null,
      "postponedDate": null,
      "latitude": 37.2744,
      "longitude": 9.8739
    },
    {
      "id": "PKG_008",
      "deliveryAddress": "678 Avenue de la Paix, Kairouan 3100",
      "status": "pending",
      "description": "Appareils ménagers",
      "clientContact": "+216 91 000 333",
      "scheduledDate": "2024-12-16T10:30:00Z",
      "failureReason": null,
      "postponedDate": null,
      "latitude": 35.6781,
      "longitude": 10.0963
    },
    {
      "id": "PKG_009",
      "deliveryAddress": "112 Rue des Martyrs, Mahdia 5100",
      "status": "delivered",
      "description": "Bijoux et accessoires",
      "clientContact": "+216 90 999 444",
      "scheduledDate": "2024-12-13T14:00:00Z",
      "failureReason": null,
      "postponedDate": null,
      "latitude": 35.5047,
      "longitude": 11.0622
    },
    {
      "id": "PKG_010",
      "deliveryAddress": "445 Boulevard Hedi Chaker, Gafsa 2100",
      "status": "failed",
      "description": "Outillage professionnel",
      "clientContact": "+216 89 888 555",
      "scheduledDate": "2024-12-14T12:00:00Z",
      "failureReason": "threeAttempts",
      "postponedDate": null,
      "latitude": 34.4250,
      "longitude": 8.7842
    },
    {
      "id": "PKG_011",
      "deliveryAddress": "778 Avenue Farhat Hached, Béja 9000",
      "status": "pending",
      "description": "Produits alimentaires",
      "clientContact": "+216 88 777 666",
      "scheduledDate": "2024-12-15T17:00:00Z",
      "failureReason": null,
      "postponedDate": null,
      "latitude": 36.7256,
      "longitude": 9.1817
    },
    {
      "id": "PKG_012",
      "deliveryAddress": "334 Rue de Carthage, Ariana 2080",
      "status": "inTransit",
      "description": "Matériel informatique",
      "clientContact": "+216 87 666 777",
      "scheduledDate": "2024-12-15T11:45:00Z",
      "failureReason": null,
      "postponedDate": null,
      "latitude": 36.8667,
      "longitude": 10.1833
    }
  ];

  Future<List<Package>> getPackages(String token) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (token.isEmpty) {
      throw Exception('Unauthorized');
    }

    return _mockPackagesData.map((json) => Package.fromJson(json)).toList();
  }

  Future<DashboardStats> getDashboardStats(String token) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    if (token.isEmpty) {
      throw Exception('Unauthorized');
    }

    // Calculate stats from current packages data
    final packages = _mockPackagesData;
    final totalPackages = packages.length;
    final deliveredPackages = packages.where((p) => p['status'] == 'delivered').length;
    final pendingPackages = packages.where((p) => p['status'] == 'pending').length;
    final inTransitPackages = packages.where((p) => p['status'] == 'inTransit').length;
    final failedPackages = packages.where((p) => p['status'] == 'failed').length;
    
    final deliveryRate = totalPackages > 0 
        ? (deliveredPackages / totalPackages) * 100 
        : 0.0;

    final statsData = {
      "totalPackages": totalPackages,
      "deliveredPackages": deliveredPackages,
      "pendingPackages": pendingPackages + inTransitPackages,
      "failedPackages": failedPackages,
      "deliveryRate": deliveryRate
    };

    return DashboardStats.fromJson(statsData);
  }

  Future<bool> updatePackageStatus(
    String token,
    String packageId,
    PackageStatus status, {
    FailureReason? failureReason,
    DateTime? postponedDate,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (token.isEmpty) {
      throw Exception('Unauthorized');
    }

    // Find and update the package
    final packageIndex = _mockPackagesData.indexWhere((p) => p['id'] == packageId);
    
    if (packageIndex == -1) {
      throw Exception('Package not found');
    }

    // Update the package data
    _mockPackagesData[packageIndex] = {
      ..._mockPackagesData[packageIndex],
      'status': status.name,
      'failureReason': failureReason?.name,
      'postponedDate': postponedDate?.toIso8601String(),
    };

    return true;
  }

  // Method to reset data (useful for testing)
  static void resetMockData() {
    _mockPackagesData = [
      {
        "id": "PKG_001",
        "deliveryAddress": "123 Avenue Habib Bourguiba, Tunis 1000",
        "status": "pending",
        "description": "Colis fragile - Électronique",
        "clientContact": "+216 98 123 456",
        "scheduledDate": "2024-12-15T14:30:00Z",
        "failureReason": null,
        "postponedDate": null,
        "latitude": 36.8008,
        "longitude": 10.1817
      },
      // ... include all other packages here if needed
    ];
  }
}