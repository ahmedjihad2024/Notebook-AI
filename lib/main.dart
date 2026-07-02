import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebook_ai/core/app.dart';
import 'package:notebook_ai/core/config/constants.dart';
import 'package:notebook_ai/core/config/supported_locales.dart';
import 'package:notebook_ai/core/di/dependency_injection.dart';
import 'package:notebook_ai/core/utils/logger/app_logger.dart';




/// dart format off
void main() {
  runZonedGuarded(_initApp, _onError);
}

Future<void> _initApp() async {
  // Framework + plugins
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}
  await EasyLocalization.ensureInitialized();
  await DI.init();


  // System UI — light status-bar icons on the dark background
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    UncontrolledProviderScope(
      container: DI.container,
      child: EasyLocalization(
        supportedLocales: SupportedLocales.allLocales,
        startLocale: SupportedLocales.EN.locale,
        path: Constants.translationsPath,
        child: MyApp(),
      ),
    ),
  );
}

void _onError(Object error, StackTrace stack) {
  AppLogger.instance.e('Uncaught error', error: error, stackTrace: stack);
}

// dart pub global activate flutter_gen
// fluttergen -c .\pubspec.yaml
