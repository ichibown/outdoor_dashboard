/// extensions
extension EnumByName<T extends Enum> on Iterable<T> {
  T? byNameWithCatch(String name) {
    try {
      return byName(name);
    } catch (e) {
      return null;
    }
  }
}

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
      (Map<K, List<E>> map, E element) =>
          map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));

  num sumBy(num Function(E element) f) {
    num sum = 0;
    for (var item in this) {
      sum += f(item);
    }
    return sum;
  }

  num maxBy(num Function(E element) f) {
    num max = isEmpty ? 0 : f(first);
    for (var item in this) {
      if (f(item) > max) {
        max = f(item);
      }
    }
    return max;
  }

  num minBy(num Function(E element) f) {
    num min = isEmpty ? 0 : f(first);
    for (var item in this) {
      if (f(item) < min) {
        min = f(item);
      }
    }
    return min;
  }

  E? firstWhereOrNull(bool Function(E element) test) {
    final list = where(test);
    return list.isEmpty ? null : list.first;
  }
}
