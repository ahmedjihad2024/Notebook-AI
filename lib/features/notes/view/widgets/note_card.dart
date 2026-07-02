import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:notebook_ai/core/extensions/extensions.dart';
import 'package:notebook_ai/core/res/color_manager.dart';
import 'package:notebook_ai/core/res/fonts_manager.dart';
import 'package:notebook_ai/core/res/sizes_manager.dart';
import 'package:notebook_ai/features/notes/data/models/note_model.dart';
import 'package:notebook_ai/features/notes/data/utils/note_utils.dart';
import 'package:notebook_ai/features/notes/view/widgets/tag_pill.dart';

/// Note card matching the Figma design.
///
/// Rounded card with title, summary/body preview (2 lines), tag pills,
/// timestamp, and a star toggle button. Includes scale-down tap animation.
class NoteCard extends StatefulWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onStar;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onStar,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: ColorM.cardBackground,
            borderRadius: BorderRadius.circular(SizeM.cardBorderRadius.r),
            border: Border.all(color: ColorM.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title + Star ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeightM.semiBold,
                        color: ColorM.foreground,
                        height: 1.3,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: widget.onStar,
                    child: Icon(
                      LucideIcons.star,
                      size: 16.sp,
                      color: widget.note.starred
                          ? ColorM.starYellow
                          : ColorM.mutedForeground,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              // ── Summary or body preview ──
              Text(
                widget.note.summary ?? widget.note.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: ColorM.mutedForeground,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 12.h),

              // ── Tags + Timestamp ──
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 4.w,
                      runSpacing: 4.h,
                      children: widget.note.tags
                          .take(2)
                          .map((tag) => TagPill(tag: tag))
                          .toList(),
                    ),
                  ),
                  Text(
                    timeAgo(widget.note.createdAt),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontFamily: FontsM.dmSans.name,
                      color: ColorM.mutedForeground,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
