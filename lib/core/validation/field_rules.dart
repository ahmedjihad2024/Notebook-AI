import 'package:flutter/widgets.dart';

/// A synchronous field rule: returns `null` when [value] is valid, or an error
/// message when it isn't.
///
/// The signature matches `SimpleForm.validator` / Flutter's
/// `FormField.validator`, so the same rule can drive inline error text or the
/// imperative [validateOnSubmit] flow below.
typedef Rule = String? Function(String value);

/// Reusable, composable field rules.
abstract final class Rules {
  /// Fails when the trimmed value is empty.
  ///
  /// [message] is optional: fields that signal failure only by focusing (no
  /// visible error text) can leave it empty.
  static Rule required([String message = '']) =>
      (value) => value.trim().isEmpty ? message : null;

  /// Fails when the trimmed value is shorter than [min] characters.
  static Rule minLength(int min, [String message = '']) =>
      (value) => value.trim().length < min ? message : null;

  /// Runs [rules] in order and returns the first failure, or `null` if all pass.
  static Rule all(List<Rule> rules) => (value) {
    for (final rule in rules) {
      final error = rule(value);
      if (error != null) return error;
    }
    return null;
  };
}

/// A field to check when a form is submitted: its current [value], the
/// [focusNode] to move to when it's invalid, and the [rule] it must satisfy.
class SubmitField {
  final String value;
  final FocusNode focusNode;
  final Rule rule;

  const SubmitField({
    required this.value,
    required this.focusNode,
    required this.rule,
  });
}

/// Validates [fields] in order. On the first failure it focuses that field and
/// returns its error message (which may be empty when the field signals only by
/// focus). Returns `null` when every field passes.
String? validateOnSubmit(List<SubmitField> fields) {
  for (final field in fields) {
    final error = field.rule(field.value);
    if (error != null) {
      field.focusNode.requestFocus();
      return error;
    }
  }
  return null;
}
