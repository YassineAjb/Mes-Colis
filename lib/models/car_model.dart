// lib/models/car_model.dart
class Car {

  final int carId;
  final String? carName;
  final String? carNumber;
  final int? agencyId;

  Car({
    required this.carId,
    this.carName,
    this.carNumber,
    this.agencyId,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      carId: json['car_id'] ?? 0,
      carName: json['car_name']?.toString(),
      carNumber: json['car_number']?.toString(),
      agencyId: json['agency_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'car_id': carId,
      'car_name': carName,
      'car_number': carNumber,
      'agency_id': agencyId,
    };
  }
}