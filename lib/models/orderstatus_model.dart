// lib/models/order_status_model.dart
class OrderStatus {
  final int orderStatusId;
  final String status;
  final String active;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int type;

  OrderStatus({
    required this.orderStatusId,
    required this.status,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    required this.type,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      orderStatusId: json['order_status_id'] ?? 0,
      status: json['status'] ?? '',
      active: json['active'] ?? 'Y',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      type: json['type'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_status_id': orderStatusId,
      'status': status,
      'active': active,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'type': type,
    };
  }

  // Helper method to get display-friendly status name
  String get displayName {
    switch (status) {
      case 'to-be-checked-with-sender':
        return 'À vérifier avec l\'expéditeur';
      case '3-attempts-done':
        return '3 tentatives effectuées';
      case 'unreachable':
        return 'Injoignable';
      case 'closed':
        return 'Fermé';
      case 'cancelled-by-sender':
        return 'Annulé par l\'expéditeur';
      case 'rescheduled-dated':
        return 'Reprogrammé avec date';
      case 'rescheduled-tomorrow':
        return 'Reprogrammé pour demain';
      case 'no-answer':
        return 'Pas de réponse';
      case 'wrong-address':
        return 'Mauvaise adresse';
      case 'invalid-number':
        return 'Numéro invalide';
      case 'duplicate-package':
        return 'Colis dupliqué';
      case 'wrong-amount':
        return 'Montant incorrect';
      case 'order-not-conformed':
        return 'Commande non conforme';
      case 'client-not-serious':
        return 'Client non sérieux';
      case 'number-in-blacklist':
        return 'Numéro en liste noire';
      case 'cancled-by-sender-client':
        return 'Annulé par expéditeur-client';
      default:
        return status.replaceAll('-', ' ').toUpperCase();
    }
  }

  @override
  String toString() {
    return 'OrderStatus{orderStatusId: $orderStatusId, status: $status, active: $active}';
  }
}