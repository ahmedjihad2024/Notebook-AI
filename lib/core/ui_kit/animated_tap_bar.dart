import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u/app/extensions/extensions.dart';

import 'package:for_u/presentation/res/sizes_manager.dart';
import 'package:for_u/presentation/res/color_manager.dart';
import 'package:for_u/presentation/res/fonts_manager.dart';
import 'package:smooth_corner/smooth_corner.dart';

class AnimatedTapsNavigator extends StatefulWidget {
  final List<String> tabs;
  final int selectedTap;
  final double? margin;
  final double? padding;
  final Function(int) onTap;
  final bool isStickStyle;
  final double? stickHeight;
  final double? stickWidth;
  final double? stickTopMargin;
  final bool isStickAtTop;

  // New customization parameters
  final double? containerHeight;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final Color? activeTextColor;
  final Color? inactiveTextColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? stickColor;
  final Gradient? stickGradient;
  final double? stickBorderRadius;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final double smoothness;

  const AnimatedTapsNavigator({
    required this.tabs,
    required this.selectedTap,
    required this.onTap,
    this.margin,
    this.padding,
    this.isStickStyle = false,
    this.stickHeight,
    this.stickWidth,
    this.stickTopMargin,
    this.isStickAtTop = false,
    this.containerHeight,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.activeTextColor,
    this.inactiveTextColor,
    this.fontSize,
    this.fontWeight,
    this.stickColor,
    this.stickGradient,
    this.stickBorderRadius,
    this.animationDuration,
    this.animationCurve,
    this.smoothness = 0,
    super.key,
  });

  @override
  _AnimatedTapsNavigatorState createState() => _AnimatedTapsNavigatorState();
}

class _AnimatedTapsNavigatorState extends State<AnimatedTapsNavigator> {
  double get margin => widget.margin ?? SizeM.pagePadding.dg;
  double get padding => widget.padding ?? 6.w;
  double get stickHeight => widget.stickHeight ?? 3.h;
  late double stickTopMargin;
  double get containerHeight => widget.containerHeight ?? 50.h;
  double get borderRadius => widget.borderRadius ?? 12.r;
  Color get backgroundColor => widget.backgroundColor ?? Colors.white;
  Color get borderColor => widget.borderColor ?? const Color(0xFFEEF0EE);
  double get borderWidth => widget.borderWidth ?? 1;
  Color get activeTextColor => widget.activeTextColor ?? ColorM.primary;
  Color get inactiveTextColor =>
      widget.inactiveTextColor ?? const Color(0xFF6A6A6A);
  double get fontSize => widget.fontSize ?? 14.sp;
  FontWeight get fontWeight => widget.fontWeight ?? FontWeightM.medium;
  Color? get stickColor => widget.stickColor;
  Gradient? get stickGradient => widget.stickGradient;
  double get stickBorderRadius => widget.stickBorderRadius ?? 6.r;
  Duration get animationDuration =>
      widget.animationDuration ?? const Duration(milliseconds: 300);
  Curve get animationCurve =>
      widget.animationCurve ?? Curves.fastLinearToSlowEaseIn;

  @override
  void initState() {
    // Fix stick positioning
    if (widget.isStickAtTop) {
      stickTopMargin = widget.stickTopMargin ?? padding;
    } else {
      stickTopMargin =
          widget.stickTopMargin ?? (containerHeight - stickHeight - padding);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            (constraints.maxWidth - (margin * 2) - (padding * 2)) /
            widget.tabs.length;

        // Calculate stick width and position
        final calculatedStickWidth =
            widget.stickWidth ?? (width - (padding * 2));

        // Calculate stick left position
        final stickLeft =
            (widget.selectedTap * width) + (width - calculatedStickWidth) / 2;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: margin),
          padding: EdgeInsets.all(padding),
          decoration: ShapeDecoration(
            shape: SmoothRectangleBorder(
              smoothness: widget.smoothness,
              borderRadius: BorderRadius.circular(borderRadius),
              side: BorderSide(color: borderColor, width: borderWidth),
            ),
            color: backgroundColor,
          ),
          height: containerHeight,
          child: Stack(
            children: [
              // Background fill or stick indicator
              if (widget.isStickStyle)
                // Stick/Indicator style
                PositionedDirectional(
                  top: stickTopMargin,
                  start: stickLeft,
                  child: AnimatedContainer(
                    duration: animationDuration,
                    curve: animationCurve,
                    width: calculatedStickWidth,
                    height: stickHeight,
                    decoration: ShapeDecoration(
                      color: stickColor,
                      gradient: stickGradient,
                      shape: SmoothRectangleBorder(
                        smoothness: 1,
                        borderRadius: BorderRadius.circular(stickBorderRadius),
                      ),
                    ),
                  ),
                )
              else
                // Background fill style (original behavior)
                Row(
                  children: [
                    AnimatedContainer(
                      duration: animationDuration,
                      curve: animationCurve,
                      margin: EdgeInsetsDirectional.only(
                        start: (widget.selectedTap * width),
                      ),
                      width: width,
                      height: double.infinity,
                      decoration: ShapeDecoration(
                        color: stickColor,
                        shape: SmoothRectangleBorder(
                          smoothness: 1,
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                      ),
                    ),
                  ],
                ),
              // Tabs content
              Row(
                children: List.generate(widget.tabs.length, (index) {
                  return Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          widget.onTap(index);
                        },
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(padding),
                          width: width,
                          child: FittedBox(
                            child: Text(
                              widget.tabs[index],
                              textAlign: TextAlign.center,
                              softWrap: true,
                              maxLines: 2,
                              style: context.labelMedium.copyWith(
                                fontWeight: fontWeight,
                                fontSize: fontSize,
                                height: 1,
                                color: index == widget.selectedTap
                                    ? (widget.isStickStyle
                                          ? activeTextColor
                                          : Colors.white)
                                    : inactiveTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              if (widget.isStickStyle)
                PositionedDirectional(
                  top: stickTopMargin,
                  child: Container(
                    width: 1.sw,
                    height: 1.w,
                    color: context.colorScheme.surface.withValues(alpha: 0.1),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
