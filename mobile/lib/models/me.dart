class Me {
  final String id;
  final String email;
  final String role;
  final String createdAt;

  Me({
    required this.id,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory Me.fromJson(Map<String, dynamic> json) {
    return Me(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

