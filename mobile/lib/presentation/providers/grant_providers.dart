import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/grant.dart';

final grantStoreProvider =
    StateNotifierProvider<GrantStoreNotifier, GrantAppState>(
  (ref) => GrantStoreNotifier(),
);

class GrantAppState {
  const GrantAppState({
    required this.grants,
    required this.donationsByGrant,
    required this.commentsByGrant,
  });

  final List<Grant> grants;
  final Map<String, List<GrantDonation>> donationsByGrant;
  final Map<String, List<GrantComment>> commentsByGrant;

  Grant? grantById(String id) {
    try {
      return grants.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  int donorCount(String grantId) {
    final gifts = donationsByGrant[grantId] ?? const [];
    return gifts.map((g) => g.donorLabel).toSet().length;
  }
}

class GrantStoreNotifier extends StateNotifier<GrantAppState> {
  GrantStoreNotifier() : super(_initial);

  static GrantAppState get _initial {
    final grants = <Grant>[
      Grant(
        id: 'grant_seed_1',
        title: 'Final exams & accommodation',
        story:
            'I’m a final-year CS student. My family lost income last month and I’m short on rent and exam registration. A small grant would let me finish strong — no strings.',
        goalNaira: 85000,
        raisedNaira: 41200,
        category: GrantCategory.studentStory,
        studentName: 'Amaka O.',
        createdAt: _t,
        isUrgent: false,
      ),
      Grant(
        id: 'grant_seed_2',
        title: 'Laptop repair before thesis deadline',
        story:
            'URGENT: My only laptop died 5 days before thesis submission. I have quotes for repair — this is not a loan, I can’t repay until next year.',
        goalNaira: 35000,
        raisedNaira: 8900,
        category: GrantCategory.urgentNeed,
        studentName: 'Chidi N.',
        createdAt: _t,
        isUrgent: true,
      ),
      Grant(
        id: 'grant_seed_3',
        title: 'STEM lab fees & safety kit',
        story:
            'Education grant for lab access and PPE. I’m committed to tutoring two juniors in return for the community.',
        goalNaira: 120000,
        raisedNaira: 67000,
        category: GrantCategory.education,
        studentName: 'Zainab K.',
        createdAt: _t,
        isUrgent: false,
      ),
    ];

    final donations = <String, List<GrantDonation>>{
      'grant_seed_1': [
        GrantDonation(
          id: 'd1',
          grantId: 'grant_seed_1',
          donorLabel: 'Anonymous',
          amountNaira: 5000,
          at: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        GrantDonation(
          id: 'd2',
          grantId: 'grant_seed_1',
          donorLabel: 'Peer circle #12',
          amountNaira: 12000,
          at: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
      'grant_seed_2': [
        GrantDonation(
          id: 'd3',
          grantId: 'grant_seed_2',
          donorLabel: 'Anonymous',
          amountNaira: 2000,
          at: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ],
      'grant_seed_3': [
        GrantDonation(
          id: 'd4',
          grantId: 'grant_seed_3',
          donorLabel: 'Alumni ’19',
          amountNaira: 15000,
          at: DateTime.now().subtract(const Duration(days: 3)),
        ),
        GrantDonation(
          id: 'd5',
          grantId: 'grant_seed_3',
          donorLabel: 'Anonymous',
          amountNaira: 8000,
          at: DateTime.now().subtract(const Duration(days: 2)),
        ),
        GrantDonation(
          id: 'd6',
          grantId: 'grant_seed_3',
          donorLabel: 'STEM club',
          amountNaira: 22000,
          at: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    };

    final comments = <String, List<GrantComment>>{
      'grant_seed_1': [
        GrantComment(
          id: 'c1',
          authorName: 'Tolu',
          message: 'Rooting for you — submitted a small gift.',
          at: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        GrantComment(
          id: 'c2',
          authorName: 'Campus mutual aid',
          message: 'Verified student ID on file. 💙',
          at: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
      'grant_seed_3': [
        GrantComment(
          id: 'c3',
          authorName: 'Dr. A.',
          message: 'Happy to endorse this need.',
          at: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ],
    };

    return GrantAppState(
      grants: grants,
      donationsByGrant: donations,
      commentsByGrant: comments,
    );
  }

  static DateTime get _t => DateTime.utc(2026, 3, 1);

  void donate({
    required String grantId,
    required double amountNaira,
    String donorLabel = 'You',
  }) {
    if (amountNaira <= 0) return;
    final id = 'don_${DateTime.now().millisecondsSinceEpoch}';
    final row = GrantDonation(
      id: id,
      grantId: grantId,
      donorLabel: donorLabel,
      amountNaira: amountNaira,
      at: DateTime.now(),
    );
    final map = Map<String, List<GrantDonation>>.from(state.donationsByGrant);
    map[grantId] = [...(map[grantId] ?? const []), row];

    final grants = state.grants.map((g) {
      if (g.id != grantId) return g;
      final newRaised = g.raisedNaira + amountNaira;
      return Grant(
        id: g.id,
        title: g.title,
        story: g.story,
        goalNaira: g.goalNaira,
        raisedNaira: newRaised,
        category: g.category,
        studentName: g.studentName,
        createdAt: g.createdAt,
        attachmentLabels: g.attachmentLabels,
        isUrgent: g.isUrgent,
      );
    }).toList();

    state = GrantAppState(
      grants: grants,
      donationsByGrant: map,
      commentsByGrant: state.commentsByGrant,
    );
  }

  void addComment({
    required String grantId,
    required String authorName,
    required String message,
  }) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;
    final id = 'com_${DateTime.now().millisecondsSinceEpoch}';
    final c = GrantComment(
      id: id,
      authorName: authorName,
      message: trimmed,
      at: DateTime.now(),
    );
    final map = Map<String, List<GrantComment>>.from(state.commentsByGrant);
    map[grantId] = [...(map[grantId] ?? const []), c];
    state = GrantAppState(
      grants: state.grants,
      donationsByGrant: state.donationsByGrant,
      commentsByGrant: map,
    );
  }

  void submitGrantRequest({
    required String title,
    required String story,
    required double goalNaira,
    required GrantCategory category,
    required String studentName,
    List<String> attachmentLabels = const [],
    bool isUrgent = false,
  }) {
    final id = 'grant_${DateTime.now().millisecondsSinceEpoch}';
    final g = Grant(
      id: id,
      title: title,
      story: story,
      goalNaira: goalNaira,
      raisedNaira: 0,
      category: category,
      studentName: studentName,
      createdAt: DateTime.now().toUtc(),
      attachmentLabels: attachmentLabels,
      isUrgent: isUrgent,
    );
    state = GrantAppState(
      grants: [g, ...state.grants],
      donationsByGrant: state.donationsByGrant,
      commentsByGrant: state.commentsByGrant,
    );
  }
}
