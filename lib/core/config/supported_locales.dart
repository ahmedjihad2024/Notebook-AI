import 'package:flutter/material.dart';

enum SupportedLocales {
  EN(Locale('en')),
  AR(Locale('ar'));

  final Locale locale;
  const SupportedLocales(this.locale);

  static List<Locale> get allLocales {
    return values.map((e) => e.locale).toList();
  }

  static SupportedLocales? fromString(String languageCode) {
    return SupportedLocales.values.firstWhere(
      (t) => t.locale.languageCode == languageCode,
    );
  }
}
