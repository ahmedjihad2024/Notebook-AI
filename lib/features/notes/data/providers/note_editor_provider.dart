import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
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
  final String voiceDraft;
  final bool voiceLangMissing;
  final Set<AiAction> loading;
  final Set<AiAction> done;

  const EditorState({
    this.tags = const [],
    this.summary = '',
    this.showSummary = false,
    this.recording = false,
    this.voiceDraft = '',
    this.voiceLangMissing = false,
    this.loading = const {},
    this.done = const {},
  });

  EditorState copyWith({
    List<AITag>? tags,
    String? summary,
    bool? showSummary,
    bool? recording,
    String? voiceDraft,
    bool? voiceLangMissing,
    Set<AiAction>? loading,
    Set<AiAction>? done,
  }) {
    return EditorState(
      tags: tags ?? this.tags,
      summary: summary ?? this.summary,
      showSummary: showSummary ?? this.showSummary,
      recording: recording ?? this.recording,
      voiceDraft: voiceDraft ?? this.voiceDraft,
      voiceLangMissing: voiceLangMissing ?? this.voiceLangMissing,
      loading: loading ?? this.loading,
      done: done ?? this.done,
    );
  }
}

class NoteEditorNotifier extends Notifier<EditorState> {
  NotesDataSource get _ds => DI().notesDataSource;

  final SpeechToText _speech = SpeechToText();
  String _baseBody = '';
  bool _speechReady = false;
  List<LocaleName>? _locales;

  bool _disposed = false;

  NoteModel? get _note => ref.read(notesNavProvider).activeNote;

  @override
  EditorState build() {
    ref.onDispose(() {
      _disposed = true;
      if (_speechReady) _speech.cancel();
    });
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
      _handleAiError(AiAction.summarize, error, stack);
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
      _handleAiError(AiAction.tag, error, stack);
    }
  }

  void _handleAiError(AiAction action, Object error, StackTrace stack) {
    AppLogger.instance.e(error, stackTrace: stack);
    if (_disposed) return;
    state = state.copyWith(loading: state.loading.difference({action}));
    DI().snackBarHelper.showMessage(
          _aiErrorMessage(error),
          ErrorMessage.snackBar,
          isError: true,
        );
  }

  String _aiErrorMessage(Object error) {
    if (error is! AiException) return 'ai_errors.unknown'.tr();
    final key = switch (error.kind) {
      AiErrorKind.notConfigured => 'not_configured',
      AiErrorKind.network => 'network',
      AiErrorKind.timeout => 'timeout',
      AiErrorKind.auth => 'auth',
      AiErrorKind.permission => 'permission',
      AiErrorKind.rateLimit => 'rate_limit',
      AiErrorKind.overloaded => 'overloaded',
      AiErrorKind.server => 'server',
      AiErrorKind.invalidRequest => 'invalid_request',
      AiErrorKind.empty => 'empty',
      AiErrorKind.unknown => 'unknown',
    };
    return 'ai_errors.$key'.tr();
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

  Future<void> toggleVoice(String currentBody, {String? languageCode}) async {
    if (state.recording) {
      await _speech.stop();
      if (_disposed) return;
      state = state.copyWith(recording: false, voiceLangMissing: false);
      return;
    }
    final available = _speechReady || await _initSpeech();
    if (_disposed) return;
    if (!available) {
      _showVoiceError('voice.unavailable'.tr());
      return;
    }
    final localeId = await _resolveLocaleId(languageCode);
    if (_disposed) return;
    final langMissing = languageCode != null &&
        localeId == null &&
        (_locales?.isNotEmpty ?? false);
    _baseBody = currentBody;
    state = state.copyWith(
      recording: true,
      voiceDraft: currentBody,
      voiceLangMissing: langMissing,
    );
    await _speech.listen(
      onResult: _onSpeechResult,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        autoPunctuation: true,
        listenMode: ListenMode.dictation,
        localeId: localeId,
      ),
    );
  }

  Future<String?> _resolveLocaleId(String? languageCode) async {
    if (languageCode == null) return null;
    try {
      if (_locales == null || _locales!.isEmpty) {
        _locales = await _speech.locales();
      }
      final code = languageCode.toLowerCase();
      for (final locale in _locales!) {
        final id = locale.localeId.toLowerCase().replaceAll('_', '-');
        if (id == code || id.startsWith('$code-')) {
          return locale.localeId;
        }
      }
      AppLogger.instance.w(
        'No speech locale for "$code". Available: '
        '${_locales!.map((l) => l.localeId).join(', ')}',
      );
    } catch (error, stack) {
      AppLogger.instance.e(error, stackTrace: stack);
    }
    return null;
  }

  Future<bool> _initSpeech() async {
    try {
      _speechReady = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );
      return _speechReady;
    } catch (error, stack) {
      AppLogger.instance.e(error, stackTrace: stack);
      return false;
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (_disposed) return;
    final words = result.recognizedWords;
    final composed = _baseBody.isEmpty
        ? words
        : words.isEmpty
            ? _baseBody
            : '$_baseBody\n$words';
    state = state.copyWith(voiceDraft: composed);
  }

  void _onSpeechStatus(String status) {
    if (_disposed) return;
    final ended = status == SpeechToText.notListeningStatus ||
        status == SpeechToText.doneStatus;
    if (ended && state.recording) {
      state = state.copyWith(recording: false);
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    AppLogger.instance.e(error.errorMsg);
    if (_disposed) return;
    if (state.recording) state = state.copyWith(recording: false);
    _showVoiceError('voice.failed'.tr());
  }

  void _showVoiceError(String message) {
    DI().snackBarHelper.showMessage(
          message,
          ErrorMessage.snackBar,
          isError: true,
        );
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
