import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:notebook_ai/core/extensions/extensions.dart';
import 'package:notebook_ai/core/res/color_manager.dart';
import 'package:notebook_ai/core/res/fonts_manager.dart';
import 'package:notebook_ai/core/res/sizes_manager.dart';
import 'package:notebook_ai/features/notes/data/providers/navigation_provider.dart';
import 'package:notebook_ai/features/notes/data/providers/notes_provider.dart';
import 'package:notebook_ai/features/notes/data/utils/note_utils.dart';

/// Folders view matching the Figma design.
///
/// Shows "Smart Folders / Organize" header, an "All Notes" hero card,
/// and a 2-column grid of category folders with counts.
class FoldersView extends ConsumerWidget {
  const FoldersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final nav = ref.read(notesNavProvider.notifier);

    // Count notes per folder — a note belongs to every folder whose name
    // matches one of its tags, so multi-tag notes appear in multiple folders.
    final counts = <String, int>{};
    for (final folder in kFolders) {
      counts[folder] =
          notes.where((n) => n.tags.any((t) => t.label == folder)).length;
    }
    // "Others" collects notes that have no tags at all.
    final othersCount = notes.where((n) => n.tags.isEmpty).length;

    // Grid folders: "Others" pinned to the top, then the tag folders.
    final gridFolders = [kOthersFolder, ...kFolders];

    return Column(
      children: [
        // ── Header ──
        Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: MediaQuery.of(context).padding.top + 12.h,
            bottom: 20.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Smart Folders',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: FontsM.dmSans.name,
                  color: ColorM.primaryAccent,
                  fontWeight: FontWeightM.medium,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Organize',
                style: context.headlineSmall.copyWith(
                  fontWeight: FontWeightM.bold,
                  color: ColorM.foreground,
                ),
              ),
            ],
          ),
        ),

        // ── Content ──
        Expanded(
          child: ListView(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              bottom: 120.h,
            ),
            children: [
              // ── All Notes Hero Card ──
              GestureDetector(
                onTap: () => nav.openFolder('__all__'),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: BoxDecoration(
                    color: ColorM.primaryAccent,
                    borderRadius:
                        BorderRadius.circular(SizeM.cardBorderRadius.r),
                    border: Border.all(color: ColorM.border, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'All Notes',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontFamily: FontsM.dmSans.name,
                              color: ColorM.onPrimary.withValues(alpha: 0.7),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${notes.length}',
                            style: context.headlineSmall.copyWith(
                              fontWeight: FontWeightM.bold,
                              color: ColorM.onPrimary,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        LucideIcons.fileText,
                        size: 36.sp,
                        color: ColorM.onPrimary.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),
              ).premiumAppear(index: 0),

              // ── By Category Label ──
              Text(
                'BY CATEGORY',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontFamily: FontsM.dmSans.name,
                  fontWeight: FontWeightM.medium,
                  letterSpacing: 2,
                  color: ColorM.mutedForeground,
                ),
              ),
              SizedBox(height: 12.h),

              // ── Folder Grid ──
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 1.15,
                ),
                itemCount: gridFolders.length,
                itemBuilder: (context, index) {
                  final folder = gridFolders[index];
                  final isOthers = folder == kOthersFolder;
                  final color = isOthers
                      ? ColorM.mutedForeground
                      : (ColorM.tagColors[folder] ?? ColorM.primaryAccent);
                  final count =
                      isOthers ? othersCount : (counts[folder] ?? 0);

                  return GestureDetector(
                    onTap: () => nav.openFolder(folder),
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: ColorM.cardBackground,
                        borderRadius: BorderRadius.circular(
                            SizeM.cardBorderRadius.r),
                        border:
                            Border.all(color: ColorM.border, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Folder icon
                          Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.13),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Icon(
                              isOthers
                                  ? LucideIcons.folderOpen
                                  : LucideIcons.folder,
                              size: 20.sp,
                              color: color,
                            ),
                          ),

                          SizedBox(height: 12.h),

                          // Name
                          Text(
                            folder,
                            style: context.bodyMedium.copyWith(
                              fontWeight: FontWeightM.semiBold,
                              color: ColorM.foreground,
                            ),
                          ),

                          SizedBox(height: 2.h),

                          // Count
                          Text(
                            '$count note${count != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontFamily: FontsM.dmSans.name,
                              color: ColorM.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).premiumAppear(index: index + 1, baseDelay: 50);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
