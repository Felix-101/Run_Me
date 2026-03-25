class AdminSummary {
  final int usersCount;
  final String generatedAt;

  AdminSummary({
    required this.usersCount,
    required this.generatedAt,
  });

  factory AdminSummary.fromJson(Map<String, dynamic> json) {
    return AdminSummary(
      usersCount: (json['usersCount'] as num).toInt(),
      generatedAt: json['generatedAt'] as String,
    );
  }
}

