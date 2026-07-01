import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u/app/extensions/extensions.dart';

class CustomDropDownButton extends StatefulWidget {
  final int itemsCount;
  final String Function(int index) itemsBuilder;
  final int? initialSelectedIndex;
  final String? hintText;
  final Function(int index) onItemSelected;

  const CustomDropDownButton({
    super.key,
    this.initialSelectedIndex,
    required this.itemsCount,
    required this.itemsBuilder,
    required this.onItemSelected,
    this.hintText,
  });

  @override
  State<CustomDropDownButton> createState() => _CustomDropDownButtonState();
}

class _CustomDropDownButtonState<T> extends State<CustomDropDownButton> {
  int? selectedValue;

  @override
  Widget build(BuildContext context) {
    // handle the initialSelectedIndex
    if (selectedValue == null && widget.initialSelectedIndex != null) {
      selectedValue = widget.initialSelectedIndex;
      widget.onItemSelected(selectedValue!);
    }

    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF7FCFF),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: Colors.black.withValues(alpha: .03),
          width: 1.w,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedValue,
          menuMaxHeight: .9.sh,
          menuWidth: 200.w,
          hint: Text(
            widget.hintText ?? "Select",
            style: context.labelMedium.copyWith(color: const Color(0xFF4A5E6D)),
          ),
          borderRadius: BorderRadius.circular(14.r),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, size: 17.w),
          dropdownColor: Colors.white,
          style: context.labelMedium,
          onChanged: (value) {
            setState(() {
              selectedValue = value;
            });
            widget.onItemSelected(value!);
          },
          items: List.generate(widget.itemsCount, (index) {
            return DropdownMenuItem<int>(
              value: index,
              child: Text(
                widget.itemsBuilder(index),
                style: context.labelMedium,
              ),
            );
          }),
        ),
      ),
    );
  }
}
