import 'package:mobile/core/failures/failures.dart';

sealed class ExampleState {}

class ExampleInit extends ExampleState {}

class ExampleLoading extends ExampleState {}

class ExampleSuccess extends ExampleState {
  final String data;
  ExampleSuccess(this.data);
}

class ExampleFailure extends ExampleState {
  final Failure failure;
  ExampleFailure(this.failure);
}
