import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebook_ai/core/di/dependency_injection.dart';
import 'package:notebook_ai/features/notes/data/datasources/notes_datasources.dart';
import 'package:notebook_ai/features/notes/data/utils/note_utils.dart';

class FoldersState {
  final Map<String, int> counts;
  final int total;
  final bool loading;

  const FoldersState({
    this.counts = const {},
    this.total = 0,
    this.loading = true,
  });

  int countOf(String folder) => counts[folder] ?? 0;

  FoldersState copyWith({
    Map<String, int>? counts,
    int? total,
    bool? loading,
  }) {
    return FoldersState(
      counts: counts ?? this.counts,
      total: total ?? this.total,
      loading: loading ?? this.loading,
    );
  }
}

class FoldersNotifier extends Notifier<FoldersState> {
  NotesDataSource get _ds => DI().notesDataSource;

  @override
  FoldersState build() {
    _load();
    return const FoldersState();
  }

  Future<void> _load() async {
    final counts = <String, int>{};
    for (final folder in gridFolders) {
      counts[folder] = await _ds.countFolder(folder);
    }
    final total = await _ds.countAll();
    state = FoldersState(counts: counts, total: total, loading: false);
  }

  Future<void> refresh() => _load();
}

final foldersProvider =
    NotifierProvider.autoDispose<FoldersNotifier, FoldersState>(
  FoldersNotifier.new,
);
