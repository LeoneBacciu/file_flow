T notNull<T, E extends Exception>(T? v, [E Function()? exception]) {
  if (v != null) return v;
  if (exception != null) throw exception();
  throw TypeError();
}
