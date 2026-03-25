import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'repositories/auth_repository.dart';
import 'services/api_client.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();

  final repo = AuthRepository(api: ApiClient());
  runApp(MyApp(repo: repo));
}

class MyApp extends StatefulWidget {
  final AuthRepository repo;

  const MyApp({super.key, required this.repo});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hydrated = false;
  bool _authed = false;

  @override
  void initState() {
    super.initState();
    _hydrateAuth();
  }

  Future<void> _hydrateAuth() async {
    final token = await widget.repo.getAccessToken();
    if (!mounted) return;
    setState(() {
      _authed = token != null;
      _hydrated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_hydrated) {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text('RunMe')),
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'RunMe',
      initialRoute: _authed ? '/home' : '/login',
      routes: {
        '/login': (ctx) => LoginScreen(repo: widget.repo),
        '/home': (ctx) => HomeScreen(repo: widget.repo),
      },
    );
  }
}
