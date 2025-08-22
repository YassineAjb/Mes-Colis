// lib/models/user_model.dart

class Agency {
  final int agencyId;
  final String name;
  final String code;
  final String tel;
  final String? email;
  final String address;
  final int managerId;
  final String active;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool showContact;

  Agency({
    required this.agencyId,
    required this.name,
    required this.code,
    required this.tel,
    this.email,
    required this.address,
    required this.managerId,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    required this.showContact,
  });

  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
      agencyId: json['agency_id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      tel: json['tel'] ?? '',
      email: json['email'],
      address: json['address'] ?? '',
      managerId: json['manager_id'] ?? 0,
      active: json['active'] ?? 'N',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      showContact: json['show_contact'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agency_id': agencyId,
      'name': name,
      'code': code,
      'tel': tel,
      'email': email,
      'address': address,
      'manager_id': managerId,
      'active': active,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'show_contact': showContact,
    };
  }
}

class Role {
  final int roleId;
  final String roleName;
  final String active;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Role({
    required this.roleId,
    required this.roleName,
    required this.active,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      roleId: json['role_id'] ?? 0,
      roleName: json['role_name'] ?? '',
      active: json['active'] ?? 'N',
      status: json['status'] ?? 'N',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
      'role_name': roleName,
      'active': active,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class User {
  final int userId;
  final String username;
  final String firstName;
  final String? lastName;
  final String? email;
  final String active;
  final int status;
  final int? agencyId;
  final int? roleId;
  final Agency? agency;
  final Role? role;
  final String? address;
  final String? phoneNumber;
  final String? countryCode;
  final String? country;
  final Map<String, dynamic>? userFields;
  final Map<String, dynamic>? params;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.userId,
    required this.username,
    required this.firstName,
    this.lastName,
    this.email,
    required this.active,
    required this.status,
    this.agencyId,
    this.roleId,
    this.agency,
    this.role,
    this.address,
    this.phoneNumber,
    this.countryCode,
    this.country,
    this.userFields,
    this.params,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? 0,
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'],
      email: json['email'],
      active: json['active'] ?? 'N',
      status: json['status'] ?? 0,
      agencyId: json['agency_id'],
      roleId: json['role_id'],
      agency: json['agency'] != null ? Agency.fromJson(json['agency']) : null,
      role: json['role'] != null ? Role.fromJson(json['role']) : null,
      address: json['address'],
      phoneNumber: json['phone_number'],
      countryCode: json['country_code'],
      country: json['country'],
      userFields: json['user_fields'] != null ? Map<String, dynamic>.from(json['user_fields']) : null,
      params: json['params'] != null ? Map<String, dynamic>.from(json['params']) : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'active': active,
      'status': status,
      'agency_id': agencyId,
      'role_id': roleId,
      'agency': agency?.toJson(),
      'role': role?.toJson(),
      'address': address,
      'phone_number': phoneNumber,
      'country_code': countryCode,
      'country': country,
      'user_fields': userFields,
      'params': params,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'User{userId: $userId, username: $username, firstName: $firstName, lastName: $lastName, email: $email, active: $active, status: $status, agencyId: $agencyId, roleId: $roleId, agency: ${agency?.name}, role: ${role?.roleName}}';
  }
}


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

//   @override
//   String toString() {
//     return 'User{userId: $userId, username: $username, first_name: $first_name, email: $email, active: $active, status: $status, agencyId: $agencyId, roles: $roles}';
//   }
// }

