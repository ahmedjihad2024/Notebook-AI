import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebook_ai/core/res/color_manager.dart';
import 'package:notebook_ai/features/notes/data/providers/navigation_provider.dart';
import 'package:notebook_ai/features/notes/view/folder_detail_view.dart';
import 'package:notebook_ai/features/notes/view/folders_view.dart';
import 'package:notebook_ai/features/notes/view/note_editor_view.dart';
import 'package:notebook_ai/features/notes/view/notes_list_view.dart';
import 'package:notebook_ai/features/notes/view/search_view.dart';
import 'package:notebook_ai/features/notes/view/widgets/bottom_nav_bar.dart';

/// Main shell for the notes feature.
///
/// Manages view switching between list, editor, folders, folder detail,
/// and search. Shows bottom nav on all views except the editor.
class NotesShellView extends ConsumerWidget {
  const NotesShellView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(notesNavProvider);
    final nav = ref.read(notesNavProvider.notifier);

    return Scaffold(
      backgroundColor: ColorM.background,
      body: Stack(
        children: [
          // ── View Content ──
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _buildView(navState.view),
            ),
          ),

          // ── Bottom Nav (hidden in editor) ──
          if (navState.view != NotesView.editor)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: NotesBottomNavBar(
                currentView: navState.view,
                onNav: (target) {
                  switch (target) {
                    case NotesView.list:
                      nav.goToList();
                    case NotesView.folders:
                      nav.goToFolders();
                    case NotesView.search:
                      nav.goToSearch();
                    default:
                      break;
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildView(NotesView view) {
    return switch (view) {
      NotesView.list => const NotesListView(key: ValueKey('list')),
      NotesView.editor => const NoteEditorView(key: ValueKey('editor')),
      NotesView.folders => const FoldersView(key: ValueKey('folders')),
      NotesView.folderDetail =>
        const FolderDetailView(key: ValueKey('folderDetail')),
      NotesView.search => const SearchView(key: ValueKey('search')),
    };
  }
}
