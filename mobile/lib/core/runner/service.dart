import 'package:dartz/dartz.dart';
import 'package:mobile/constants/error_strings.dart';
import 'package:mobile/core/failures/failures.dart';
import 'package:mobile/core/network_info/network_info.dart';

class ServiceRunner<F extends Failure, T> {
  final NetworkInfo _networkInfo;

  ServiceRunner(this._networkInfo);

  Future<Either<Failure, T>> tryRemoteandCatch({
    required Future<T> call,
    required String errorTitle,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(
        Failure(
          ErrorStrings.noInternetConnection,
          title: errorTitle,
        ),
      );
    }
    try {
      final result = await call;
      return Right(result);
    } catch (e) {
      return Left(Failure(e.toString(), title: errorTitle));
    }
  }
}
