import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:notebook_ai/core/extensions/extensions.dart';
import 'package:notebook_ai/core/res/color_manager.dart';
import 'package:notebook_ai/core/res/fonts_manager.dart';
import 'package:notebook_ai/features/notes/data/providers/navigation_provider.dart';
import 'package:notebook_ai/features/notes/data/providers/notes_provider.dart';
import 'package:notebook_ai/features/notes/data/utils/note_utils.dart';
import 'package:notebook_ai/features/notes/view/widgets/note_card.dart';

/// Folder detail view matching the Figma design.
///
/// Shows filtered notes for a specific folder, or all notes when
/// folder is '__all__'. Includes back button and empty state.
class FolderDetailView extends ConsumerWidget {
  const FolderDetailView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(notesNavProvider);
    final notes = ref.watch(notesProvider);
    final nav = ref.read(notesNavProvider.notifier);
    final folder = navState.activeFolder;

    final filtered = folder == '__all__'
        ? notes
        : folder == kOthersFolder
            ? notes.where((n) => n.tags.isEmpty).toList()
            : notes.where((n) => n.tags.any((t) => t.label == folder)).toList();

    return Column(
      children: [
        // ── Header ──
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: context.topSafeAreaPadding + 12.h,
                  bottom: 16.h,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: ColorM.border, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => nav.goToFolders(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.arrowLeft,
                            size: 18.sp,
                            color: ColorM.primaryAccent,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'Folders',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: FontsM.dmSans.name,
                              color: ColorM.primaryAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
              
                    SizedBox(height: 12.h),
              
                    // Folder name
                    Text(
                      folder == '__all__' ? 'All Notes' : folder,
                      style: context.titleLarge.copyWith(
                        fontWeight: FontWeightM.bold,
                        color: ColorM.foreground,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${filtered.length} notes',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: FontsM.dmSans.name,
                        color: ColorM.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ── Content ──
        Expanded(
          child: filtered.isEmpty
              ? _EmptyState()
              : ListView.builder(
                  padding: EdgeInsets.only(
                    left: 20.w,
                    right: 20.w,
                    top: 16.h,
                    bottom: 120.h,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final note = filtered[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: NoteCard(
                        note: note,
                        onTap: () => nav.openNote(note),
                        onStar: () => ref
                            .read(notesProvider.notifier)
                            .toggleStar(note.id),
                      ).premiumAppear(index: index, baseDelay: 50),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.folder,
            size: 36.sp,
            color: ColorM.mutedForeground,
          ),
          SizedBox(height: 8.h),
          Text(
            'No notes yet',
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorM.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
