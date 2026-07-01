/// **Important Note:** This class contains constants that are used throughout the application.
///
/// - `splashTimer`: The duration in seconds for which the splash screen is displayed.
/// - `translationsPath`: The path to the translation files.
///
/// The API base URL lives in [Env] (`lib/app/config/env.dart`) — it is
/// build-time configuration, not an app constant.
// dart format off
class Constants {
  static const int    splashTimer                  = 2;
  static const String translationsPath             = "assets/translations";
  static const int    locationDialogShowCountLimit = 3;
}
// dart format on
