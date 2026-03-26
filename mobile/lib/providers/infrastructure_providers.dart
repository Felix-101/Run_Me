import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network_info/network_info.dart';
import 'package:mobile/core/network_request/network_request.dart';
import 'package:mobile/core/network_retry/network_retry.dart';

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final networkInfoProvider = Provider<NetworkInfo>(
  (ref) => NetworkInfo(ref.read(connectivityProvider)),
);

final networkRequestProvider = Provider<NetworkRequest>(
  (ref) => NetworkRequest(),
);

final networkRetryProvider = Provider<NetworkRetry>(
  (ref) => NetworkRetry(),
);
