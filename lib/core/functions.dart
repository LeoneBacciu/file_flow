import 'package:uuid/uuid.dart';

extension NullApplyExtension<T, R> on T? {
  R? apply(R Function(T) f) {
    final cp = this;
    if (cp != null) {
      return f(cp);
    } else {
      return null;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return this[0].toUpperCase() + substring(1);
  }
}

T id<T>(T v) => v;

String uuid4() => const Uuid().v4();
