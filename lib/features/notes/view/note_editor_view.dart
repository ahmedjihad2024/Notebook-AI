import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:notebook_ai/core/extensions/extensions.dart';
import 'package:notebook_ai/core/res/color_manager.dart';
import 'package:notebook_ai/core/res/fonts_manager.dart';
import 'package:notebook_ai/core/res/sizes_manager.dart';
import 'package:notebook_ai/core/ui_kit/directional_back_icon.dart';
import 'package:notebook_ai/features/notes/data/providers/navigation_provider.dart';
import 'package:notebook_ai/features/notes/data/providers/note_editor_provider.dart';
import 'package:notebook_ai/features/notes/data/utils/note_utils.dart';
import 'package:notebook_ai/features/notes/view/widgets/tag_pill.dart';

class NoteEditorView extends ConsumerStatefulWidget {
  const NoteEditorView({super.key});

  @override
  ConsumerState<NoteEditorView> createState() => _NoteEditorViewState();
}

class _NoteEditorViewState extends ConsumerState<NoteEditorView> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    final note = ref.read(notesNavProvider).activeNote;
    _titleController = TextEditingController(text: note?.title ?? '');
    _bodyController = TextEditingController(text: note?.body ?? '');
    _bodyController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  NoteEditorNotifier get _editor => ref.read(noteEditorProvider.notifier);

  Future<void> _back() async {
    await _editor.save(
      title: _titleController.text,
      body: _bodyController.text,
    );
    ref.read(notesNavProvider.notifier).goToList();
  }

  Future<void> _delete() async {
    await _editor.delete();
    ref.read(notesNavProvider.notifier).goToList();
  }

  Future<void> _handleVoice() => _editor.toggleVoice(
        _bodyController.text,
        languageCode: context.locale.languageCode,
      );

  void _openTagPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TagPickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      noteEditorProvider.select((s) => s.voiceDraft),
      (previous, next) {
        if (!ref.read(noteEditorProvider).recording) return;
        _bodyController.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      },
    );

    final state = ref.watch(noteEditorProvider);
    final isNew = ref.read(notesNavProvider).activeNote == null;
    final body = _bodyController.text;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: MediaQuery.of(context).padding.top + 8.h,
            bottom: 12.h,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: ColorM.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: _back,
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: DirectionalBackIcon(
                    icon: LucideIcons.arrowLeft,
                    size: 22.sp,
                    color: ColorM.primaryAccent,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _openTagPicker,
                  child: state.tags.isEmpty
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.hash,
                              size: 14.sp,
                              color: ColorM.mutedForeground,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'editor.add_tags'.tr(),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontFamily: FontsM.dmSans.name,
                                color: ColorM.mutedForeground,
                              ),
                            ),
                          ],
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: state.tags
                                .take(2)
                                .map(
                                  (tag) => Padding(
                                    padding:
                                        EdgeInsetsDirectional.only(end: 6.w),
                                    child: TagPill(tag: tag),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                ),
              ),
              if (!isNew)
                GestureDetector(
                  onTap: _delete,
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      LucideIcons.trash2,
                      size: 18.sp,
                      color: ColorM.destructive,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  style: context.titleLarge.copyWith(
                    fontWeight: FontWeightM.bold,
                    color: ColorM.foreground,
                  ),
                  decoration: InputDecoration(
                    hintText: 'editor.title_hint'.tr(),
                    hintStyle: context.titleLarge.copyWith(
                      fontWeight: FontWeightM.bold,
                      color: ColorM.mutedForeground,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                SizedBox(height: 12.h),
                if (state.showSummary && state.summary.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: ColorM.accent,
                      borderRadius:
                          BorderRadius.circular(SizeM.buttonBorderRadius.r),
                      border: Border.all(
                        color: ColorM.primaryAccent.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.sparkles,
                                  size: 12.sp,
                                  color: ColorM.primaryAccent,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'editor.ai_summary'.tr(),
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontFamily: FontsM.dmSans.name,
                                    fontWeight: FontWeightM.medium,
                                    letterSpacing: 2,
                                    color: ColorM.primaryAccent,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              state.summary,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: ColorM.accentForeground,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                        PositionedDirectional(
                          top: 0,
                          end: 0,
                          child: GestureDetector(
                            onTap: _editor.dismissSummary,
                            child: Icon(
                              LucideIcons.x,
                              size: 14.sp,
                              color: ColorM.mutedForeground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                TextField(
                  controller: _bodyController,
                  maxLines: null,
                  minLines: 6,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: ColorM.foreground,
                    height: 1.6,
                  ),
                  decoration: InputDecoration(
                    hintText: 'editor.body_hint'.tr(),
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: ColorM.mutedForeground,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: ColorM.background,
            border: Border(
              top: BorderSide(color: ColorM.border, width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _AIActionButton(
                        label: state.loading.contains(AiAction.summarize)
                            ? 'editor.summarizing'.tr()
                            : state.done.contains(AiAction.summarize)
                                ? 'editor.summarized'.tr()
                                : 'editor.summarize'.tr(),
                        icon: state.loading.contains(AiAction.summarize)
                            ? null
                            : state.done.contains(AiAction.summarize)
                                ? LucideIcons.check
                                : LucideIcons.alignLeft,
                        isLoading: state.loading.contains(AiAction.summarize),
                        isDone: state.done.contains(AiAction.summarize),
                        doneColor: ColorM.tagIdeas,
                        enabled:
                            state.loading.isEmpty && body.trim().length >= 20,
                        onTap: () => _editor.runSummarize(body),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _AIActionButton(
                        label: state.loading.contains(AiAction.tag)
                            ? 'editor.tagging'.tr()
                            : state.done.contains(AiAction.tag)
                                ? 'editor.tagged'.tr()
                                : 'editor.autotag'.tr(),
                        icon: state.loading.contains(AiAction.tag)
                            ? null
                            : state.done.contains(AiAction.tag)
                                ? LucideIcons.check
                                : LucideIcons.wand2,
                        isLoading: state.loading.contains(AiAction.tag),
                        isDone: state.done.contains(AiAction.tag),
                        doneColor: ColorM.tagWork,
                        enabled:
                            state.loading.isEmpty && body.trim().length >= 10,
                        onTap: () => _editor.runTag(
                          '$body ${_titleController.text}',
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: _handleVoice,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48.w,
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: state.recording
                              ? ColorM.recordingRed.withValues(alpha: 0.13)
                              : ColorM.primaryAccent,
                          borderRadius:
                              BorderRadius.circular(SizeM.buttonBorderRadius.r),
                          border: state.recording
                              ? Border.all(
                                  color: ColorM.recordingRed
                                      .withValues(alpha: 0.27),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Icon(
                          state.recording ? LucideIcons.micOff : LucideIcons.mic,
                          size: 18.sp,
                          color: state.recording
                              ? ColorM.recordingRed
                              : ColorM.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (state.recording)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: ColorM.recordingRed.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          _PulsingDot(),
                          SizedBox(width: 8.w),
                          Text(
                            'editor.listening'.tr(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontFamily: FontsM.dmSans.name,
                              color: ColorM.recordingRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (state.recording && state.voiceLangMissing)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: ColorM.starYellow.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: ColorM.starYellow.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            LucideIcons.info,
                            size: 14.sp,
                            color: ColorM.starYellow,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'voice.lang_missing'.tr(),
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontFamily: FontsM.dmSans.name,
                                    color: ColorM.foreground,
                                    height: 1.4,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'voice.lang_missing_hint'.tr(),
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontFamily: FontsM.dmSans.name,
                                    color: ColorM.mutedForeground,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

class _AIActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isLoading;
  final bool isDone;
  final Color doneColor;
  final bool enabled;
  final VoidCallback onTap;

  const _AIActionButton({
    required this.label,
    this.icon,
    required this.isLoading,
    required this.isDone,
    required this.doneColor,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44.h,
        decoration: BoxDecoration(
          color: isDone ? doneColor.withValues(alpha: 0.13) : ColorM.accent,
          borderRadius: BorderRadius.circular(SizeM.buttonBorderRadius.r),
          border: Border.all(
            color: isDone ? doneColor.withValues(alpha: 0.27) : ColorM.border,
            width: 1,
          ),
        ),
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.4,
          duration: const Duration(milliseconds: 200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 14.sp,
                  height: 14.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(ColorM.accentForeground),
                  ),
                )
              else if (icon != null)
                Icon(
                  icon,
                  size: 14.sp,
                  color: isDone ? doneColor : ColorM.accentForeground,
                ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: FontsM.dmSans.name,
                  fontWeight: FontWeightM.medium,
                  color: isDone ? doneColor : ColorM.accentForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller.drive(Tween(begin: 0.3, end: 1.0)),
      child: Container(
        width: 8.w,
        height: 8.w,
        decoration: const BoxDecoration(
          color: ColorM.recordingRed,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _TagPickerSheet extends ConsumerWidget {
  const _TagPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected =
        ref.watch(noteEditorProvider).tags.map((t) => t.label).toSet();
    final notifier = ref.read(noteEditorProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: ColorM.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        border: Border.all(color: ColorM.border, width: 1),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: ColorM.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'editor.tags_title'.tr(),
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeightM.bold,
                    color: ColorM.foreground,
                  ),
                ),
                Text(
                  'editor.tags_counter'.tr(
                    namedArgs: {
                      'count': '${selected.length}',
                      'max': '${NoteEditorNotifier.maxTags}',
                    },
                  ),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontFamily: FontsM.dmSans.name,
                    color: ColorM.mutedForeground,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: ColorM.tagColors.entries.map((entry) {
                final label = entry.key;
                final color = entry.value;
                final isSelected = selected.contains(label);
                final atMax = !isSelected &&
                    selected.length >= NoteEditorNotifier.maxTags;
                return GestureDetector(
                  onTap: atMax ? null : () => notifier.toggleTag(label),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: atMax ? 0.35 : 1,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: isSelected ? 0.22 : 0.08),
                        borderRadius: BorderRadius.circular(100.r),
                        border: Border.all(
                          color:
                              color.withValues(alpha: isSelected ? 0.6 : 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? LucideIcons.check : LucideIcons.hash,
                            size: 12.sp,
                            color: color,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            localizedTag(label),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontFamily: FontsM.dmSans.name,
                              fontWeight: FontWeightM.medium,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
