import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:notebook_ai/core/extensions/extensions.dart';
import 'package:notebook_ai/core/res/color_manager.dart';
import 'package:notebook_ai/core/res/fonts_manager.dart';
import 'package:notebook_ai/core/ui_kit/customized_smart_refresh.dart';
import 'package:notebook_ai/features/notes/data/providers/folder_notes_provider.dart';
import 'package:notebook_ai/features/notes/data/providers/navigation_provider.dart';
import 'package:notebook_ai/features/notes/view/widgets/note_card.dart';

class FolderDetailView extends ConsumerStatefulWidget {
  const FolderDetailView({super.key});

  @override
  ConsumerState<FolderDetailView> createState() => _FolderDetailViewState();
}

class _FolderDetailViewState extends ConsumerState<FolderDetailView> {
  final _refreshController = RefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(folderNotesProvider.notifier).refresh();
    _refreshController.refreshCompleted();
    _refreshController.resetNoData();
  }

  Future<void> _onLoading() async {
    await ref.read(folderNotesProvider.notifier).loadMore();
    ref.read(folderNotesProvider).hasMore
        ? _refreshController.loadComplete()
        : _refreshController.loadNoData();
  }

  @override
  Widget build(BuildContext context) {
    final nav = ref.read(notesNavProvider.notifier);
    final folder = ref.watch(notesNavProvider).activeFolder;
    final state = ref.watch(folderNotesProvider);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: MediaQuery.of(context).padding.top + 12.h,
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
                    Text(
                      folder == '__all__' ? 'All Notes' : folder,
                      style: context.titleLarge.copyWith(
                        fontWeight: FontWeightM.bold,
                        color: ColorM.foreground,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${state.total} notes',
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
              : state.items.isEmpty
                  ? const _EmptyState()
                  : CustomizedSmartRefresh(
                      controller: _refreshController,
                      enableRefresh: true,
                      enableLoading: true,
                      onRefresh: _onRefresh,
                      onLoading: _onLoading,
                      child: ListView.builder(
                        padding: EdgeInsets.only(
                          left: 20.w,
                          right: 20.w,
                          top: 16.h,
                          bottom: 120.h,
                        ),
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          final note = state.items[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: NoteCard(
                              note: note,
                              onTap: () => nav.openNote(note),
                              onStar: () => ref
                                  .read(folderNotesProvider.notifier)
                                  .toggleStar(note.id),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
