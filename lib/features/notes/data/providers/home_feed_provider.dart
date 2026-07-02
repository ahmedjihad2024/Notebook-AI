import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebook_ai/core/di/dependency_injection.dart';
import 'package:notebook_ai/features/notes/data/datasources/notes_datasources.dart';
import 'package:notebook_ai/features/notes/data/models/note_model.dart';

class HomeFeed {
  final List<NoteModel> starred;
  final List<NoteModel> recent;
  final int total;
  final int page;
  final bool hasMore;
  final bool loading;

  const HomeFeed({
    this.starred = const [],
    this.recent = const [],
    this.total = 0,
    this.page = 0,
    this.hasMore = true,
    this.loading = true,
  });

  HomeFeed copyWith({
    List<NoteModel>? starred,
    List<NoteModel>? recent,
    int? total,
    int? page,
    bool? hasMore,
    bool? loading,
  }) {
    return HomeFeed(
      starred: starred ?? this.starred,
      recent: recent ?? this.recent,
      total: total ?? this.total,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loading: loading ?? this.loading,
    );
  }
}

class HomeFeedNotifier extends Notifier<HomeFeed> {
  static const _limit = 15;

  NotesDataSource get _ds => DI().notesDataSource;

  @override
  HomeFeed build() {
    loadFirst();
    return const HomeFeed();
  }

  Future<void> loadFirst() async {
    final starred = await _ds.page(starred: true, page: 0, limit: 100);
    final recent = await _ds.page(starred: false, page: 0, limit: _limit);
    final total = await _ds.countAll();
    state = HomeFeed(
      starred: starred,
      recent: recent,
      total: total,
      page: 0,
      hasMore: recent.length == _limit,
      loading: false,
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.loading) return;
    final next = state.page + 1;
    final more = await _ds.page(starred: false, page: next, limit: _limit);
    state = state.copyWith(
      recent: [...state.recent, ...more],
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

final homeFeedProvider =
    NotifierProvider.autoDispose<HomeFeedNotifier, HomeFeed>(
  HomeFeedNotifier.new,
);
