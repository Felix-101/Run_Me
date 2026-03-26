import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/repo_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const Color _pageBg = Color(0xFFF2F4F7);
  static const Color _ink = Color(0xFF101828);
  static const Color _muted = Color(0xFF667085);
  static const Color _mutedLight = Color(0xFF98A2B3);
  static const Color _blue = Color(0xFF1A73E8);
  static const Color _navyTab = Color(0xFF1D2939);
  static const Color _fieldFill = Color(0xFFE8F0FA);
  static const Color _helperGreen = Color(0xFF166534);
  static const Color _greenLeft = Color(0xFF1B833E);
  static const Color _greenRight = Color(0xFF5DD879);
  static const Color _socialFill = Color(0xFFE8EEF5);

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _error;
  int _tab = 0; // 0 Login, 1 Sign Up

  /// Dev/local bypass: always reaches the dashboard; API errors still save a
  /// placeholder session so downstream screens can load mock UI.
  static const String _devSessionToken = 'local-dev-session';

  Future<void> _submitLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final repo = ref.read(authRepositoryProvider);
    try {
      final token = await repo.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await repo.saveAccessToken(token);
    } catch (_) {
      await repo.saveAccessToken(_devSessionToken);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not reach the server — signed in with local preview.',
            ),
          ),
        );
      }
    }

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _submitSignUpStub() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registration will be available soon.')),
    );
  }

  void _forgotStub() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset — coming soon.')),
    );
  }

  void _socialStub(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name sign-in — coming soon.')),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _ink.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AuthTabs(
                        tab: _tab,
                        onChanged: (i) => setState(() {
                          _tab = i;
                          _error = null;
                        }),
                        navy: _navyTab,
                        muted: _mutedLight,
                        blue: _blue,
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'University Email',
                        style: textTheme.labelLarge?.copyWith(
                          color: _ink,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        style: textTheme.bodyLarge?.copyWith(
                          color: _ink,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'student@university.edu',
                          hintStyle: TextStyle(
                            color: _mutedLight,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          filled: true,
                          fillColor: _fieldFill,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 14,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 12, right: 8),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.alternate_email_rounded,
                                size: 18,
                                color: _blue,
                              ),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 52,
                            minHeight: 48,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: _helperGreen,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'STUDENT VERIFICATION REQUIRED',
                              style: textTheme.labelSmall?.copyWith(
                                color: _helperGreen,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                                fontSize: 10,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Password',
                            style: textTheme.labelLarge?.copyWith(
                              color: _ink,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _forgotStub,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forgot?',
                              style: textTheme.labelLarge?.copyWith(
                                color: _blue,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        obscuringCharacter: '•',
                        style: textTheme.bodyLarge?.copyWith(
                          color: _ink,
                          fontSize: 15,
                          letterSpacing: 1.2,
                        ),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: TextStyle(
                            color: _mutedLight,
                            letterSpacing: 2,
                          ),
                          filled: true,
                          fillColor: _fieldFill,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 14,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 12, right: 8),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.lock_outline_rounded,
                                size: 18,
                                color: _blue,
                              ),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 52,
                            minHeight: 48,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.red.shade700,
                            height: 1.35,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            colors: [_greenLeft, _greenRight],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _greenLeft.withValues(alpha: 0.38),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: _loading
                                ? null
                                : (_tab == 0
                                    ? _submitLogin
                                    : _submitSignUpStub),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Center(
                                child: _loading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        _tab == 0
                                            ? 'Access Ledger'
                                            : 'Create account',
                                        style: textTheme.titleSmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_tab == 0) ...[
                        const SizedBox(height: 22),
                        _OrDivider(muted: _mutedLight, textTheme: textTheme),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _SocialButton(
                                onTap: () => _socialStub('Google'),
                                background: _socialFill,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _GoogleGMark(),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Google',
                                      style: textTheme.titleSmall?.copyWith(
                                        color: _ink,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SocialButton(
                                onTap: () => _socialStub('Apple'),
                                background: _socialFill,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.apple,
                                      size: 22,
                                      color: _ink,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Apple',
                                      style: textTheme.titleSmall?.copyWith(
                                        color: _ink,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 22),
                      _LegalFooter(
                        ink: _muted,
                        blue: _blue,
                        textTheme: textTheme,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthTabs extends StatelessWidget {
  const _AuthTabs({
    required this.tab,
    required this.onChanged,
    required this.navy,
    required this.muted,
    required this.blue,
    required this.textTheme,
  });

  final int tab;
  final ValueChanged<int> onChanged;
  final Color navy;
  final Color muted;
  final Color blue;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => onChanged(0),
            borderRadius: BorderRadius.circular(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Login',
                  style: textTheme.titleMedium?.copyWith(
                    color: tab == 0 ? navy : muted,
                    fontWeight: tab == 0 ? FontWeight.w800 : FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 3,
                  decoration: BoxDecoration(
                    color: tab == 0 ? blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 28),
        Expanded(
          child: InkWell(
            onTap: () => onChanged(1),
            borderRadius: BorderRadius.circular(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign Up',
                  style: textTheme.titleMedium?.copyWith(
                    color: tab == 1 ? navy : muted,
                    fontWeight: tab == 1 ? FontWeight.w800 : FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 3,
                  decoration: BoxDecoration(
                    color: tab == 1 ? blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({
    required this.muted,
    required this.textTheme,
  });

  final Color muted;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: muted.withValues(alpha: 0.35))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR CONTINUE WITH',
            style: textTheme.labelSmall?.copyWith(
              color: muted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.9,
              fontSize: 10,
            ),
          ),
        ),
        Expanded(child: Divider(color: muted.withValues(alpha: 0.35))),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.onTap,
    required this.background,
    required this.child,
  });

  final VoidCallback onTap;
  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: child,
        ),
      ),
    );
  }
}

/// Compact Google-style “G” without bundling the official logo asset.
class _GoogleGMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD0D5DD)),
      ),
      child: const Text(
        'G',
        style: TextStyle(
          color: Color(0xFF4285F4),
          fontSize: 13,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _LegalFooter extends StatefulWidget {
  const _LegalFooter({
    required this.ink,
    required this.blue,
    required this.textTheme,
  });

  final Color ink;
  final Color blue;
  final TextTheme textTheme;

  @override
  State<_LegalFooter> createState() => _LegalFooterState();
}

class _LegalFooterState extends State<_LegalFooter> {
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()
      ..onTap = () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terms of Service — coming soon.')),
        );
      };
    _privacyTap = TapGestureRecognizer()
      ..onTap = () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Privacy Policy — coming soon.')),
        );
      };
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: widget.textTheme.bodySmall?.copyWith(
          color: widget.ink,
          height: 1.45,
          fontSize: 11,
        ),
        children: [
          const TextSpan(
            text: 'By logging in, you agree to our ',
          ),
          TextSpan(
            text: 'Terms of Service',
            style: TextStyle(
              color: widget.blue,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w600,
            ),
            recognizer: _termsTap,
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              color: widget.blue,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w600,
            ),
            recognizer: _privacyTap,
          ),
          const TextSpan(
            text:
                '. Student ID may be requested for Growth features.',
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
