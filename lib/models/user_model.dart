// // lib/models/user_model.dart
// class User {
//   final int userId;
//   final String username;
//   final String first_name;
//   final String email;
//   final String active;
//   final int status;
//   final int? agencyId;
//   final List<dynamic> roles;

//   User({
//     required this.userId,
//     required this.username,
//     required this.first_name,
//     required this.email,
//     required this.active,
//     required this.status,
//     this.agencyId,
//     required this.roles,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       userId: json['user_id'] ?? 0,
//       username: json['username'] ?? '',
//       first_name: json['first_name'] ?? '',
//       email: json['email'] ?? '',
//       active: json['active'] ?? 'N',
//       status: json['status'] ?? 0,
//       agencyId: json['agency_id'],
//       roles: json['roles'] ?? [],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'user_id': userId,
//       'username': username,
//       'first_name': first_name,
//       'email': email,
//       'active': active,
//       'status': status,
//       'agency_id': agencyId,
//       'roles': roles,
//     };
//   }

// }
// lib/models/user_model.dart
class User {
  final int userId;
  final String username;
  final String first_name;
  final String email;
  final String active;
  final int status;
  final int? agencyId;
  final List<dynamic> roles;

  User({
    required this.userId,
    required this.username,
    required this.first_name,
    required this.email,
    required this.active,
    required this.status,
    this.agencyId,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? 0,
      username: json['username'] ?? '',
      first_name: json['first_name'] ?? '',
      email: json['email'] ?? '',
      active: json['active'] ?? 'N',
      status: json['status'] ?? 0,
      agencyId: json['agency_id'],
      roles: json['roles'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'first_name': first_name,
      'email': email,
      'active': active,
      'status': status,
      'agency_id': agencyId,
      'roles': roles,
    };
  }

  @override
  String toString() {
    return 'User{userId: $userId, username: $username, first_name: $first_name, email: $email, active: $active, status: $status, agencyId: $agencyId, roles: $roles}';
  }
}
//--------------
/*
class Runsheet {
  final int runsheetId;
  final String? runsheetNumber;
  final int? carId;
  final String? carName;
  final int? deliverymanId;
  final String? deliverymanName;
  final String? date;
  final String? status;
  final int? ordersCount;

  Runsheet({
    required this.runsheetId,
    this.runsheetNumber,
    this.carId,
    this.carName,
    this.deliverymanId,
    this.deliverymanName,
    this.date,
    this.status,
    this.ordersCount,
  });

  factory Runsheet.fromJson(Map<String, dynamic> json) {
    return Runsheet(
      runsheetId: json['runsheet_id'] ?? 0,
      runsheetNumber: json['runsheet_number']?.toString(),
      carId: json['car_id'],
      carName: json['car_name']?.toString(),
      deliverymanId: json['deliveryman_id'],
      deliverymanName: json['deliveryman_name']?.toString(),
      date: json['date']?.toString(),
      status: json['status']?.toString(),
      ordersCount: json['orders_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'runsheet_id': runsheetId,
      'runsheet_number': runsheetNumber,
      'car_id': carId,
      'car_name': carName,
      'deliveryman_id': deliverymanId,
      'deliveryman_name': deliverymanName,
      'date': date,
      'status': status,
      'orders_count': ordersCount,
    };
  }
}
*/
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


//--------------

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