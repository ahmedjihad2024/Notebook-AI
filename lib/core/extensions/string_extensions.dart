extension NonNullString on String? {
  String get orEmpty => this ?? '';
}

extension StringNumberExtension on String {
  String get onlyDoubles => replaceAll(RegExp(r'[^0-9.]'), '');
  String get onlyNumbers => replaceAll(RegExp(r'[^0-9]'), '');
}
