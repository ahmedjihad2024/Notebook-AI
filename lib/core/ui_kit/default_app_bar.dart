import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notebook_ai/core/extensions/extensions.dart';
import 'package:notebook_ai/core/ui_kit/buttons/custom_ink_button.dart';
import 'package:notebook_ai/core/res/color_manager.dart';
import 'package:notebook_ai/core/res/fonts_manager.dart';
import 'package:notebook_ai/core/res/sizes_manager.dart';
import 'package:notebook_ai/core/ui_kit/shapes/gradient_border_side.dart';

class DefaultAppBar extends StatelessWidget {
  const DefaultAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.backFunction,
    this.actionButtons,
    this.customBackButton,
    this.hideBackButton = false,
    this.titleAlignment = Alignment.center,
    this.titleTextAlign = TextAlign.center,
    this.padding,
    this.titleColor,
    this.backButtonIconColor,
  });

  final String? title;
  final Widget? titleWidget;
  final VoidCallback? backFunction;
  final List<Widget>? actionButtons;
  final Widget? customBackButton;
  final bool hideBackButton;
  final AlignmentGeometry titleAlignment;
  final TextAlign titleTextAlign;
  final EdgeInsetsGeometry? padding;
  final Color? titleColor;
  final Color? backButtonIconColor;

  EdgeInsetsGeometry get _defaultPadding =>
      EdgeInsets.symmetric(horizontal: SizeM.pagePadding.dg);

  Widget? _buildLeading(BuildContext context) {
    if (hideBackButton) return null;
    if (customBackButton != null) return customBackButton;

    // Determine arrow color based on background
    Color arrowColor = backButtonIconColor ?? ColorM.gray700;
    Color backgroundColor = Colors.transparent;

    return CustomInkButton(
      onTap: backFunction ?? () => Navigator.of(context).maybePop(),
      padding: EdgeInsets.zero,
      width: 38.w,
      height: 38.w,
      smoothness: 0,
      backgroundColor: backgroundColor,
      borderRadius: 12.r,
      alignment: Alignment.center,
      side: GradientBorderSide(color: ColorM.gray300, width: 1.w),
      child: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: arrowColor,
        size: 20.sp,
      ),
    );
  }

  Widget? _buildTitle(BuildContext context) {
    if (titleWidget == null && (title == null || title!.isEmpty)) {
      return SizedBox.shrink();
    }

    final Widget? resolvedTitle =
        titleWidget ??
        (title == null
            ? null
            : Text(
                title!,
                textAlign: titleTextAlign,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.bodyLarge.copyWith(
                  height: 1,
                  fontWeight: FontWeightM.semiBold,
                  color: titleColor,
                ),
              ));

    return resolvedTitle != null
        ? Align(alignment: titleAlignment, child: resolvedTitle)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final leading = _buildLeading(context);
    final titleW = _buildTitle(context);
    final actions = actionButtons ?? const [];

    return Padding(
      padding: padding ?? _defaultPadding,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Leading + Actions: overlaid as a spaceBetween row ─────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button sits on the right (= start in RTL)
              SizedBox(width: 40.w, child: leading),

              // Actions sit on the left (= end in RTL)
              if (actions.isNotEmpty)
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions,
                  ),
                )
              else
                SizedBox(width: 40.w), // placeholder to keep title centered
            ],
          ),

          // ── Title: always truly centered over the full bar width ──────────
          if (titleW != null)
            Padding(
              // Keep the title text from running under the buttons
              padding: EdgeInsets.symmetric(horizontal: 48.w),
              child: titleW,
            ),
        ],
      ),
    );
  }
}
