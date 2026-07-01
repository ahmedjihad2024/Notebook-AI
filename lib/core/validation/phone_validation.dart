import 'package:flutter_libphonenumber/flutter_libphonenumber.dart'
    as libphonenumber;

/// Parses a full international number and returns libphonenumber's result map.
/// Throws when the number is not a valid E.164 number.
///
/// This is the single side-effecting boundary of [validatePhoneNumber]; it is
/// injectable so the validation logic can be unit-tested without the platform
/// channel.
typedef PhoneParser = Future<Map<String, dynamic>> Function(String phone);

/// The outcome of validating a phone number.
///
/// Sealed so every call site must handle all three cases — the compiler
/// enforces exhaustiveness in a `switch`, which is what lets the UI react
/// differently to "empty" (focus the field) vs "invalid" (show an error).
sealed class PhoneValidation {
  const PhoneValidation();
}

/// The number is well-formed. [e164] is the normalized form ready to be sent
/// to the backend, e.g. `+966512345678`.
final class ValidPhone extends PhoneValidation {
  final String e164;
  const ValidPhone(this.e164);
}

/// No digits were entered.
final class EmptyPhone extends PhoneValidation {
  const EmptyPhone();
}

/// Digits were entered but they don't form a valid number for the dial code.
final class InvalidPhone extends PhoneValidation {
  const InvalidPhone();
}

/// Validates [number] (the local part, without the dial code) against
/// [dialCode] (e.g. `+966`) using libphonenumber.
///
/// Requires `libphonenumber.init()` to have run at startup. The default
/// [parse] delegates to the real library; tests can pass a fake.
Future<PhoneValidation> validatePhoneNumber({
  required String dialCode,
  required String number,
  PhoneParser parse = libphonenumber.parse,
}) async {
  // The field uses an as-you-type mask, so [number] may contain spaces/dashes.
  // Keep only digits before combining with the dial code.
  final digits = number.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return const EmptyPhone();

  final full = '$dialCode$digits'.replaceAll(RegExp(r'\s'), '');
  try {
    final parsed = await parse(full);
    final e164 = parsed['e164'] as String?;
    return ValidPhone(e164 ?? full);
  } catch (_) {
    return const InvalidPhone();
  }
}
