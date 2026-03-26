import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import 'config/app_config.dart';
import 'features/example/views/example_screen.dart';
import 'presentation/screens/loan_detail_screen.dart';
import 'presentation/screens/loan_request_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding/onboarding_decentralized_screen.dart';
import 'screens/onboarding/onboarding_peer_network_screen.dart';
import 'screens/onboarding/onboarding_reputation_screen.dart';
import 'screens/onboarding/onboarding_trust_capital_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        final baseTheme = ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A73E8),
          ),
        );
        return MaterialApp(
          title: 'runme',
          theme: baseTheme.copyWith(
            textTheme: GoogleFonts.spaceGroteskTextTheme(baseTheme.textTheme),
            primaryTextTheme:
                GoogleFonts.spaceGroteskTextTheme(baseTheme.primaryTextTheme),
          ),
          home: const SplashScreen(),
          routes: {
            '/onboarding': (ctx) => const OnboardingReputationScreen(),
            '/onboarding-peer': (ctx) => const OnboardingPeerNetworkScreen(),
            '/onboarding-decentralized': (ctx) =>
                const OnboardingDecentralizedScreen(),
            '/onboarding-trust-capital': (ctx) =>
                const OnboardingTrustCapitalScreen(),
            '/login': (ctx) => const LoginScreen(),
            '/home': (ctx) => const HomeScreen(),
            '/loan-request': (ctx) => const LoanRequestScreen(),
            '/loan-detail': (ctx) {
              final id = ModalRoute.of(ctx)!.settings.arguments as String?;
              if (id == null || id.isEmpty) {
                return const Scaffold(
                  body: Center(child: Text('Missing loan id')),
                );
              }
              return LoanDetailScreen(loanId: id);
            },
            '/example': (ctx) => const ExampleScreen(),
          },
        );
      },
    );
  }
}
