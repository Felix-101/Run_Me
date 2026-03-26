import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/example/providers/example_provider.dart';
import 'package:mobile/features/example/states/example_state.dart';

class ExampleScreen extends ConsumerStatefulWidget {
  const ExampleScreen({super.key});

  @override
  ConsumerState<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends ConsumerState<ExampleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exampleNotifierProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exampleNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: switch (state) {
        ExampleInit() => const Center(
            child: Text('Tap refresh in initState'),
          ),
        ExampleLoading() => const Center(child: CircularProgressIndicator()),
        ExampleSuccess(:final data) => Center(child: Text(data)),
        ExampleFailure(:final failure) =>
          Center(child: Text(failure.message)),
      },
    );
  }
}
