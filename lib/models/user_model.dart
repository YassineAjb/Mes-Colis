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

