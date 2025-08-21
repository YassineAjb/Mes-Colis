class Car {
  final int carId;
  final String? registrationNumber;
  final String? active;
  final String? status;
  final int? agencyId;
  final String? createdAt;
  final String? updatedAt;

  Car({
    required this.carId,
    this.registrationNumber,
    this.active,
    this.status,
    this.agencyId,
    this.createdAt,
    this.updatedAt,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      carId: json['car_id'] ?? 0,
      registrationNumber: json['registration_number'],
      active: json['active'],
      status: json['status'],
      agencyId: json['agency_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // For the dropdown, you might want to add a getter for display name
  String get displayName => registrationNumber ?? 'Car #$carId';

  // If you need carName for backward compatibility
  String? get carName => registrationNumber;
}// // lib/models/car_model.dart
// class Car {

//   final int carId;
//   final String? carName;
//   final String? carNumber;
//   final int? agencyId;

//   Car({
//     required this.carId,
//     this.carName,
//     this.carNumber,
//     this.agencyId,
//   });

//   factory Car.fromJson(Map<String, dynamic> json) {
//     return Car(
//       carId: json['car_id'] ?? 0,
//       carName: json['car_name']?.toString(),
//       carNumber: json['car_number']?.toString(),
//       agencyId: json['agency_id'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'car_id': carId,
//       'car_name': carName,
//       'car_number': carNumber,
//       'agency_id': agencyId,
//     };
//   }
// }