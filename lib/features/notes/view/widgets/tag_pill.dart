import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:notebook_ai/core/res/fonts_manager.dart';
import 'package:notebook_ai/features/notes/data/models/note_model.dart';
import 'package:notebook_ai/features/notes/data/utils/note_utils.dart';

/// Pill-shaped tag chip matching the Figma design.
///
/// Displays a `#Label` with transparent colored background + colored border.
class TagPill extends StatelessWidget {
  final AITag tag;

  const TagPill({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: tag.color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(
          color: tag.color.withValues(alpha: 0.27),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.hash,
            size: 9.sp,
            color: tag.color,
          ),
          SizedBox(width: 2.w),
          Text(
            localizedTag(tag.label),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeightM.medium,
              color: tag.color,
              height: 1.2,
              fontFamily: FontsM.dmSans.name,
            ),
          ),
        ],
      ),
    );
  }
}
