import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notebook_ai/core/extensions/extensions.dart';
import 'package:notebook_ai/core/res/color_manager.dart';

class CustomCheckBox extends StatelessWidget {
  const CustomCheckBox({
    super.key,
    required this.value,
    this.width,
    this.height,
    this.borderRadius,
    this.borderColor,
    this.fillColor,
    this.checkColor,
    this.backgroundColor,
    this.onChange,
    this.borderWidth,
    this.checkSize,
  });
  final double? width;
  final double? height;
  final double? borderRadius;
  final Color? borderColor;
  final Color? fillColor;
  final Color? checkColor;
  final Color? backgroundColor;
  final bool value;
  final double? borderWidth;
  final double? checkSize;
  final void Function(bool value)? onChange;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChange?.call(!value);
      },
      child: Container(
        width: width ?? 25.w,
        height: height ?? 25.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // color: value
          //     ? fillColor ?? Colors.purple
          //     : backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
          border: !value
              ? Border.all(
                  color:
                      borderColor ??
                      context.colorScheme.surface.withValues(alpha: 0.35),
                  width: borderWidth ?? 1.5,
                )
              : Border.all(color: ColorM.primary, width: borderWidth ?? 1.5),
        ),
        child: value
            ? Icon(
                Icons.check_rounded,
                color: checkColor ?? ColorM.primary,
                size: checkSize ?? 17.w,
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
