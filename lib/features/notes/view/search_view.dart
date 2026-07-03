import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:notebook_ai/core/extensions/extensions.dart';
import 'package:notebook_ai/core/res/color_manager.dart';
import 'package:notebook_ai/core/res/fonts_manager.dart';
import 'package:notebook_ai/core/res/sizes_manager.dart';
import 'package:notebook_ai/features/notes/data/providers/navigation_provider.dart';
import 'package:notebook_ai/features/notes/data/providers/search_provider.dart';
import 'package:notebook_ai/features/notes/data/utils/note_utils.dart';
import 'package:notebook_ai/features/notes/view/widgets/note_card.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _searchController.addListener(() {
      ref.read(searchProvider.notifier).search(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nav = ref.read(notesNavProvider.notifier);
    final state = ref.watch(searchProvider);

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
              Text(
                'search.eyebrow'.tr(),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: FontsM.dmSans.name,
                  color: ColorM.primaryAccent,
                  fontWeight: FontWeightM.medium,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'search.title'.tr(),
                style: context.headlineSmall.copyWith(
                  fontWeight: FontWeightM.bold,
                  color: ColorM.foreground,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: ColorM.cardBackground,
                  borderRadius: BorderRadius.circular(SizeM.cardBorderRadius.r),
                  border: Border.all(color: ColorM.border, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.search,
                      size: 18.sp,
                      color: ColorM.mutedForeground,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: ColorM.foreground,
                        ),
                        decoration: InputDecoration(
                          hintText: 'search.hint'.tr(),
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: ColorM.mutedForeground,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (state.isSearching)
                      GestureDetector(
                        onTap: () => _searchController.clear(),
                        child: Icon(
                          LucideIcons.x,
                          size: 16.sp,
                          color: ColorM.mutedForeground,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 120.h),
            children: state.isSearching
                ? _buildSearchResults(state, nav)
                : _buildIdleContent(state, nav),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSearchResults(SearchState state, NotesNavNotifier nav) {
    return [
      Text(
        plural('search.results', state.results.length),
        style: TextStyle(
          fontSize: 11.sp,
          fontFamily: FontsM.dmSans.name,
          letterSpacing: 2,
          color: ColorM.mutedForeground,
        ),
      ),
      SizedBox(height: 12.h),
      if (state.results.isEmpty && !state.loading)
        Padding(
          padding: EdgeInsets.only(top: 40.h),
          child: Column(
            children: [
              Icon(
                LucideIcons.search,
                size: 32.sp,
                color: ColorM.mutedForeground,
              ),
              SizedBox(height: 8.h),
              Text(
                'search.no_matches'.tr(namedArgs: {'query': state.query}),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: ColorM.mutedForeground,
                ),
              ),
            ],
          ),
        )
      else
        ...state.results.map(
          (note) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: NoteCard(
              note: note,
              onTap: () => nav.openNote(note),
              onStar: () =>
                  ref.read(searchProvider.notifier).toggleStar(note.id),
            ),
          ),
        ),
    ];
  }

  List<Widget> _buildIdleContent(SearchState state, NotesNavNotifier nav) {
    return [
      Text(
        'search.recent'.tr(),
        style: TextStyle(
          fontSize: 11.sp,
          fontFamily: FontsM.dmSans.name,
          fontWeight: FontWeightM.medium,
          letterSpacing: 2,
          color: ColorM.mutedForeground,
        ),
      ),
      SizedBox(height: 12.h),
      ...state.recent.map(
        (note) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: NoteCard(
            note: note,
            onTap: () => nav.openNote(note),
            onStar: () =>
                ref.read(searchProvider.notifier).toggleStar(note.id),
          ),
        ),
      ),
      SizedBox(height: 24.h),
      Text(
        'search.browse_by_tag'.tr(),
        style: TextStyle(
          fontSize: 11.sp,
          fontFamily: FontsM.dmSans.name,
          fontWeight: FontWeightM.medium,
          letterSpacing: 2,
          color: ColorM.mutedForeground,
        ),
      ),
      SizedBox(height: 12.h),
      Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: ColorM.tagColors.entries.map((entry) {
          final label = entry.key;
          final color = entry.value;
          return GestureDetector(
            onTap: () => _searchController.text = label,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100.r),
                border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.tag, size: 12.sp, color: color),
                  SizedBox(width: 4.w),
                  Text(
                    localizedTag(label),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: FontsM.dmSans.name,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ];
  }
}
