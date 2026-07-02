import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebook_ai/core/di/dependency_injection.dart';
import 'package:notebook_ai/core/res/color_manager.dart';
import 'package:notebook_ai/features/notes/data/datasources/notes_datasources.dart';
import 'package:notebook_ai/features/notes/data/models/note_model.dart';
import 'package:notebook_ai/features/notes/data/providers/navigation_provider.dart';
import 'package:notebook_ai/features/notes/data/utils/note_utils.dart';

class EditorState {
  final List<AITag> tags;
  final String summary;
  final bool showSummary;
  final bool recording;
  final String? aiLoading;
  final String? aiDone;

  const EditorState({
    this.tags = const [],
    this.summary = '',
    this.showSummary = false,
    this.recording = false,
    this.aiLoading,
    this.aiDone,
  });

  static const Object _keep = Object();

  EditorState copyWith({
    List<AITag>? tags,
    String? summary,
    bool? showSummary,
    bool? recording,
    Object? aiLoading = _keep,
    Object? aiDone = _keep,
  }) {
    return EditorState(
      tags: tags ?? this.tags,
      summary: summary ?? this.summary,
      showSummary: showSummary ?? this.showSummary,
      recording: recording ?? this.recording,
      aiLoading: aiLoading == _keep ? this.aiLoading : aiLoading as String?,
      aiDone: aiDone == _keep ? this.aiDone : aiDone as String?,
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
    state = state.copyWith(aiLoading: 'summarize', aiDone: null);
    String result;
    try {
      final summary = await DI().ai.summarize(body);
      result = summary.isEmpty ? summarize(body) : summary;
    } catch (_) {
      result = summarize(body);
    }
    if (_disposed) return;
    state = state.copyWith(
      summary: result,
      showSummary: true,
      aiLoading: null,
      aiDone: 'summarize',
    );
    _clearDoneLater('summarize');
  }

  Future<void> runTag(String text) async {
    state = state.copyWith(aiLoading: 'tag', aiDone: null);
    List<AITag> result;
    try {
      final labels =
          await DI().ai.classifyTags(text, ColorM.tagColors.keys.toList());
      result = labels.isEmpty
          ? inferTags(text)
          : labels.map(AITag.fromLabel).toList();
    } catch (_) {
      result = inferTags(text);
    }
    if (_disposed) return;
    state = state.copyWith(
      tags: result,
      aiLoading: null,
      aiDone: 'tag',
    );
    _clearDoneLater('tag');
  }

  void _clearDoneLater(String action) {
    Future.delayed(const Duration(seconds: 2), () {
      if (_disposed) return;
      if (state.aiDone == action) state = state.copyWith(aiDone: null);
    });
  }

  void dismissSummary() => state = state.copyWith(showSummary: false);

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
