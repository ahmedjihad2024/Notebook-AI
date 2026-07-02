import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:notebook_ai/core/extensions/extensions.dart';
import 'package:notebook_ai/core/res/color_manager.dart';
import 'package:notebook_ai/core/res/fonts_manager.dart';
import 'package:notebook_ai/core/res/sizes_manager.dart';
import 'package:notebook_ai/features/notes/data/models/note_model.dart';
import 'package:notebook_ai/features/notes/data/providers/navigation_provider.dart';
import 'package:notebook_ai/features/notes/data/providers/notes_provider.dart';
import 'package:notebook_ai/features/notes/view/widgets/note_card.dart';

/// Search view matching the Figma design.
///
/// "Quick Find / Search" header, search input bar, results when querying,
/// and "Recent" + "Browse by tag" cloud when idle.
class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
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
    final notes = ref.watch(notesProvider);
    final nav = ref.read(notesNavProvider.notifier);

    // Search results
    final results = _query.isNotEmpty
        ? notes.where((n) {
            return n.title.toLowerCase().contains(_query) ||
                n.body.toLowerCase().contains(_query) ||
                n.tags.any(
                    (t) => t.label.toLowerCase().contains(_query)) ||
                (n.summary ?? '').toLowerCase().contains(_query);
          }).toList()
        : <NoteModel>[];

    // Recent (when not searching)
    final recent = _query.isEmpty
        ? (notes.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)))
            .take(4)
            .toList()
        : <NoteModel>[];

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
              Text(
                'Quick Find',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: FontsM.dmSans.name,
                  color: ColorM.primaryAccent,
                  fontWeight: FontWeightM.medium,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Search',
                style: context.headlineSmall.copyWith(
                  fontWeight: FontWeightM.bold,
                  color: ColorM.foreground,
                ),
              ),
              SizedBox(height: 16.h),

              // Search input
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: ColorM.cardBackground,
                  borderRadius:
                      BorderRadius.circular(SizeM.cardBorderRadius.r),
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
                          hintText: 'Search notes, tags, folders…',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: ColorM.mutedForeground,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
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

        // ── Content ──
        Expanded(
          child: ListView(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              bottom: 120.h,
            ),
            children: _query.isNotEmpty
                ? _buildSearchResults(results, nav)
                : _buildIdleContent(recent, nav),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSearchResults(
      List<NoteModel> results, NotesNavNotifier nav) {
    return [
      Text(
        '${results.length} result${results.length != 1 ? 's' : ''}',
        style: TextStyle(
          fontSize: 11.sp,
          fontFamily: FontsM.dmSans.name,
          letterSpacing: 2,
          color: ColorM.mutedForeground,
        ),
      ),
      SizedBox(height: 12.h),
      if (results.isEmpty)
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
                'No matches for "${_searchController.text}"',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: ColorM.mutedForeground,
                ),
              ),
            ],
          ),
        )
      else
        ...results.map(
          (note) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: NoteCard(
              note: note,
              onTap: () => nav.openNote(note),
              onStar: () =>
                  ref.read(notesProvider.notifier).toggleStar(note.id),
            ),
          ),
        ),
    ];
  }

  List<Widget> _buildIdleContent(
      List<NoteModel> recent, NotesNavNotifier nav) {
    return [
      // Recent section
      Text(
        'RECENT',
        style: TextStyle(
          fontSize: 11.sp,
          fontFamily: FontsM.dmSans.name,
          fontWeight: FontWeightM.medium,
          letterSpacing: 2,
          color: ColorM.mutedForeground,
        ),
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
          ).premiumAppear(index: recent.indexOf(note), baseDelay: 50),
        ),
      ),

      // Tag cloud
      SizedBox(height: 24.h),
      Text(
        'BROWSE BY TAG',
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
            onTap: () {
              _searchController.text = label;
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100.r),
                border: Border.all(
                  color: color.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.tag, size: 12.sp, color: color),
                  SizedBox(width: 4.w),
                  Text(
                    label,
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
