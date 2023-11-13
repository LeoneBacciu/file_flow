import 'dart:async';

enum OptimisticResultState { success, failed }

class OptimisticCall<T> {
  final T value;
  final Future<void> Function(T) onSend;
  final Future<void> Function(T)? onSuccess;
  final Future<T> Function(T) onError;

  final Completer<(T, OptimisticResultState)> completer = Completer();

  OptimisticCall(
      {required this.value,
      required this.onSend,
      required this.onError,
      this.onSuccess}) {
    onSend(value)
        .then((_) => onSuccess?.call(value))
        .then((_) => (value, OptimisticResultState.success))
        .onError((_, __) =>
            onError(value).then((v) => (v, OptimisticResultState.failed)))
        .then((v) => completer.complete(v));
  }

  T getValue() => value;

  Future<(T, OptimisticResultState)> getResult() => completer.future;
}
