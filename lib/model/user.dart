import 'dart:convert';

class User {
  final String id;
  final String username;
  final String email;
  final String role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.role = 'User',
    required this.createdAt,
  });

  // Convert a User object to a Map (for JSON encoding)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create a User object from a Map (from JSON decoding)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'User',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Convert a User object to a JSON string
  String toJson() => json.encode(toMap());

  // Create a User object from a JSON string
  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}