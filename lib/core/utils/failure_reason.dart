import 'package:for_u/presentation/res/translations_manager.dart';

/// Localized label for a backend delivery-failure reason. For the `other`
/// reason it shows the captain's free-text note when present, falling back to
/// the generic "other" label. Single source of truth shared by the captain and
/// customer order screens so the wording never drifts between them.
String? failureReasonLabel(String? reason, {String? note}) => switch (reason) {
  null => null,
  'customer_not_available' => Translation.customer_not_available.tr,
  'no_answer' => Translation.not_answering_phone.tr,
  'wrong_address' => Translation.incorrect_address.tr,
  'customer_refused' => Translation.customer_refused_receipt.tr,
  'other' => (note != null && note.trim().isNotEmpty)
      ? note.trim()
      : Translation.other_reason.tr,
  _ => Translation.delivery_failed.tr,
};
