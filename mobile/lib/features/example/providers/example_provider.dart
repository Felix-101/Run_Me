import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/example/states/example_notifier.dart';
import 'package:mobile/features/example/states/example_state.dart';

final exampleNotifierProvider =
    StateNotifierProvider<ExampleNotifier, ExampleState>(
  (ref) => ExampleNotifier(ref),
);
