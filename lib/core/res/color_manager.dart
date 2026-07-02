import 'package:flutter/material.dart';

// dart format off
abstract class ColorM{
  static const Color primary                = Color(0xFF25D366);

  static const Color gray50                 = Color(0xFFF4F4F4);
  static const Color gray100                = Color(0xFFF9FAFB);
  static const Color gray150                = Color(0xFFF7F7F7);
  static const Color gray200                = Color(0xFFE8E8E8);
  static const Color gray250                = Color(0xFFE3E7EC);
  static const Color gray300                = Color(0xFFE5E7EB);
  static const Color gray400                = Color(0xFF78828A);
  static const Color gray500                = Color(0xFF808B9A);
  static const Color gray600                = Color(0xFF6B7280);
  static const Color gray700                = Color(0xFF515151);
  static const Color gray800                = Color(0xFF374151);
  static const Color gray900                = Color(0xFF1F2937);
  static const Color gray950                = Color(0xFF181818);
  static const Color gray1000               = Color(0xFF111827);

  static const Color white                  = Color(0xFFFFFFFF);
  static const Color transparent            = Colors.transparent;
  static const Color red                    = Color(0xFFEF4444);

  // ─── AI Notes Design Tokens · Dark Purple (Figma Make src/styles/theme.css) ──
  static const Color background             = Color(0xFF0D0D14); // --background
  static const Color foreground             = Color(0xFFF0EFFA); // --foreground
  static const Color cardBackground         = Color(0xFF15141F); // --card
  static const Color primaryAccent          = Color(0xFF7C5CFC); // --primary
  static const Color onPrimary              = Color(0xFFFFFFFF); // --primary-foreground
  static const Color secondary              = Color(0xFF1E1C2E); // --secondary
  static const Color accent                 = Color(0xFF2D1F6E); // --accent
  static const Color accentForeground       = Color(0xFFC8BFFF); // --accent-foreground
  static const Color mutedForeground        = Color(0xFF7A778F); // --muted-foreground
  static const Color destructive            = Color(0xFFE0365A); // --destructive
  static const Color starYellow             = Color(0xFFFACC15);
  static const Color border                 = Color(0x267C5CFC); // rgba(124,92,252,0.15)
  static const Color inputBackground        = Color(0xFF1E1C2E); // --input-background
  static const Color recordingRed           = Color(0xFFE0365A);

  // ─── Tag Colors ───────────────────────────────────────────────────────
  static const Color tagWork                = Color(0xFF7C5CFC);
  static const Color tagIdeas               = Color(0xFF22D3A8);
  static const Color tagPersonal            = Color(0xFFF97316);
  static const Color tagResearch            = Color(0xFF38BDF8);
  static const Color tagShopping            = Color(0xFFFB923C);
  static const Color tagHealth              = Color(0xFF4ADE80);
  static const Color tagTravel              = Color(0xFFE879F9);
  static const Color tagFinance             = Color(0xFFFACC15);
  static const Color tagReading             = Color(0xFFF472B6);
  static const Color tagCoding              = Color(0xFF22D3EE);
  static const Color tagFood                = Color(0xFFF87171);
  static const Color tagMusic               = Color(0xFFA78BFA);
  static const Color tagMovies              = Color(0xFFFB7185);
  static const Color tagLearning            = Color(0xFF2DD4BF);
  static const Color tagGoals               = Color(0xFFA3E635);
  static const Color tagEvents              = Color(0xFFC084FC);
  static const Color tagQuotes              = Color(0xFF94A3B8);
  static const Color tagProjects            = Color(0xFF0EA5E9);

  static const Map<String, Color> tagColors = {
    'Work':     tagWork,
    'Ideas':    tagIdeas,
    'Personal': tagPersonal,
    'Research': tagResearch,
    'Shopping': tagShopping,
    'Health':   tagHealth,
    'Travel':   tagTravel,
    'Finance':  tagFinance,
    'Reading':  tagReading,
    'Coding':   tagCoding,
    'Food':     tagFood,
    'Music':    tagMusic,
    'Movies':   tagMovies,
    'Learning': tagLearning,
    'Goals':    tagGoals,
    'Events':   tagEvents,
    'Quotes':   tagQuotes,
    'Projects': tagProjects,
  };
}


