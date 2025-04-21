class EnumHelper<T extends Enum> {
  T? unknown;
  List<T> _values;

  List<T> get values => _usefulValues;

  T byName(String name) => unknown == null
    ? _map[name]!
    : _map.containsKey(name) ? _map[name]! : unknown!
  ;

  factory EnumHelper(List<T> values, [T? value]) => EnumHelper._(
    values: values,
    unknown: value,
  );

  EnumHelper._({
    required values,
    this.unknown
  }): _values = values {
    _init();
  }

  late Map<String, T> _map;
  late List<T> _usefulValues;

  _init() {
    _map = _values.asNameMap();
    _usefulValues = _values
      .where((e) => e != unknown)
      .toList()
    ;
  }
}
