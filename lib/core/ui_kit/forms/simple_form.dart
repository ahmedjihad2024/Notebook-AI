import 'package:for_u/presentation/res/fonts_manager.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u/app/extensions/extensions.dart';
import 'package:for_u/presentation/res/color_manager.dart';
import 'package:for_u/app/ui_kit/shapes/gradient_border_side.dart';
import 'package:for_u/presentation/res/sizes_manager.dart';

import 'custom_form_field.dart';

class SimpleForm extends StatelessWidget {
  final TextEditingController controller;
  final SecurityController? securityController;
  final String hintText;
  final TextInputType keyboardType;
  final FocusNode? focusNode;
  final String? Function(String)? validator;
  final Widget Function(bool)? suffixWidget;
  final Widget? prefixWidget;
  final bool? obscureText;
  final Widget? label;
  final int? textLength;
  final double? height;
  final bool outlineBorder;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Future<Widget?> Function(String, void Function() hide)?
  searchResultsBuilder;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final TextStyle? hintStyle;
  final double? fontSize;
  final int maxLines;
  final AlignmentDirectional alignment;
  final double? borderRadius;
  final bool removeBorders;
  final bool removeShadow;
  final Color? unFocusedBorderColor;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final double smoothness;
  final bool enableCustomValidation;
  final List<Function(String)?>? customValidators;
  final bool enableActiveBorder;
  final TextAlign textAlign;
  final Color? borderColor;
  final TextDirection? textDirection;

  const SimpleForm({
    super.key,
    this.securityController,
    required this.hintText,
    required this.keyboardType,
    required this.controller,
    this.height,
    this.focusNode,
    this.validator,
    this.suffixWidget,
    this.obscureText,
    this.prefixWidget,
    this.textLength,
    this.hintStyle,
    this.label,
    this.backgroundColor,
    this.padding,
    this.outlineBorder = true,
    this.searchResultsBuilder,
    this.onFieldSubmitted,
    this.textInputAction,
    this.fontSize,
    this.maxLines = 1,
    this.alignment = AlignmentDirectional.center,
    this.onChanged,
    this.borderRadius,
    this.removeBorders = false,
    this.removeShadow = true,
    this.unFocusedBorderColor,
    this.readOnly = false,
    this.inputFormatters,
    this.smoothness = 1,
    this.enableCustomValidation = false,
    this.customValidators,
    this.enableActiveBorder = false,
    this.textAlign = TextAlign.start,
    this.borderColor,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    return NiceTextForm(
      key: super.key,
      alignment: alignment,
      maxLines: maxLines,
      enableCustomValidation: enableCustomValidation,
      customValidators: customValidators,
      textAlign: textAlign,
      textDirection: textDirection,
      prefixWidget: prefixWidget,
      height: height ?? 52.h,
      width: double.infinity,
      textLength: textLength,
      controller: securityController,
      searchResultsBuilder: searchResultsBuilder,
      onTextChanged: onChanged,
      inputFormatters: inputFormatters,
      validatorStyle: context.labelSmall.copyWith(
        color: Colors.red,
        fontSize: 9.sp,
        fontWeight: FontWeightM.medium,
      ),
      boxDecoration: ShapeDecoration(
        color: backgroundColor ?? ColorM.white,
        shape: SmoothRectangleBorder(
          smoothness: smoothness,
          borderRadius: BorderRadius.circular(
            borderRadius ?? SizeM.commonBorderRadius.r,
          ),
          side: GradientBorderSide(
            color: borderColor ?? ColorM.gray100,
            width: 1.w,
          ),
        ),
      ),
      activeBoxDecoration: enableActiveBorder
          ? ShapeDecoration(
              color: backgroundColor ?? ColorM.white,
              shape: SmoothRectangleBorder(
                borderRadius: BorderRadius.circular(
                  borderRadius ?? SizeM.commonBorderRadius.r,
                ),
                smoothness: smoothness,
                side: GradientBorderSide(color: ColorM.primary, width: 1.w),
              ),
            )
          : null,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w),
      isPhoneForm: false,
      obscureText: obscureText,
      focusNode: focusNode,
      label: label,
      keyboardType: keyboardType,
      hintText: hintText,
      validator: validator,
      textStyle: context.labelMedium.copyWith(
        fontSize: fontSize ?? context.labelMedium.fontSize!,
      ),
      hintStyle:
          hintStyle ??
          context.labelMedium.copyWith(
            color: ColorM.gray600,
            fontSize: fontSize ?? context.labelMedium.fontSize!,
          ),
      textEditingController: controller,
      sufixWidget: suffixWidget,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      readOnly: readOnly,
    );
  }
}
