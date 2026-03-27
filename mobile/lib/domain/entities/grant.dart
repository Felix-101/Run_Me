/// Non-repayable peer support (grants).
enum GrantCategory {
  studentStory,
  urgentNeed,
  education,
}

extension GrantCategoryLabel on GrantCategory {
  String get label {
    switch (this) {
      case GrantCategory.studentStory:
        return 'Student stories';
      case GrantCategory.urgentNeed:
        return 'Urgent needs';
      case GrantCategory.education:
        return 'Education';
    }
  }
}

class GrantComment {
  const GrantComment({
    required this.id,
    required this.authorName,
    required this.message,
    required this.at,
  });

  final String id;
  final String authorName;
  final String message;
  final DateTime at;
}

class GrantDonation {
  const GrantDonation({
    required this.id,
    required this.grantId,
    required this.donorLabel,
    required this.amountNaira,
    required this.at,
  });

  final String id;
  final String grantId;
  final String donorLabel;
  final double amountNaira;
  final DateTime at;
}

class Grant {
  const Grant({
    required this.id,
    required this.title,
    required this.story,
    required this.goalNaira,
    required this.raisedNaira,
    required this.category,
    required this.studentName,
    required this.createdAt,
    this.attachmentLabels = const [],
    this.isUrgent = false,
  });

  final String id;
  final String title;
  final String story;
  final double goalNaira;
  final double raisedNaira;
  final GrantCategory category;
  final String studentName;
  final DateTime createdAt;
  /// Mock display names for picked media (no upload in demo).
  final List<String> attachmentLabels;
  final bool isUrgent;

  double get progress =>
      goalNaira <= 0 ? 0 : (raisedNaira / goalNaira).clamp(0.0, 1.0);
}
