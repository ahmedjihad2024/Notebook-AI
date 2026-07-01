import 'package:flutter/services.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';

/// Builds an as-you-type phone formatter for the given ISO [countryCode]
/// (e.g. `SA`, `GB`). The user types only the national part — the dial code is
/// shown separately in the field's prefix — so the mask excludes the country
/// code, and any leading trunk `0` (e.g. `0512…`) is stripped first.
///
/// The country mask is appended only when the country is known
/// (after `libphonenumber.init()` has populated [CountryManager]); the field
/// still strips leading zeros and accepts input before that.
List<TextInputFormatter> phoneInputFormatters(String countryCode) {
  final formatters = <TextInputFormatter>[const StripLeadingZerosFormatter()];

  final countries = CountryManager().countries;
  final index = countries.indexWhere((c) => c.countryCode == countryCode);
  if (index >= 0) {
    formatters.add(LibPhonenumberTextFormatter(country: countries[index]));
  }
  return formatters;
}

/// Drops leading zeros as the user types: the national significant number
/// never starts with the trunk `0` when the dial code is shown separately
/// (Saudi `0512345678` → `512345678`).
class StripLeadingZerosFormatter extends TextInputFormatter {
  const StripLeadingZerosFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (!text.startsWith('0')) return newValue;

    final stripped = text.replaceFirst(RegExp(r'^0+'), '');
    final removed = text.length - stripped.length;
    final offset = (newValue.selection.baseOffset - removed).clamp(
      0,
      stripped.length,
    );
    return TextEditingValue(
      text: stripped,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
