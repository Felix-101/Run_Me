import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/example/states/example_state.dart';
import 'package:mobile/providers/repo_provider.dart';
import 'package:mobile/repository/example_repository.dart';

class ExampleNotifier extends StateNotifier<ExampleState> {
  final ExampleRepository _repo;

  ExampleNotifier(Ref ref)
      : _repo = ref.read(exampleRepositoryProvider),
        super(ExampleInit());

  Future<void> load() async {
    state = ExampleLoading();
    final result = await _repo.fetchSomething();
    result.fold(
      (l) => state = ExampleFailure(l),
      (r) => state = ExampleSuccess(r),
    );
  }

  void reset() => state = ExampleInit();
}
