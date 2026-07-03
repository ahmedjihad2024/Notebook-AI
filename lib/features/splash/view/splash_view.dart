import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:notebook_ai/core/extensions/extensions.dart';
import 'package:notebook_ai/core/res/color_manager.dart';
import 'package:notebook_ai/core/res/fonts_manager.dart';
import 'package:notebook_ai/core/res/router/app_router.dart';

/// Splash screen with a brief branding animation, then navigates
/// to the notes shell.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    // Navigate to notes after a short delay
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        context.goNamed(Routes.notesShell);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorM.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App icon
                Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    color: ColorM.primaryAccent,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Icon(
                    LucideIcons.sparkles,
                    size: 36.sp,
                    color: ColorM.onPrimary,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'app.name'.tr(),
                  style: context.headlineMedium.copyWith(
                    fontWeight: FontWeightM.bold,
                    color: ColorM.foreground,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'app.tagline'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'monospace',
                    color: ColorM.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
