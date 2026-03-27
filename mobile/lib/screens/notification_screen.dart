import 'package:flutter/material.dart';

/// In-app notifications hub; wire to a backend feed when available.
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const Color _ink = Color(0xFF101828);
  static const Color _muted = Color(0xFF667085);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          Text(
            'Recent',
            style: theme.titleSmall?.copyWith(
              color: _ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _Tile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Wallet top-up confirmed',
            subtitle: 'Your wallet was funded successfully.',
            time: 'Today',
            theme: theme,
          ),
          _Tile(
            icon: Icons.handshake_outlined,
            title: 'Loan update',
            subtitle: 'A peer loan you follow changed status.',
            time: 'Yesterday',
            theme: theme,
          ),
          _Tile(
            icon: Icons.notifications_active_outlined,
            title: 'Repayment reminder',
            subtitle: 'An installment is due in 3 days.',
            time: '2d ago',
            theme: theme,
          ),
          const SizedBox(height: 24),
          Text(
            'Nothing else for now — push and in-app alerts will show here.',
            style: theme.bodySmall?.copyWith(color: _muted, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.theme,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final TextTheme theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: const Color(0xFF1A73E8), size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.titleSmall?.copyWith(
                          color: NotificationScreen._ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.bodySmall?.copyWith(
                          color: NotificationScreen._muted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  time,
                  style: theme.labelSmall?.copyWith(
                    color: NotificationScreen._muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
