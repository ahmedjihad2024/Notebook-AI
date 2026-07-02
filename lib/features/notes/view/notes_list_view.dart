import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:notebook_ai/core/extensions/extensions.dart';
import 'package:notebook_ai/core/res/color_manager.dart';
import 'package:notebook_ai/core/res/fonts_manager.dart';
import 'package:notebook_ai/core/ui_kit/customized_smart_refresh.dart';
import 'package:notebook_ai/features/notes/data/providers/home_feed_provider.dart';
import 'package:notebook_ai/features/notes/data/providers/navigation_provider.dart';
import 'package:notebook_ai/features/notes/view/widgets/note_card.dart';

class NotesListView extends ConsumerStatefulWidget {
  const NotesListView({super.key});

  @override
  ConsumerState<NotesListView> createState() => _NotesListViewState();
}

class _NotesListViewState extends ConsumerState<NotesListView> {
  final _refreshController = RefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(homeFeedProvider.notifier).refresh();
    _refreshController.refreshCompleted();
    _refreshController.resetNoData();
  }

  Future<void> _onLoading() async {
    await ref.read(homeFeedProvider.notifier).loadMore();
    ref.read(homeFeedProvider).hasMore
        ? _refreshController.loadComplete()
        : _refreshController.loadNoData();
  }

  @override
  Widget build(BuildContext context) {
    final nav = ref.read(notesNavProvider.notifier);
    final state = ref.watch(homeFeedProvider);

    return Column(
      children: [
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
                '${state.total} notes · ${state.starred.length} starred',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: FontsM.dmSans.name,
                  color: ColorM.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.loading
              ? Center(
                  child: SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation(ColorM.primaryAccent),
                    ),
                  ),
                )
              : CustomizedSmartRefresh(
                  controller: _refreshController,
                  enableRefresh: true,
                  enableLoading: true,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child: ListView(
                    padding: EdgeInsets.only(
                      left: 20.w,
                      right: 20.w,
                      bottom: 120.h,
                    ),
                    children: [
                      if (state.starred.isNotEmpty) ...[
                        _SectionHeader(
                          icon: LucideIcons.star,
                          iconColor: ColorM.starYellow,
                          label: 'STARRED',
                        ),
                        SizedBox(height: 12.h),
                        ...state.starred.map(
                          (note) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: NoteCard(
                              note: note,
                              onTap: () => nav.openNote(note),
                              onStar: () => ref
                                  .read(homeFeedProvider.notifier)
                                  .toggleStar(note.id),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                      _SectionHeader(
                        icon: LucideIcons.clock,
                        iconColor: ColorM.mutedForeground,
                        label: 'RECENT',
                      ),
                      SizedBox(height: 12.h),
                      ...state.recent.map(
                        (note) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: NoteCard(
                            note: note,
                            onTap: () => nav.openNote(note),
                            onStar: () => ref
                                .read(homeFeedProvider.notifier)
                                .toggleStar(note.id),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

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
