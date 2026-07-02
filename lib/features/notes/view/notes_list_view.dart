import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:notebook_ai/core/extensions/extensions.dart';
import 'package:notebook_ai/core/res/color_manager.dart';
import 'package:notebook_ai/core/res/fonts_manager.dart';
import 'package:notebook_ai/features/notes/data/providers/navigation_provider.dart';
import 'package:notebook_ai/features/notes/data/providers/notes_provider.dart';
import 'package:notebook_ai/features/notes/view/widgets/note_card.dart';

/// Notes list view matching the Figma design.
///
/// Shows "AI Notes / My Notes" header, note/starred counts,
/// starred section, and recent section.
class NotesListView extends ConsumerWidget {
  const NotesListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final nav = ref.read(notesNavProvider.notifier);

    final starred = notes.where((n) => n.starred).toList();
    final recent = notes
        .where((n) => !n.starred)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      children: [
        // ── Header ──
        Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: MediaQuery.of(context).padding.top + 12.h,
            bottom: 16.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Notes',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: FontsM.dmSans.name,
                          color: ColorM.primaryAccent,
                          fontWeight: FontWeightM.medium,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'My Notes',
                        style: context.headlineSmall.copyWith(
                          fontWeight: FontWeightM.bold,
                          color: ColorM.foreground,
                        ),
                      ),
                    ],
                  ),
                  // Add button
                  GestureDetector(
                    onTap: () => nav.openNewNote(),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: ColorM.primaryAccent,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(
                        LucideIcons.plus,
                        color: ColorM.onPrimary,
                        size: 22.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                '${notes.length} notes · ${starred.length} starred',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: FontsM.dmSans.name,
                  color: ColorM.mutedForeground,
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
              // ── Starred Section ──
              if (starred.isNotEmpty) ...[
                _SectionHeader(
                  icon: LucideIcons.star,
                  iconColor: ColorM.starYellow,
                  label: 'STARRED',
                ),
                SizedBox(height: 12.h),
                ...starred.map(
                  (note) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: NoteCard(
                      note: note,
                      onTap: () => nav.openNote(note),
                      onStar: () =>
                          ref.read(notesProvider.notifier).toggleStar(note.id),
                    ).premiumAppear(
                      index: starred.indexOf(note),
                      baseDelay: 50,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],

              // ── Recent Section ──
              _SectionHeader(
                icon: LucideIcons.clock,
                iconColor: ColorM.mutedForeground,
                label: 'RECENT',
              ),
              SizedBox(height: 12.h),
              ...recent.map(
                (note) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: NoteCard(
                    note: note,
                    onTap: () => nav.openNote(note),
                    onStar: () =>
                        ref.read(notesProvider.notifier).toggleStar(note.id),
                  ).premiumAppear(
                    index: recent.indexOf(note) + starred.length,
                    baseDelay: 50,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13.sp, color: iconColor),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontFamily: FontsM.dmSans.name,
            fontWeight: FontWeightM.medium,
            letterSpacing: 2,
            color: ColorM.mutedForeground,
          ),
        ),
      ],
    );
  }
}
