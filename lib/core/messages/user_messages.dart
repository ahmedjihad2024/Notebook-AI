import 'package:notebook_ai/core/network/error_handler/error_handler.dart';
import 'package:notebook_ai/core/network/error_handler/failure.dart';
import 'package:for_u/presentation/res/translations_manager.dart';

/// **Important Note:** This extension provides user-friendly error messages for different types of failures.
///
/// - `userMessage`: Returns the appropriate error message based on the failure type.
/// - `DEFAULT_ERROR_MESSAGE`: The default error message to display when no specific message is available.
///
/// **Usage:**
/// ```dart
/// String message = failure.userMessage;
/// ```
// dart format off
extension UserMessages on Failure {
  String get userMessage => switch (this) {
    // Dio-specific errors
    DioLocalError(message: final msg)              => msg ?? DEFAULT_ERROR_MESSAGE,
    CustomDioLocalError(error: final dioError)     => dioError?.message ?? DEFAULT_ERROR_MESSAGE,

    // Server-side errors
    ServerError(message: final msg)                => msg ?? Translation.error_server.tr,
    CustomServerError(error: final apiError)       => switch (apiError) {
      ApiErrorType.UNAUTHORIZED || _               => apiError?.message ?? DEFAULT_ERROR_MESSAGE,
    },

    // Unexpected errors
    UnexpectedError(message: final msg)            => msg ?? DEFAULT_ERROR_MESSAGE,

    // No internet connection
    NoInternetConnection()                         => Translation.error_no_internet.tr,
    _                                              => DEFAULT_ERROR_MESSAGE,
  };
}

final DEFAULT_ERROR_MESSAGE = Translation.error_generic.tr;
