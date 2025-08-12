// lib/models/user_model.dart
class User {
  final String id;
  final String username;
  final String? name;
  final String? email;

  User({
    required this.id,
    required this.username,
    this.name,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
    };
  }
}
