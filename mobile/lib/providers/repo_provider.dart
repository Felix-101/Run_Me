import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/repositories/auth_repository.dart';
import 'package:mobile/repository/example_repository.dart';
import 'package:mobile/services/api_client.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(api: ApiClient()),
);

final exampleRepositoryProvider = Provider<ExampleRepository>(
  (ref) => ExampleRepositoryImpl(ref: ref),
);
