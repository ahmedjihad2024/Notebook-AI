import 'package:notebook_ai/core/network/error_handler/error_handler.dart';
import 'package:notebook_ai/core/network/error_handler/failure.dart';
import 'package:notebook_ai/core/translations/translations_manager.dart';

extension FailureDisplay on Failure {
  String get displayMessage => switch (this) {
    NoInternetConnection() => Translation.error_no_internet.tr,
    CustomDioLocalError(:final error) => switch (error) {
      DioErrorType.CONNECTION_TIMEOUT ||
      DioErrorType.SEND_TIMEOUT ||
      DioErrorType.RECEIVE_TIMEOUT => Translation.error_no_internet.tr,
      _ => Translation.error_generic.tr,
    },
    ServerError(:final code, :final message) =>
      _serverCopy(code) ?? message ?? Translation.error_generic.tr,
    _ => Translation.error_generic.tr,
  };

  static String? _serverCopy(String? code) => switch (code) {
    'otp_invalid' => Translation.error_otp_invalid.tr,
    'otp_not_found' ||
    'otp_expired' ||
    'otp_max_attempts' => Translation.error_otp_expired.tr,
    'otp_resend_cooldown' => Translation.error_otp_cooldown.tr,
    'account_suspended' => Translation.error_account_suspended.tr,
    'order_already_rated' => Translation.error_order_already_rated.tr,
    'rating_window_closed' => Translation.error_rating_window_closed.tr,
    'order_not_rateable' => Translation.error_order_not_rateable.tr,
    'address_required' => Translation.error_address_required.tr,
    'outside_delivery_zone' => Translation.error_outside_delivery_zone.tr,
    'coverage_city_mismatch' ||
    'district_city_mismatch' ||
    'address_city_mismatch' => Translation.error_address_different_city.tr,
    'cart_branch_mismatch' => Translation.error_cart_different_store.tr,
    'delivery_zone_no_branch' => Translation.map_zone_no_branch.tr,
    'branch_unavailable' ||
    'merchant_unavailable' => Translation.error_branch_unavailable.tr,
    'item_unavailable' ||
    'insufficient_stock' => Translation.error_item_unavailable.tr,
    'empty_cart' => Translation.error_empty_cart.tr,
    'unauthenticated' => Translation.unauthorized.tr,
    _ => null,
  };
}
