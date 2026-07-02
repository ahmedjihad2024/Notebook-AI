import 'package:flutter/material.dart';

import 'package:notebook_ai/core/res/fonts_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notebook_ai/core/res/sizes_manager.dart';
import 'package:smooth_corner/smooth_corner.dart';

import 'color_manager.dart';

class ThemeManager {
  // Always-dark theme (Figma Make `.dark` palette).
  static ThemeData darkTheme(BuildContext context) => ThemeData(
    fontFamily: FontsM.ibmPlexSansArabic.name,
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ColorM.background,
    colorScheme: ColorScheme.dark(
      primary: ColorM.primaryAccent,
      onPrimary: ColorM.onPrimary,
      surface: ColorM.background,
      onSurface: ColorM.foreground,
    ),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    textTheme: TextStyles.customTextTheme(ColorM.foreground),
    visualDensity: VisualDensity.comfortable,
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        // tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        // padding: WidgetStatePropertyAll(EdgeInsets.zero),
        minimumSize: WidgetStatePropertyAll(Size.zero),
        backgroundColor: WidgetStatePropertyAll(ColorM.primary),
        iconColor: WidgetStatePropertyAll(ColorM.white),
        iconSize: WidgetStatePropertyAll(12.sp),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size.zero),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return ColorM.gray500.withValues(alpha: .5);
          }
          return ColorM.primary;
        }),
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
        // minimumSize: WidgetStatePropertyAll(Size(double.infinity, 60.w)),
        shape: WidgetStatePropertyAll(
          SmoothRectangleBorder(
            borderRadius: BorderRadius.circular(SizeM.commonBorderRadius.r),
          ),
        ),
        textStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 18.sp, color: ColorM.white),
        ),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: ColorM.foreground,
      selectionColor: ColorM.foreground.withValues(alpha: .1),
      selectionHandleColor: ColorM.foreground,
    ),
  );

  // static get darkTheme => ThemeData(
  //       fontFamily: FontsM.IBMPlexSansArabic.name,
  //       colorScheme:
  //           ColorScheme.light(primary: ColorM.purple, secondary: ColorM.white),
  //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //       scaffoldBackgroundColor: ColorM.black,
  //       textTheme: TextStyles.customTextTheme(ColorM.white),
  //       visualDensity: VisualDensity.comfortable,
  //       iconButtonTheme: IconButtonThemeData(
  //           style: ButtonStyle(
  //               // tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //               // padding: WidgetStatePropertyAll(EdgeInsets.zero),
  //               minimumSize: WidgetStatePropertyAll(Size.zero),
  //               backgroundColor: WidgetStatePropertyAll(ColorM.purple),
  //               iconColor: WidgetStatePropertyAll(ColorM.white),
  //               iconSize: WidgetStatePropertyAll(12.sp))),
  //       textButtonTheme: TextButtonThemeData(
  //           style: ButtonStyle(
  //               minimumSize: WidgetStatePropertyAll(Size.zero),
  //               backgroundColor: WidgetStateProperty.resolveWith((states) {
  //                 if (states.contains(WidgetState.disabled)) {
  //                   return ColorM.white.withValues(alpha: .5);
  //                 }
  //                 return ColorM.purple;
  //               }),
  //               padding: WidgetStatePropertyAll(EdgeInsets.zero),
  //               // minimumSize: WidgetStatePropertyAll(Size(double.infinity, 60.w)),
  //               shape: WidgetStatePropertyAll(RoundedRectangleBorder(
  //                   borderRadius:
  //                       BorderRadius.circular(SizeM.commonBorderRadius.r))),
  //               textStyle: WidgetStatePropertyAll(
  //                   TextStyle(fontSize: 18.sp, color: ColorM.white)))),
  //       textSelectionTheme: TextSelectionThemeData(
  //           cursorColor: ColorM.white,
  //           selectionColor: ColorM.white.withValues(alpha: .1),
  //           selectionHandleColor: ColorM.white),
  //     );
}

class TextStyles {
  static TextTheme customTextTheme(Color color, [additionalFontSize = 0.0]) =>
      TextTheme(
        labelSmall: TextStyle(
          fontSize: 10.sp,
          color: color,
          fontWeight: FontWeightM.regular,
        ),
        labelMedium: TextStyle(
          fontSize: 12.sp,
          color: color,
          fontWeight: FontWeightM.regular,
        ),
        labelLarge: TextStyle(
          fontSize: 14.sp,
          color: color,
          fontWeight: FontWeightM.regular,
        ),
        bodySmall: TextStyle(
          fontSize: 12.sp,
          color: color,
          fontWeight: FontWeightM.regular,
        ),
        bodyMedium: TextStyle(
          fontSize: 14.sp,
          color: color,
          fontWeight: FontWeightM.regular,
        ),
        bodyLarge: TextStyle(
          fontSize: 16.sp,
          color: color,
          fontWeight: FontWeightM.regular,
        ),
        titleSmall: TextStyle(
          fontSize: 14.sp,
          color: color,
          fontWeight: FontWeightM.regular,
        ),
        titleMedium: TextStyle(
          fontSize: 16.sp,
          color: color,
          fontWeight: FontWeightM.regular,
        ),
        titleLarge: TextStyle(
          fontSize: 20.sp,
          color: color,
          fontWeight: FontWeightM.regular,
        ),
        headlineSmall: TextStyle(
          fontSize: 22.sp,
          color: color,
          fontWeight: FontWeightM.regular,
        ),
        headlineMedium: TextStyle(
          fontSize: 26.sp,
          color: color,
          fontWeight: FontWeightM.regular,
        ),
        headlineLarge: TextStyle(
          fontSize: 30.sp,
          color: color,
          fontWeight: FontWeightM.regular,
        ),
        displaySmall: TextStyle(
          fontSize: 34.sp,
          color: color,
          fontWeight: FontWeightM.regular,
        ),
        displayMedium: TextStyle(
          fontSize: 40.sp,
          color: color,
          fontWeight: FontWeightM.regular,
        ),
        displayLarge: TextStyle(
          fontSize: 48.sp,
          color: color,
          fontWeight: FontWeightM.regular,
        ),
      );
}
