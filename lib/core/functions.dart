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
