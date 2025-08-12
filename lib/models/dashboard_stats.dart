// lib/models/dashboard_stats.dart
class DashboardStats {
  final int totalPackages;
  final int deliveredPackages;
  final int pendingPackages;
  final int failedPackages;
  final double deliveryRate;

  DashboardStats({
    required this.totalPackages,
    required this.deliveredPackages,
    required this.pendingPackages,
    required this.failedPackages,
    required this.deliveryRate,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalPackages: json['totalPackages'] ?? 0,
      deliveredPackages: json['deliveredPackages'] ?? 0,
      pendingPackages: json['pendingPackages'] ?? 0,
      failedPackages: json['failedPackages'] ?? 0,
      deliveryRate: (json['deliveryRate'] ?? 0.0).toDouble(),
    );
  }
}
