import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/constants/error_strings.dart';
import 'package:mobile/core/failures/failures.dart';
import 'package:mobile/core/network_info/network_info.dart';
import 'package:mobile/core/runner/service.dart';
import 'package:mobile/providers/infrastructure_providers.dart';
import 'package:mobile/providers/source_provider.dart';
import 'package:mobile/source/example_source.dart';

abstract class ExampleRepository {
  Future<Either<Failure, String>> fetchSomething();
}

class ExampleRepositoryImpl implements ExampleRepository {
  final NetworkInfo _networkInfo;
  final ExampleSource _remote;

  ExampleRepositoryImpl({required Ref ref})
      : _remote = ref.read(exampleSourceProvider),
        _networkInfo = ref.read(networkInfoProvider);

  @override
  Future<Either<Failure, String>> fetchSomething() async {
    final sR = ServiceRunner<Failure, String>(_networkInfo);
    return sR.tryRemoteandCatch(
      call: _remote.getData(),
      errorTitle: ErrorStrings.errorMakingRequest,
    );
  }
}
