import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebook_ai/core/di/dependency_injection.dart';
import 'package:notebook_ai/features/notes/data/datasources/notes_datasources.dart';
import 'package:notebook_ai/features/notes/data/models/note_model.dart';

class SearchState {
  final String query;
  final List<NoteModel> results;
  final List<NoteModel> recent;
  final bool loading;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.recent = const [],
    this.loading = false,
  });

  bool get isSearching => query.trim().isNotEmpty;

  SearchState copyWith({
    String? query,
    List<NoteModel>? results,
    List<NoteModel>? recent,
    bool? loading,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      recent: recent ?? this.recent,
      loading: loading ?? this.loading,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  NotesDataSource get _ds => DI().notesDataSource;

  @override
  SearchState build() {
    _loadRecent();
    return const SearchState();
  }

  Future<void> _loadRecent() async {
    final recent = await _ds.page(page: 0, limit: 4);
    state = state.copyWith(recent: recent);
  }

  Future<void> search(String query) async {
    final term = query.trim();
    if (term.isEmpty) {
      state = state.copyWith(query: '', results: const [], loading: false);
      return;
    }
    state = state.copyWith(query: query, loading: true);
    final results = await _ds.page(query: term, page: 0, limit: 50);
    if (state.query.trim() != term) return;
    state = state.copyWith(results: results, loading: false);
  }

  Future<void> toggleStar(String id) async {
    await _ds.toggleStar(id);
    if (state.isSearching) {
      await search(state.query);
    } else {
      await _loadRecent();
    }
  }
}

final searchProvider =
    NotifierProvider.autoDispose<SearchNotifier, SearchState>(
  SearchNotifier.new,
);
