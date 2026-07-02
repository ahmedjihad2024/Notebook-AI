import 'package:isar_community/isar.dart';
import 'package:notebook_ai/features/notes/data/models/note_model.dart';

part 'note.g.dart';

@collection
class Note {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String noteId;

  late String title;
  late String body;

  @Index(type: IndexType.value, caseSensitive: false)
  late List<String> tagLabels;

  late String folder;

  @Index()
  late DateTime createdAt;

  String? summary;

  @Index(composite: [CompositeIndex('createdAt')])
  late bool starred;

  Note();

  factory Note.fromModel(NoteModel model) => Note()
    ..noteId = model.id
    ..title = model.title
    ..body = model.body
    ..tagLabels = model.tags.map((t) => t.label).toList()
    ..folder = model.folder
    ..createdAt = model.createdAt
    ..summary = model.summary
    ..starred = model.starred;

  NoteModel toModel() => NoteModel(
        id: noteId,
        title: title,
        body: body,
        tags: tagLabels.map(AITag.fromLabel).toList(),
        folder: folder,
        createdAt: createdAt,
        summary: summary,
        starred: starred,
      );
}
