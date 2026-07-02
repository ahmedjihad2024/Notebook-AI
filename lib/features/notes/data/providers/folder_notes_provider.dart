import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebook_ai/core/di/dependency_injection.dart';
import 'package:notebook_ai/features/notes/data/datasources/notes_datasources.dart';
import 'package:notebook_ai/features/notes/data/models/note_model.dart';
import 'package:notebook_ai/features/notes/data/providers/navigation_provider.dart';

class PagedNotes {
  final List<NoteModel> items;
  final int total;
  final int page;
  final bool hasMore;
  final bool loading;

  const PagedNotes({
    this.items = const [],
    this.total = 0,
    this.page = 0,
    this.hasMore = true,
    this.loading = true,
  });

  PagedNotes copyWith({
    List<NoteModel>? items,
    int? total,
    int? page,
    bool? hasMore,
    bool? loading,
  }) {
    return PagedNotes(
      items: items ?? this.items,
      total: total ?? this.total,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loading: loading ?? this.loading,
    );
  }
}

class FolderNotesNotifier extends Notifier<PagedNotes> {
  static const _limit = 15;

  NotesDataSource get _ds => DI().notesDataSource;

  String get _folder => ref.read(notesNavProvider).activeFolder;

  @override
  PagedNotes build() {
    loadFirst();
    return const PagedNotes();
  }

  Future<void> loadFirst() async {
    final items = await _ds.page(folder: _folder, page: 0, limit: _limit);
    final total = await _ds.countFolder(_folder);
    state = PagedNotes(
      items: items,
      total: total,
      page: 0,
      hasMore: items.length == _limit,
      loading: false,
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.loading) return;
    final next = state.page + 1;
    final more = await _ds.page(folder: _folder, page: next, limit: _limit);
    state = state.copyWith(
      items: [...state.items, ...more],
      page: next,
      hasMore: more.length == _limit,
    );
  }

  Future<void> refresh() => loadFirst();

  Future<void> toggleStar(String id) async {
    await _ds.toggleStar(id);
    await loadFirst();
  }
}

final folderNotesProvider =
    NotifierProvider.autoDispose<FolderNotesNotifier, PagedNotes>(
  FolderNotesNotifier.new,
);
