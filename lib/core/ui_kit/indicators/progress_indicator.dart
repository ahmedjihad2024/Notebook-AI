import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:notebook_ai/core/res/color_manager.dart';

class MProgressIndicator extends StatelessWidget {
  final double? height;
  final double? width;
  final double percent;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? borderRadius;
  final VoidCallback? onTap;

  const MProgressIndicator({
    super.key,
    this.height,
    this.width,
    this.percent = 0,
    this.activeColor,
    this.inactiveColor,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 8.w,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
        color: inactiveColor ?? Colors.black.withValues(alpha: .04),
      ),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.fastLinearToSlowEaseIn,
        alignment: AlignmentDirectional.centerStart,
        child: FractionallySizedBox(
          widthFactor: percent / 100,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
              color: activeColor ?? ColorM.primary,
            ),
          ),
        ),
      ),
    );
  }
}
