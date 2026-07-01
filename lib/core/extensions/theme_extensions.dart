import 'package:flutter/material.dart';
import 'package:for_u/app/app.dart';

// dart format off
extension ThemeSettings on BuildContext {

  ThemeData     get theme             => Theme.of(this);

  /// 10.sp
  TextStyle     get labelSmall        => theme.textTheme.labelSmall!;

  /// 12.sp
  TextStyle     get labelMedium       => theme.textTheme.labelMedium!;

  /// 14.sp
  TextStyle     get labelLarge        => theme.textTheme.labelLarge!;

  /// 12.sp
  TextStyle     get bodySmall         => theme.textTheme.bodySmall!;

  /// 14.sp
  TextStyle     get bodyMedium        => theme.textTheme.bodyMedium!;

  /// 16.sp
  TextStyle     get bodyLarge         => theme.textTheme.bodyLarge!;

  /// 14.sp
  TextStyle     get titleSmall        => theme.textTheme.titleSmall!;

  /// 16.sp
  TextStyle     get titleMedium       => theme.textTheme.titleMedium!;

  /// 20.sp
  TextStyle     get titleLarge        => theme.textTheme.titleLarge!;

  /// 22.sp
  TextStyle     get headlineSmall     => theme.textTheme.headlineSmall!;

  /// 26.sp
  TextStyle     get headlineMedium    => theme.textTheme.headlineMedium!;

  /// 30.sp
  TextStyle     get headlineLarge     => theme.textTheme.headlineLarge!;

  /// 34.sp
  TextStyle     get displaySmall      => theme.textTheme.displaySmall!;

  /// 40.sp
  TextStyle     get displayMedium     => theme.textTheme.displayMedium!;

  /// 48.sp
  TextStyle     get displayLarge      => theme.textTheme.displayLarge!;

  ColorScheme   get colorScheme       => theme.colorScheme;

  TextTheme     get textTheme         => theme.textTheme;

  // theme mode
  bool          get isDark            => findAncestorStateOfType<MyAppState>()?.themeMode == ThemeMode.dark;
  bool          get isLight           => findAncestorStateOfType<MyAppState>()?.themeMode == ThemeMode.light;
  ThemeMode     get themeMode         => findAncestorStateOfType<MyAppState>()?.themeMode ?? ThemeMode.light;
  
}
// dart format on
