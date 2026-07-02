import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:notebook_ai/features/notes/data/entities/note.dart';
import 'package:notebook_ai/features/notes/data/models/note_model.dart';
import 'package:notebook_ai/features/notes/data/utils/note_utils.dart';

const String kAllFolder = '__all__';

class NotesDataSource {
  final Isar _isar;

  NotesDataSource(this._isar);

  static Future<Isar> openIsar() async {
    final existing = Isar.getInstance();
    if (existing != null) return existing;
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open([NoteSchema], directory: dir.path);
  }

  Future<List<NoteModel>> page({
    int page = 0,
    int limit = 20,
    String? folder,
    String? query,
    bool? starred,
  }) async {
    final term = query?.trim() ?? '';
    final results = await _isar.notes
        .filter()
        .optional(starred != null, (q) => q.starredEqualTo(starred ?? false))
        .optional(
          folder != null && folder != kAllFolder,
          (q) => folder == kOthersFolder
              ? q.tagLabelsIsEmpty()
              : q.tagLabelsElementEqualTo(folder!, caseSensitive: false),
        )
        .optional(
          term.isNotEmpty,
          (q) => q.group(
            (g) => g
                .titleContains(term, caseSensitive: false)
                .or()
                .bodyContains(term, caseSensitive: false)
                .or()
                .tagLabelsElementContains(term, caseSensitive: false)
                .or()
                .summaryContains(term, caseSensitive: false),
          ),
        )
        .sortByCreatedAtDesc()
        .offset(page * limit)
        .limit(limit)
        .findAll();
    return results.map((e) => e.toModel()).toList();
  }

  Future<List<NoteModel>> getAll() async {
    final results = await _isar.notes.where().findAll();
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results.map((e) => e.toModel()).toList();
  }

  Future<int> countAll() => _isar.notes.count();

  Future<int> countFolder(String folder) {
    if (folder == kAllFolder) return _isar.notes.count();
    if (folder == kOthersFolder) {
      return _isar.notes.filter().tagLabelsIsEmpty().count();
    }
    return _isar.notes
        .filter()
        .tagLabelsElementEqualTo(folder, caseSensitive: false)
        .count();
  }

  Future<void> save(NoteModel note) async {
    await _isar.writeTxn(() => _isar.notes.putByNoteId(Note.fromModel(note)));
  }

  Future<void> delete(String noteId) async {
    await _isar.writeTxn(() => _isar.notes.deleteByNoteId(noteId));
  }

  Future<void> toggleStar(String noteId) async {
    await _isar.writeTxn(() async {
      final entity = await _isar.notes.getByNoteId(noteId);
      if (entity == null) return;
      entity.starred = !entity.starred;
      await _isar.notes.putByNoteId(entity);
    });
  }

  Future<void> seedIfEmpty(List<NoteModel> seed) async {
    if (await _isar.notes.count() > 0) return;
    await _isar.writeTxn(
      () => _isar.notes.putAll(seed.map(Note.fromModel).toList()),
    );
  }

  Stream<void> watchLazy() => _isar.notes.watchLazy();
}
