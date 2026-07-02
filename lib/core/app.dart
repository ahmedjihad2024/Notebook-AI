import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notebook_ai/core/extensions/view_extensions.dart';
import 'package:notebook_ai/core/res/router/app_router.dart';
import 'package:notebook_ai/core/res/theme_manager.dart';
import 'package:notebook_ai/core/ui_kit/global_keyboard_dismissal.dart';

// dart format off
// ignore: non_constant_identifier_names
GlobalKey<ScaffoldMessengerState> SCAFFOLD_MESSENGER_KEY = GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState>   NAVIGATOR_KEY          = GlobalKey<NavigatorState>();
// dart format on

class MyApp extends StatefulWidget {
  const MyApp._internal();

  static const MyApp _instance = MyApp._internal();

  factory MyApp() => _instance;

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    SCAFFOLD_MESSENGER_KEY = GlobalKey<ScaffoldMessengerState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = View.of(context);
    final aspectRatio = mediaQuery.physicalSize.aspectRatio;

    final designSize = (aspectRatio > 0.5)
        // some designes are not working with the default design size
        // so for 16:9 dimensions we use 375, 667
        ? const Size(375, 667) // 16:9 (iPhone SE)
        : const Size(375, 812); // 20:9 (Android base)
    return ScreenUtilInit(
      designSize: designSize,
      builder: (context, details) {
        return MaterialApp.router(
          scaffoldMessengerKey: SCAFFOLD_MESSENGER_KEY,
          debugShowCheckedModeBanner: false,
          darkTheme: ThemeManager.darkTheme(context),
          theme: ThemeManager.darkTheme(context),
          themeMode: ThemeMode.dark,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          routerConfig: appRouter,
          builder: (context, child) {
            return GlobalKeyboardDismissal(
              child: Stack(
                children: [
                  child!,
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: context.topSafeAreaPadding,
                    child: IgnorePointer(
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  ThemeMode get themeMode => ThemeMode.dark;
}
