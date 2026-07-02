import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebook_ai/core/di/dependency_injection.dart';
import 'package:notebook_ai/core/res/color_manager.dart';
import 'package:notebook_ai/core/services/ai/ai_service.dart';
import 'package:notebook_ai/core/utils/logger/app_logger.dart';
import 'package:notebook_ai/features/notes/data/datasources/notes_datasources.dart';
import 'package:notebook_ai/features/notes/data/models/note_model.dart';
import 'package:notebook_ai/features/notes/data/providers/navigation_provider.dart';
import 'package:notebook_ai/features/notes/data/utils/note_utils.dart';
import 'package:notebook_ai/core/utils/snackbar_helper.dart';

enum AiAction { tag, summarize }

class EditorState {
  final List<AITag> tags;
  final String summary;
  final bool showSummary;
  final bool recording;
  final Set<AiAction> loading;
  final Set<AiAction> done;

  const EditorState({
    this.tags = const [],
    this.summary = '',
    this.showSummary = false,
    this.recording = false,
    this.loading = const {},
    this.done = const {},
  });

  EditorState copyWith({
    List<AITag>? tags,
    String? summary,
    bool? showSummary,
    bool? recording,
    Set<AiAction>? loading,
    Set<AiAction>? done,
  }) {
    return EditorState(
      tags: tags ?? this.tags,
      summary: summary ?? this.summary,
      showSummary: showSummary ?? this.showSummary,
      recording: recording ?? this.recording,
      loading: loading ?? this.loading,
      done: done ?? this.done,
    );
  }
}

class NoteEditorNotifier extends Notifier<EditorState> {
  NotesDataSource get _ds => DI().notesDataSource;

  bool _disposed = false;

  NoteModel? get _note => ref.read(notesNavProvider).activeNote;

  @override
  EditorState build() {
    ref.onDispose(() => _disposed = true);
    final note = _note;
    return EditorState(
      tags: List.of(note?.tags ?? const []),
      summary: note?.summary ?? '',
      showSummary: (note?.summary ?? '').isNotEmpty,
    );
  }

  Future<void> runSummarize(String body) async {
    state = state.copyWith(
      loading: {...state.loading, AiAction.summarize},
      done: state.done.difference({AiAction.summarize}),
    );
    try {
      final summary = await DI().ai.summarize(body);
      if (_disposed) return;
      state = state.copyWith(
        summary: summary,
        showSummary: true,
        loading: state.loading.difference({AiAction.summarize}),
        done: {...state.done, AiAction.summarize},
      );
      _clearDoneLater(AiAction.summarize);
    } catch (error, stack) {
      _handleAiError(AiAction.summarize, error, stack, 'summarize this note');
    }
  }

  Future<void> runTag(String text) async {
    state = state.copyWith(
      loading: {...state.loading, AiAction.tag},
      done: state.done.difference({AiAction.tag}),
    );
    try {
      final labels =
          await DI().ai.classifyTags(text, ColorM.tagColors.keys.toList());
      if (_disposed) return;
      state = state.copyWith(
        tags: labels.map(AITag.fromLabel).toList(),
        loading: state.loading.difference({AiAction.tag}),
        done: {...state.done, AiAction.tag},
      );
      _clearDoneLater(AiAction.tag);
    } catch (error, stack) {
      _handleAiError(AiAction.tag, error, stack, 'auto-tag this note');
    }
  }

  void _handleAiError(
    AiAction action,
    Object error,
    StackTrace stack,
    String fallbackAction,
  ) {
    AppLogger.instance.e(error, stackTrace: stack);
    if (_disposed) return;
    state = state.copyWith(loading: state.loading.difference({action}));
    final message = error is AiException
        ? error.message
        : 'Couldn\'t $fallbackAction. Please try again.';
    DI().snackBarHelper.showMessage(
          message,
          ErrorMessage.snackBar,
          isError: true,
        );
  }

  void _clearDoneLater(AiAction action) {
    Future.delayed(const Duration(seconds: 2), () {
      if (_disposed) return;
      if (state.done.contains(action)) {
        state = state.copyWith(done: state.done.difference({action}));
      }
    });
  }

  static const int maxTags = 2;

  void toggleTag(String label) {
    final selected = state.tags.any((t) => t.label == label);
    if (selected) {
      state = state.copyWith(
        tags: state.tags.where((t) => t.label != label).toList(),
      );
    } else if (state.tags.length < maxTags) {
      state = state.copyWith(tags: [...state.tags, AITag.fromLabel(label)]);
    }
  }

  void dismissSummary() =>
      state = state.copyWith(summary: '', showSummary: false);

  String? toggleVoice() {
    if (state.recording) {
      state = state.copyWith(recording: false);
      return '\n[Voice: Whisper transcription would appear here in production]';
    }
    state = state.copyWith(recording: true);
    return null;
  }

  Future<void> save({required String title, required String body}) async {
    final note = _note;
    final saved = NoteModel(
      id: note?.id ?? generateId(),
      title: title.trim().isEmpty ? 'Untitled' : title.trim(),
      body: body,
      tags: state.tags,
      folder: note?.folder ??
          (state.tags.isNotEmpty ? state.tags.first.label : 'Personal'),
      createdAt: note?.createdAt ?? DateTime.now(),
      summary: state.summary.isEmpty ? null : state.summary,
      starred: note?.starred ?? false,
    );
    await _ds.save(saved);
  }

  Future<void> delete() async {
    final note = _note;
    if (note != null) await _ds.delete(note.id);
  }
}

final noteEditorProvider =
    NotifierProvider.autoDispose<NoteEditorNotifier, EditorState>(
  NoteEditorNotifier.new,
);
