import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/grant.dart';
import '../../providers/grant_providers.dart';

const _ink = Color(0xFF101828);
const _muted = Color(0xFF667085);
const _accent = Color(0xFFEA580C);

/// Grants hub: feed (stories, urgent, education) + request flow. Non-repayable gifts.
class GrantsShellScreen extends ConsumerStatefulWidget {
  const GrantsShellScreen({super.key});

  @override
  ConsumerState<GrantsShellScreen> createState() => _GrantsShellScreenState();
}

class _GrantsShellScreenState extends ConsumerState<GrantsShellScreen> {
  int _sub = 0;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFFFFBF5),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    label: Text('Grant feed'),
                    icon: Icon(Icons.dynamic_feed_rounded),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text('Request grant'),
                    icon: Icon(Icons.edit_note_rounded),
                  ),
                ],
                selected: {_sub},
                onSelectionChanged: (s) => setState(() => _sub = s.first),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _sub,
                children: const [
                  _GrantFeedTab(),
                  _GrantRequestTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Feed ─────────────────────────────────────────────────────────────────────

class _GrantFeedTab extends ConsumerStatefulWidget {
  const _GrantFeedTab();

  @override
  ConsumerState<_GrantFeedTab> createState() => _GrantFeedTabState();
}

class _GrantFeedTabState extends ConsumerState<_GrantFeedTab> {
  int _filter = 0; // 0 all, 1 story, 2 urgent, 3 education

  List<Grant> _filterGrants(List<Grant> all) {
    switch (_filter) {
      case 1:
        return all.where((g) => g.category == GrantCategory.studentStory).toList();
      case 2:
        return all.where((g) => g.isUrgent || g.category == GrantCategory.urgentNeed).toList();
      case 3:
        return all.where((g) => g.category == GrantCategory.education).toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(grantStoreProvider);
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    final list = _filterGrants(state.grants);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'GRANTS',
                      style: textTheme.labelLarge?.copyWith(
                        color: _accent,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('🔥', style: TextStyle(fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Free money for students — gifts, not loans.',
                  style: textTheme.headlineSmall?.copyWith(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Student stories, urgent needs, and education-only asks. '
                  'Every gift is non-repayable.',
                  style: textTheme.bodyMedium?.copyWith(color: _muted, height: 1.4),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FeedChip(
                      label: 'All',
                      selected: _filter == 0,
                      onTap: () => setState(() => _filter = 0),
                    ),
                    _FeedChip(
                      label: 'Student stories',
                      selected: _filter == 1,
                      onTap: () => setState(() => _filter = 1),
                    ),
                    _FeedChip(
                      label: 'Urgent needs',
                      selected: _filter == 2,
                      onTap: () => setState(() => _filter = 2),
                    ),
                    _FeedChip(
                      label: 'Education',
                      selected: _filter == 3,
                      onTap: () => setState(() => _filter = 3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (list.isEmpty)
          const SliverFillRemaining(
            child: Center(child: Text('No grants in this filter yet.')),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final g = list[i];
                  final donors = ref.read(grantStoreProvider).donorCount(g.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _GrantFeedCard(
                      grant: g,
                      donorCount: donors,
                      currency: currency,
                      onOpen: () => Navigator.of(context).pushNamed(
                        '/grant-detail',
                        arguments: g.id,
                      ),
                    ),
                  );
                },
                childCount: list.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _FeedChip extends StatelessWidget {
  const _FeedChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF1A73E8) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: selected ? Colors.white : _ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _GrantFeedCard extends StatelessWidget {
  const _GrantFeedCard({
    required this.grant,
    required this.donorCount,
    required this.currency,
    required this.onOpen,
  });

  final Grant grant;
  final int donorCount;
  final NumberFormat currency;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final pct = (grant.progress * 100).clamp(0, 100).toStringAsFixed(0);
    final excerpt = grant.story.length > 120
        ? '${grant.story.substring(0, 120)}…'
        : grant.story;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE4E7EC)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (grant.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'URGENT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      grant.category.label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                grant.title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                grant.studentName,
                style: textTheme.labelMedium?.copyWith(color: _muted),
              ),
              const SizedBox(height: 10),
              Text(
                excerpt,
                style: textTheme.bodyMedium?.copyWith(
                  color: _muted,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: grant.progress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE4E7EC),
                  color: const Color(0xFF22C55E),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${currency.format(grant.raisedNaira)} of ${currency.format(grant.goalNaira)} · $pct%',
                    style: textTheme.labelSmall?.copyWith(
                      color: _muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.favorite_outline, size: 16, color: _muted),
                      const SizedBox(width: 4),
                      Text(
                        '$donorCount donors',
                        style: textTheme.labelSmall?.copyWith(color: _muted),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onOpen,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Read story & support'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Request ──────────────────────────────────────────────────────────────────

class _GrantRequestTab extends ConsumerStatefulWidget {
  const _GrantRequestTab();

  @override
  ConsumerState<_GrantRequestTab> createState() => _GrantRequestTabState();
}

class _GrantRequestTabState extends ConsumerState<_GrantRequestTab> {
  final _title = TextEditingController();
  final _story = TextEditingController();
  final _amount = TextEditingController();
  final _name = TextEditingController(text: 'You');
  GrantCategory _category = GrantCategory.studentStory;
  final List<String> _media = [];
  bool _urgent = false;
  bool _submitting = false;

  @override
  void dispose() {
    _title.dispose();
    _story.dispose();
    _amount.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickMedia({required bool video}) async {
    final r = await FilePicker.platform.pickFiles(
      type: video ? FileType.video : FileType.image,
      allowMultiple: true,
    );
    if (r == null || r.files.isEmpty) return;
    setState(() {
      for (final f in r.files) {
        if (f.name.isNotEmpty) _media.add('${video ? "Video" : "Photo"}: ${f.name}');
      }
    });
  }

  Future<void> _submit() async {
    final goal = double.tryParse(_amount.text.replaceAll(',', ''));
    if (_title.text.trim().isEmpty ||
        _story.text.trim().length < 20 ||
        goal == null ||
        goal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a title, a real story (20+ chars), and a valid goal amount.'),
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    ref.read(grantStoreProvider.notifier).submitGrantRequest(
          title: _title.text.trim(),
          story: _story.text.trim(),
          goalNaira: goal,
          category: _category,
          studentName: _name.text.trim().isEmpty ? 'Student' : _name.text.trim(),
          attachmentLabels: List<String>.from(_media),
          isUrgent: _urgent,
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your grant request is live on the feed.')),
    );
    _title.clear();
    _story.clear();
    _amount.clear();
    setState(() {
      _media.clear();
      _urgent = false;
      _category = GrantCategory.studentStory;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Request a grant',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tell your story — this is not a loan. Community gifts are non-repayable.',
              style: textTheme.bodyMedium?.copyWith(color: _muted),
            ),
            const SizedBox(height: 20),
            Text(
              'Story (very important)',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _story,
              maxLines: 8,
              maxLength: 2000,
              decoration: const InputDecoration(
                hintText:
                    'What happened? What will this unlock? Why is it a grant, not credit?',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Short headline',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Amount needed (₦)',
                border: OutlineInputBorder(),
                prefixText: '₦ ',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Name / initials on the card',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Category',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SegmentedButton<GrantCategory>(
              segments: const [
                ButtonSegment(
                  value: GrantCategory.studentStory,
                  label: Text('Story'),
                ),
                ButtonSegment(
                  value: GrantCategory.urgentNeed,
                  label: Text('Urgent'),
                ),
                ButtonSegment(
                  value: GrantCategory.education,
                  label: Text('Education'),
                ),
              ],
              selected: {_category},
              onSelectionChanged: (s) =>
                  setState(() => _category = s.first),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _urgent,
              onChanged: (v) => setState(() => _urgent = v),
              title: const Text('Mark as urgent'),
              subtitle: const Text('Shows an urgent badge on the feed'),
            ),
            const SizedBox(height: 8),
            Text(
              'Images & videos (optional)',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickMedia(video: false),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Photos'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickMedia(video: true),
                    icon: const Icon(Icons.videocam_outlined),
                    label: const Text('Videos'),
                  ),
                ),
              ],
            ),
            if (_media.isNotEmpty) ...[
              const SizedBox(height: 8),
              ..._media.map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(m, style: textTheme.bodySmall?.copyWith(color: _muted)),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEA580C),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Publish grant request'),
            ),
          ],
        ),
      ),
    );
  }
}
