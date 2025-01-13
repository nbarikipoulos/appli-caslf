
List<T>? listMapper<T>(
  dynamic fieldData,
  T Function(dynamic v) mapper
) => fieldData is Iterable
  ? List.from(fieldData)
    .map(mapper)
    .toList()
  : null
;

T? mapper<T>(String? fieldData, T Function(String v) mapper) => fieldData != null
    ? mapper.call(fieldData)
    : null
;