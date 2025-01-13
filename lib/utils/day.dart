enum Day {
  monday(code: 1),
  tuesday(code: 2),
  wednesday(code: 3),
  thursday(code: 4),
  friday(code: 5),
  saturday(code: 6),
  sunday(code: 7);

  final int code;

  const Day({
    required this.code,
  });

}