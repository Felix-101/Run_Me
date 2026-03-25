// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/config/app_config.dart';
import 'package:mobile/main.dart';
import 'package:mobile/models/admin_summary.dart';
import 'package:mobile/models/me.dart';
import 'package:mobile/repositories/auth_repository.dart';
import 'package:mobile/services/api_client.dart';

void main() {
  testWidgets('Shows login when no token is present', (WidgetTester tester) async {
    await AppConfig.load();

    final api = ApiClient();

    // Avoid secure storage / network calls during widget tests.
    final repo = _FakeAuthRepository(api: api);

    await tester.pumpWidget(MyApp(repo: repo));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
  });
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository({required super.api});

  @override
  Future<String?> getAccessToken() async => null;

  @override
  Future<void> saveAccessToken(String token) async {}

  @override
  Future<void> clearAccessToken() async {}

  @override
  Future<String> login({required String email, required String password}) async {
    throw UnimplementedError();
  }

  @override
  Future<Me> fetchMe() async {
    throw UnimplementedError();
  }

  @override
  Future<AdminSummary> fetchAdminSummary() async {
    throw UnimplementedError();
  }
}
