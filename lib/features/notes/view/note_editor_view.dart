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
import 'package:notebook_ai/features/notes/data/utils/note_utils.dart';
import 'package:notebook_ai/features/notes/view/widgets/tag_pill.dart';

/// Note editor view matching the Figma design.
///
/// Includes: back button, tag display, delete button, title input,
/// AI summary card (dismissible), body textarea, and AI toolbar
/// (Summarize / Auto-tag / Voice mic).
class NoteEditorView extends ConsumerStatefulWidget {
  const NoteEditorView({super.key});

  @override
  ConsumerState<NoteEditorView> createState() => _NoteEditorViewState();
}

class _NoteEditorViewState extends ConsumerState<NoteEditorView> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  List<AITag> _tags = [];
  String _summary = '';
  bool _showSummary = false;
  bool _recording = false;
  String? _aiLoading; // 'tag' | 'summarize' | null
  String? _aiDone; // 'tag' | 'summarize' | null

  NoteModel? get _note => ref.read(notesNavProvider).activeNote;

  bool get _isNew => _note == null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: _note?.title ?? '');
    _bodyController = TextEditingController(text: _note?.body ?? '');
    _tags = List.of(_note?.tags ?? []);
    _summary = _note?.summary ?? '';
    _showSummary = _summary.isNotEmpty;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final saved = NoteModel(
      id: _note?.id ?? generateId(),
      title: _titleController.text.trim().isEmpty
          ? 'Untitled'
          : _titleController.text.trim(),
      body: _bodyController.text,
      tags: _tags,
      folder: _note?.folder ?? (_tags.isNotEmpty ? _tags.first.label : 'Personal'),
      createdAt: _note?.createdAt ?? DateTime.now(),
      summary: _summary.isEmpty ? null : _summary,
      starred: _note?.starred ?? false,
    );
    ref.read(notesProvider.notifier).saveNote(saved);
  }

  Future<void> _runAI(String action) async {
    setState(() {
      _aiLoading = action;
      _aiDone = null;
    });

    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;

    if (action == 'tag') {
      setState(() {
        _tags = inferTags('${_bodyController.text} ${_titleController.text}');
      });
    } else {
      setState(() {
        _summary = summarize(_bodyController.text);
        _showSummary = true;
      });
    }

    setState(() {
      _aiLoading = null;
      _aiDone = action;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _aiDone = null);
    });
  }

  void _handleVoice() {
    if (_recording) {
      setState(() {
        _recording = false;
        _bodyController.text +=
            '\n[Voice: Whisper transcription would appear here in production]';
      });
    } else {
      setState(() => _recording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header ──
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
              // Back button
              GestureDetector(
                onTap: () {
                  _handleSave();
                  ref.read(notesNavProvider.notifier).goToList();
                },
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    LucideIcons.arrowLeft,
                    size: 22.sp,
                    color: ColorM.primaryAccent,
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // Tags
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _tags
                        .take(2)
                        .map(
                          (tag) => Padding(
                            padding: EdgeInsetsDirectional.only(end: 6.w),
                            child: TagPill(tag: tag),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),

              // Delete button (only when editing)
              if (!_isNew)
                GestureDetector(
                  onTap: () {
                    ref.read(notesProvider.notifier).deleteNote(_note!.id);
                    ref.read(notesNavProvider.notifier).goToList();
                  },
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

        // ── Body ──
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title input
                TextField(
                  controller: _titleController,
                  style: context.titleLarge.copyWith(
                    fontWeight: FontWeightM.bold,
                    color: ColorM.foreground,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Note title…',
                    hintStyle: context.titleLarge.copyWith(
                      fontWeight: FontWeightM.bold,
                      color: ColorM.mutedForeground,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),

                SizedBox(height: 12.h),

                // AI Summary card
                if (_showSummary && _summary.isNotEmpty)
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
                                  'AI SUMMARY',
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
                              _summary,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: ColorM.accentForeground,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _showSummary = false),
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

                // Body textarea
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
                    hintText: 'Start writing… or tap the mic to record.',
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

        // ── AI Toolbar ──
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
                    // Summarize button
                    Expanded(
                      child: _AIActionButton(
                        label: _aiLoading == 'summarize'
                            ? 'Summarizing…'
                            : _aiDone == 'summarize'
                                ? 'Done!'
                                : 'Summarize',
                        icon: _aiLoading == 'summarize'
                            ? null
                            : _aiDone == 'summarize'
                                ? LucideIcons.check
                                : LucideIcons.alignLeft,
                        isLoading: _aiLoading == 'summarize',
                        isDone: _aiDone == 'summarize',
                        doneColor: ColorM.tagIdeas,
                        enabled: _aiLoading == null &&
                            _bodyController.text.trim().length >= 20,
                        onTap: () => _runAI('summarize'),
                      ),
                    ),

                    SizedBox(width: 8.w),

                    // Auto-tag button
                    Expanded(
                      child: _AIActionButton(
                        label: _aiLoading == 'tag'
                            ? 'Tagging…'
                            : _aiDone == 'tag'
                                ? 'Tagged!'
                                : 'Auto-tag',
                        icon: _aiLoading == 'tag'
                            ? null
                            : _aiDone == 'tag'
                                ? LucideIcons.check
                                : LucideIcons.wand2,
                        isLoading: _aiLoading == 'tag',
                        isDone: _aiDone == 'tag',
                        doneColor: ColorM.tagWork,
                        enabled: _aiLoading == null &&
                            _bodyController.text.trim().length >= 10,
                        onTap: () => _runAI('tag'),
                      ),
                    ),

                    SizedBox(width: 8.w),

                    // Voice button
                    GestureDetector(
                      onTap: _handleVoice,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48.w,
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: _recording
                              ? ColorM.recordingRed.withValues(alpha: 0.13)
                              : ColorM.primaryAccent,
                          borderRadius:
                              BorderRadius.circular(SizeM.buttonBorderRadius.r),
                          border: _recording
                              ? Border.all(
                                  color: ColorM.recordingRed
                                      .withValues(alpha: 0.27),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Icon(
                          _recording ? LucideIcons.micOff : LucideIcons.mic,
                          size: 18.sp,
                          color: _recording
                              ? ColorM.recordingRed
                              : ColorM.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),

                // Recording indicator
                if (_recording)
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
                            'Recording… tap mic to stop',
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── AI Action Button ─────────────────────────────────────────────────────────

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
          color: isDone
              ? doneColor.withValues(alpha: 0.13)
              : ColorM.accent,
          borderRadius: BorderRadius.circular(SizeM.buttonBorderRadius.r),
          border: Border.all(
            color: isDone
                ? doneColor.withValues(alpha: 0.27)
                : ColorM.border,
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

// ─── Pulsing Recording Dot ────────────────────────────────────────────────────

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
