import 'dart:ui';

// dart format off

enum FontsM{
  ibmPlexSansArabic("ibmp_plex_sans_arabic"),
  dmSans("dm_sans");

  final String name;
  const FontsM(this.name);
}

abstract class FontWeightM {
  /// 100
  static const FontWeight thin         = FontWeight(100);
  /// w200
  static const FontWeight extraLight   = FontWeight(200);
  /// w300
  static const FontWeight light        = FontWeight(300);
  /// w400
  static const FontWeight regular      = FontWeight(400);
  /// w500
  static const FontWeight medium       = FontWeight(500);
  /// w600
  static const FontWeight semiBold     = FontWeight(600);
  /// w700
  static const FontWeight bold         = FontWeight(700);
  /// w800
  static const FontWeight extraBold    = FontWeight(800);
  /// w900
  static const FontWeight black        = FontWeight(900);
  /// normal
  static const FontWeight normal       = FontWeight(400);
}