import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u/app/extensions/extensions.dart';
import 'package:for_u/app/ui_kit/buttons/custom_ink_button.dart';
import 'package:for_u/presentation/res/color_manager.dart';
import 'package:for_u/presentation/res/fonts_manager.dart';

class CustomActionTile extends StatefulWidget {
  final String title;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final bool showDivider;
  final Widget? expandedContent;

  const CustomActionTile({
    super.key,
    required this.title,
    this.onTap,
    this.padding,
    this.showDivider = true,
    this.expandedContent,
  });

  @override
  State<CustomActionTile> createState() => _CustomActionTileState();
}

class _CustomActionTileState extends State<CustomActionTile> {
  bool _isExpanded = false;

  void _handleTap() {
    if (widget.expandedContent != null) {
      setState(() {
        _isExpanded = !_isExpanded;
      });
    }
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomInkButton(
      onTap: _handleTap,
      backgroundColor: Colors.transparent,
      padding: widget.padding ?? EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeightM.semiBold,
                    color: ColorM.gray900,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: _isExpanded ? 0.25 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.w,
                  color: ColorM.gray400,
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            child: _isExpanded && widget.expandedContent != null
                ? Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: widget.expandedContent!,
                  )
                : const SizedBox.shrink(),
          ),
          if (widget.showDivider) ...[
            16.verticalSpace,
            Container(
              height: 1.h,
              width: double.infinity,
              color: ColorM.gray150,
            ),
          ],
        ],
      ),
    );
  }
}
