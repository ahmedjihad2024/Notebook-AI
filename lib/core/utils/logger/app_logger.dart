import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// App-wide logger — a singleton wrapper around the `logger` package so every
/// part of the app logs through one configured instance.
///
/// ```dart
/// AppLogger.instance.i('User signed in');
/// AppLogger.instance.e('Checkout failed', error: e, stackTrace: s);
/// ```
///
/// Levels, low → high: [t]race · [d]ebug · [i]nfo · [w]arning · [e]rror ·
/// [f]atal. In release builds only `warning` and above are kept.
class AppLogger {
  AppLogger._();

  /// The shared instance.
  static final AppLogger instance = AppLogger._();

  late final Logger _logger = Logger(
    // Debug shows everything; release keeps only warnings and above.
    level: kReleaseMode ? Level.warning : Level.trace,
    // ProductionFilter honours [level] in every build mode. (The default
    // DevelopmentFilter silences all logs in release, regardless of level.)
    filter: ProductionFilter(),
    printer: PrettyPrinter(
      // Drop this class's wrapper frames so the printed location points at the
      // real caller (e.g. auth_view.dart), not app_logger.dart. Unlike
      // stackTraceBeginIndex, this filters the frame out entirely, so explicit
      // error stack traces stay intact.
      excludePaths: const ['package:for_u/app/utils/logger/'],
      methodCount: 1,
      errorMethodCount: 8,
      lineLength: 100,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// The underlying `Logger`, exposed for advanced use (custom output,
  /// reconfiguration, passing to a third-party API).
  Logger get raw => _logger;

  /// Trace — the most verbose, fine-grained step-by-step detail.
  void t(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _logger.t(message, error: error, stackTrace: stackTrace);

  /// Debug — diagnostic detail useful while developing.
  void d(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _logger.d(message, error: error, stackTrace: stackTrace);

  /// Info — notable, expected events (navigation, sign-in, etc.).
  void i(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _logger.i(message, error: error, stackTrace: stackTrace);

  /// Warning — something unexpected that the app recovered from.
  void w(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  /// Error — an operation failed; pass [error]/[stackTrace] when you have them.
  void e(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  /// Fatal — an unrecoverable failure.
  void f(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _logger.f(message, error: error, stackTrace: stackTrace);
}
