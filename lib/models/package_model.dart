// lib/models/package_model.dart
enum PackageStatus {
  pending('En attente'),
  inTransit('En route'),
  delivered('Livré'),
  failed('Échec de livraison');

  const PackageStatus(this.label);
  final String label;
}

enum FailureReason {
  verifyWithSender('À vérifier avec l\'expéditeur'),
  threeAttempts('3 tentatives accomplies'),
  unreachable('Injoignable'),
  closed('Fermée'),
  cancelledBySender('Annulé par l\'expéditeur'),
  postponedWithDate('Reporté daté'),
  postponedTomorrow('Reporté demain');

  const FailureReason(this.label);
  final String label;
}

class Package {
  final String id;
  final String deliveryAddress;
  final PackageStatus status;
  final String? description;
  final String? clientContact;
  final DateTime? scheduledDate;
  final FailureReason? failureReason;
  final DateTime? postponedDate;
  final double? latitude;
  final double? longitude;

  Package({
    required this.id,
    required this.deliveryAddress,
    required this.status,
    this.description,
    this.clientContact,
    this.scheduledDate,
    this.failureReason,
    this.postponedDate,
    this.latitude,
    this.longitude,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? '',
      status: PackageStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => PackageStatus.pending,
      ),
      description: json['description'],
      clientContact: json['clientContact'],
      scheduledDate: json['scheduledDate'] != null 
          ? DateTime.parse(json['scheduledDate']) 
          : null,
      failureReason: json['failureReason'] != null
          ? FailureReason.values.firstWhere(
              (r) => r.name == json['failureReason'],
              orElse: () => FailureReason.unreachable,
            )
          : null,
      postponedDate: json['postponedDate'] != null 
          ? DateTime.parse(json['postponedDate']) 
          : null,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deliveryAddress': deliveryAddress,
      'status': status.name,
      'description': description,
      'clientContact': clientContact,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'failureReason': failureReason?.name,
      'postponedDate': postponedDate?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Package copyWith({
    String? id,
    String? deliveryAddress,
    PackageStatus? status,
    String? description,
    String? clientContact,
    DateTime? scheduledDate,
    FailureReason? failureReason,
    DateTime? postponedDate,
    double? latitude,
    double? longitude,
  }) {
    return Package(
      id: id ?? this.id,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      status: status ?? this.status,
      description: description ?? this.description,
      clientContact: clientContact ?? this.clientContact,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      failureReason: failureReason ?? this.failureReason,
      postponedDate: postponedDate ?? this.postponedDate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
