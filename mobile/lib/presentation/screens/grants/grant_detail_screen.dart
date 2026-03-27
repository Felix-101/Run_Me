import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/grant.dart';
import '../../providers/grant_providers.dart';

const _ink = Color(0xFF101828);
const _muted = Color(0xFF667085);

class GrantDetailScreen extends ConsumerStatefulWidget {
  const GrantDetailScreen({super.key, required this.grantId});

  final String grantId;

  @override
  ConsumerState<GrantDetailScreen> createState() => _GrantDetailScreenState();
}

class _GrantDetailScreenState extends ConsumerState<GrantDetailScreen> {
  final _commentController = TextEditingController();
  final _authorController = TextEditingController(text: 'Supporter');

  @override
  void dispose() {
    _commentController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    final state = ref.watch(grantStoreProvider);
    final g = state.grantById(widget.grantId);
    if (g == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Grant')),
        body: const Center(child: Text('Grant not found.')),
      );
    }
    final donors = state.donorCount(g.id);
    final comments = state.commentsByGrant[g.id] ?? const [];
    final donations = state.donationsByGrant[g.id] ?? const [];
    final recent = List<GrantDonation>.from(donations)
      ..sort((a, b) => b.at.compareTo(a.at));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grant'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (g.isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'URGENT NEED',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFB91C1C),
                    ),
                  ),
                ),
              Text(
                g.title,
                style: textTheme.headlineSmall?.copyWith(
                  color: _ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                g.studentName,
                style: textTheme.titleSmall?.copyWith(color: _muted),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFE4E7EC),
                    child: Icon(Icons.school_outlined, color: _ink.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Borrower profile',
                          style: textTheme.labelMedium?.copyWith(color: _muted),
                        ),
                        Text(
                          '${g.studentName} · ${g.category.label}',
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                g.story,
                style: textTheme.bodyLarge?.copyWith(height: 1.45, color: _ink),
              ),
              if (g.attachmentLabels.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Attachments',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                ...g.attachmentLabels.map(
                  (a) => Text('• $a', style: textTheme.bodySmall?.copyWith(color: _muted)),
                ),
              ],
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: g.progress,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFE4E7EC),
                  color: const Color(0xFF22C55E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${currency.format(g.raisedNaira)} raised of ${currency.format(g.goalNaira)}',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              _SocialProofHeader(
                donorCount: donors,
                commentCount: comments.length,
                textTheme: textTheme,
              ),
              const SizedBox(height: 12),
              if (recent.isNotEmpty) ...[
                Text(
                  'Recent gifts',
                  style: textTheme.labelLarge?.copyWith(
                    color: _muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ...recent.take(5).map(
                      (d) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              d.donorLabel,
                              style: textTheme.bodyMedium,
                            ),
                            Text(
                              currency.format(d.amountNaira),
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                const SizedBox(height: 16),
              ],
              Text(
                'Support messages',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              if (comments.isEmpty)
                Text(
                  'No messages yet — be the first to cheer them on.',
                  style: textTheme.bodyMedium?.copyWith(color: _muted),
                )
              else
                ...comments.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.authorName,
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c.message,
                              style: textTheme.bodyMedium?.copyWith(height: 1.35),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat.MMMd().add_jm().format(c.at.toLocal()),
                              style: textTheme.labelSmall?.copyWith(color: _muted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Your name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Leave a message of support',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  ref.read(grantStoreProvider.notifier).addComment(
                        grantId: g.id,
                        authorName: _authorController.text.trim().isEmpty
                            ? 'Anonymous'
                            : _authorController.text.trim(),
                        message: _commentController.text,
                      );
                  _commentController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thanks — your message was posted.')),
                  );
                },
                child: const Text('Post message'),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  '/grant-donate',
                  arguments: g.id,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEA580C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Gift now — no repayment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialProofHeader extends StatelessWidget {
  const _SocialProofHeader({
    required this.donorCount,
    required this.commentCount,
    required this.textTheme,
  });

  final int donorCount;
  final int commentCount;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ProofTile(
            icon: Icons.people_outline_rounded,
            label: 'Donors',
            value: '$donorCount',
            textTheme: textTheme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ProofTile(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Messages',
            value: '$commentCount',
            textTheme: textTheme,
          ),
        ),
      ],
    );
  }
}

class _ProofTile extends StatelessWidget {
  const _ProofTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.textTheme,
  });

  final IconData icon;
  final String label;
  final String value;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDBA74)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFEA580C)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(color: _muted),
              ),
              Text(
                value,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: _ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
