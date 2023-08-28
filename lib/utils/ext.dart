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
