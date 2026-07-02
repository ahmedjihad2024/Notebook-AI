import 'package:riverpod/riverpod.dart';
import 'package:notebook_ai/features/notes/data/models/note_model.dart';

// ─── View Enum ────────────────────────────────────────────────────────────────

enum NotesView { list, editor, folders, search, folderDetail }

// ─── Navigation State ─────────────────────────────────────────────────────────

class NotesNavState {
  final NotesView view;
  final NoteModel? activeNote;
  final String activeFolder;

  const NotesNavState({
    this.view = NotesView.list,
    this.activeNote,
    this.activeFolder = '',
  });

  NotesNavState copyWith({
    NotesView? view,
    NoteModel? activeNote,
    String? activeFolder,
    bool clearActiveNote = false,
  }) {
    return NotesNavState(
      view: view ?? this.view,
      activeNote: clearActiveNote ? null : (activeNote ?? this.activeNote),
      activeFolder: activeFolder ?? this.activeFolder,
    );
  }
}

// ─── Navigation Notifier ──────────────────────────────────────────────────────

class NotesNavNotifier extends Notifier<NotesNavState> {
  @override
  NotesNavState build() => const NotesNavState();

  void goToList() {
    state = state.copyWith(view: NotesView.list, clearActiveNote: true);
  }

  void openNote(NoteModel note) {
    state = state.copyWith(view: NotesView.editor, activeNote: note);
  }

  void openNewNote() {
    state = state.copyWith(view: NotesView.editor, clearActiveNote: true);
  }

  void goToFolders() {
    state = state.copyWith(view: NotesView.folders);
  }

  void openFolder(String folderName) {
    state = state.copyWith(
      view: NotesView.folderDetail,
      activeFolder: folderName,
    );
  }

  void goToSearch() {
    state = state.copyWith(view: NotesView.search);
  }

  void navigateTo(NotesView view) {
    state = state.copyWith(view: view);
  }
}

final notesNavProvider =
    NotifierProvider<NotesNavNotifier, NotesNavState>(NotesNavNotifier.new);
