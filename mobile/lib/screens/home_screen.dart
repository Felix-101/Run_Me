import 'package:flutter/material.dart';

import '../models/admin_summary.dart';
import '../models/me.dart';
import '../repositories/auth_repository.dart';

class HomeScreen extends StatefulWidget {
  final AuthRepository repo;

  const HomeScreen({super.key, required this.repo});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = false;
  String? _error;

  Me? _me;
  AdminSummary? _adminSummary;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final me = await widget.repo.fetchMe();
      _me = me;

      if (me.role == 'admin') {
        _adminSummary = await widget.repo.fetchAdminSummary();
      } else {
        _adminSummary = null;
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await widget.repo.clearAccessToken();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_loading) const LinearProgressIndicator(),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                if (_me != null) _buildMeCard(_me!),
                const SizedBox(height: 16),
                if (_adminSummary != null) _buildAdminCard(_adminSummary!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeCard(Me me) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Email: ${me.email}'),
            Text('Role: ${me.role}'),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(AdminSummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Total users: ${summary.usersCount}'),
            Text('Generated at: ${summary.generatedAt}'),
          ],
        ),
      ),
    );
  }
}

