import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/infrastructure_providers.dart';
import 'package:mobile/source/example_source.dart';

final exampleSourceProvider = Provider<ExampleSource>(
  (ref) => ExampleSourceImpl(
    networkRequest: ref.read(networkRequestProvider),
    networkRetry: ref.read(networkRetryProvider),
  ),
);
