import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notebook_ai/core/extensions/extensions.dart';

class SelectableWrap extends StatefulWidget {
  const SelectableWrap({
    super.key,
    required this.count,
    required this.buildChild,
    this.initialSelected,
    required this.onSelected,
  });
  final int count;
  final String Function(int index) buildChild;
  final int? initialSelected;
  final void Function(int?) onSelected;

  @override
  State<SelectableWrap> createState() => _SelectableWrapState();
}

class _SelectableWrapState extends State<SelectableWrap> {
  int? selected;

  @override
  void initState() {
    selected = widget.initialSelected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.w,
      children: List.generate(
        widget.count,
        (index) => GestureDetector(
          onTap: () {
            setState(() {
              if (selected == index) {
                selected = null;
                widget.onSelected(null);
              } else {
                selected = index;
                widget.onSelected(index);
              }
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.w, horizontal: 10.w),
            decoration: BoxDecoration(
              color: selected == index ? Colors.purple : Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: selected == index
                    ? Colors.purple
                    : Colors.black.withValues(alpha: .1),
                width: 1.w,
              ),
            ),
            child: Text(
              widget.buildChild(index),
              style: context.labelLarge.copyWith(
                height: 1.2,
                color: selected == index
                    ? Colors.white
                    : Colors.black.withValues(alpha: .5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
