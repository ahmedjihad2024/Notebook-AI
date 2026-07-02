// ignore_for_file: constant_identifier_names

import 'package:easy_localization/easy_localization.dart';

enum Translation {
  d, loading, no_more, failed_loading, load_more, search_country
}

extension Tra on Translation {
  String get tr => name.tr();
  String trNamed(Map<String, String> params) => name.tr(namedArgs: params);
}
