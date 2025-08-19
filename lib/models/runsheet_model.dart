// lib/models/runsheet_model.dart
class Runsheet {
  final int runsheetId;
  final String? runsheetNumber;
  final String? barcode;
  final int? carId;
  final String? carName;
  final String? registrationNumber;
  final int? deliverymanId;
  final String? deliverymanName;
  final String? date;
  final String? status;
  final int? ordersCount;
  final String? agencyName;
  final double? totalPrice;
  final String? type;
  final double? percentage;
  final bool? isPrestataire;

  Runsheet({
    required this.runsheetId,
    this.runsheetNumber,
    this.barcode,
    this.carId,
    this.carName,
    this.registrationNumber,
    this.deliverymanId,
    this.deliverymanName,
    this.date,
    this.status,
    this.ordersCount,
    this.agencyName,
    this.totalPrice,
    this.type,
    this.percentage,
    this.isPrestataire,
  });

  factory Runsheet.fromJson(Map<String, dynamic> json) {
    try {
      // Format the date from ISO string to readable format
      String? formattedDate;
      if (json['created_at'] != null) {
        try {
          final DateTime dateTime = DateTime.parse(json['created_at']);
          formattedDate = '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
        } catch (e) {
          formattedDate = json['created_at']?.toString();
        }
      }

      // Get deliveryman name from nested object
      String? deliverymanName;
      if (json['deliveryman'] != null && json['deliveryman'] is Map) {
        final deliveryman = json['deliveryman'] as Map<String, dynamic>;
        final firstName = deliveryman['first_name']?.toString() ?? '';
        final lastName = deliveryman['last_name']?.toString() ?? '';
        deliverymanName = '$firstName $lastName'.trim();
        if (deliverymanName.isEmpty) deliverymanName = null;
      }

      // Determine status based on API response
      String? statusText;
      if (json['status'] != null) {
        final statusValue = json['status'];
        if (statusValue is int) {
          statusText = statusValue == 1 ? 'Treated' : 'Untreated';
        } else {
          statusText = statusValue.toString();
        }
      }

      // Parse orders count
      int? ordersCount;
      if (json['count_orders'] != null) {
        if (json['count_orders'] is String) {
          ordersCount = int.tryParse(json['count_orders']);
        } else if (json['count_orders'] is int) {
          ordersCount = json['count_orders'];
        }
      }

      // Parse total price
      double? totalPrice;
      if (json['total_price'] != null) {
        if (json['total_price'] is String) {
          totalPrice = double.tryParse(json['total_price']);
        } else if (json['total_price'] is num) {
          totalPrice = json['total_price'].toDouble();
        }
      }

      return Runsheet(
        runsheetId: json['runsheet_id'] ?? 0,
        runsheetNumber: json['runsheet_id']?.toString(), // Using runsheet_id as number since barcode exists
        barcode: json['barcode']?.toString(),
        carId: json['car_id'],
        carName: json['registration_number']?.toString(), // Using registration number as car name
        registrationNumber: json['registration_number']?.toString(),
        deliverymanId: json['deliveryman_id'],
        deliverymanName: deliverymanName,
        date: formattedDate,
        status: statusText,
        ordersCount: ordersCount,
        agencyName: json['name']?.toString(),
        totalPrice: totalPrice,
        type: json['type']?.toString(),
        percentage: json['percentage_runsheet']?.toDouble(),
        isPrestataire: json['is_prestataire'],
      );
    } catch (e) {
      print("Error parsing runsheet JSON: $e");
      print("JSON data: $json");
      
      // Return a minimal runsheet object in case of parsing error
      return Runsheet(
        runsheetId: json['runsheet_id'] ?? 0,
        runsheetNumber: json['runsheet_id']?.toString() ?? 'Unknown',
        barcode: json['barcode']?.toString(),
        status: 'Unknown',
        date: DateTime.now().toString().split(' ')[0], // Today's date as fallback
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'runsheet_id': runsheetId,
      'runsheet_number': runsheetNumber,
      'barcode': barcode,
      'car_id': carId,
      'car_name': carName,
      'registration_number': registrationNumber,
      'deliveryman_id': deliverymanId,
      'deliveryman_name': deliverymanName,
      'date': date,
      'status': status,
      'orders_count': ordersCount,
      'agency_name': agencyName,
      'total_price': totalPrice,
      'type': type,
      'percentage': percentage,
      'is_prestataire': isPrestataire,
    };
  }
}
