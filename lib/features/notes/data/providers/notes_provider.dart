import 'package:riverpod/riverpod.dart';
import 'package:notebook_ai/features/notes/data/models/note_model.dart';

// ─── Seed Data ────────────────────────────────────────────────────────────────

final _seedNotes = <NoteModel>[
  NoteModel(
    id: '1',
    title: 'Q3 Product Roadmap',
    body:
        'We need to ship the voice input feature by end of July. The AI summarization pipeline should be ready in August. Key stakeholders: design team, backend, and mobile. Budget approved for compute costs. Focus on latency under 200ms for tag inference.',
    tags: [AITag.fromLabel('Work'), AITag.fromLabel('Research')],
    folder: 'Work',
    createdAt: DateTime(2026, 6, 28),
    summary:
        'Roadmap targets: voice input July, AI summary August. Latency goal <200ms.',
    starred: true,
  ),
  NoteModel(
    id: '2',
    title: 'Book list — summer reading',
    body:
        'Thinking Machines by Luke Dormehl\nThe Design of Everyday Things — Don Norman\nProject Hail Mary — Andy Weir\nFour Thousand Weeks — Oliver Burkeman\nAlready picked up Piranesi from the shelf.',
    tags: [AITag.fromLabel('Reading'), AITag.fromLabel('Personal')],
    folder: 'Personal',
    createdAt: DateTime(2026, 6, 25),
    summary: '5-book reading list spanning design, sci-fi, and philosophy.',
    starred: false,
  ),
  NoteModel(
    id: '3',
    title: 'Meal prep — this week',
    body:
        'Monday: grilled salmon + quinoa\nTuesday: lentil soup batch\nWednesday: chicken stir-fry with bok choy\nThursday: leftovers\nFriday: pasta arrabiata\nBuy: olive oil, tahini, chickpeas, greek yogurt',
    tags: [AITag.fromLabel('Health'), AITag.fromLabel('Shopping')],
    folder: 'Health',
    createdAt: DateTime(2026, 6, 30),
    summary: 'Weekly meal plan with grocery list. 5 dinners planned.',
    starred: false,
  ),
  NoteModel(
    id: '4',
    title: 'Lisbon trip notes',
    body:
        'Flight: TAP Air Portugal, June 15. Airbnb in Alfama neighborhood. Must visit: LX Factory, Pastéis de Belém, Sintra castle. Take the 28 tram. Budget: ~€1,200 total. Check local SIM options at the airport.',
    tags: [AITag.fromLabel('Travel'), AITag.fromLabel('Personal')],
    folder: 'Travel',
    createdAt: DateTime(2026, 6, 20),
    summary: 'Lisbon trip: Alfama base, tram 28, Sintra, €1.2k budget.',
    starred: true,
  ),
  NoteModel(
    id: '5',
    title: 'App ideas — notes + AI',
    body:
        'What if the note-taking app could detect emotional tone and suggest journaling prompts? Could use embedding similarity to cluster notes automatically. Real-time transcription via Whisper. Offline-first architecture with sync on reconnect.',
    tags: [AITag.fromLabel('Ideas'), AITag.fromLabel('Work')],
    folder: 'Ideas',
    createdAt: DateTime(2026, 7, 1),
    summary:
        'AI notes app ideas: tone detection, auto-clustering, Whisper transcription, offline-first.',
    starred: false,
  ),
  NoteModel(
    id: '6',
    title: 'Monthly budget review',
    body:
        'Income: €4,200. Fixed: rent €1,100, subscriptions €48, insurance €90. Variable: food €280, transport €65, dining out €190. Savings target: €800. Remaining discretionary: ~€627. Cut Netflix duplicate, downgrade gym plan.',
    tags: [AITag.fromLabel('Finance'), AITag.fromLabel('Personal')],
    folder: 'Finance',
    createdAt: DateTime(2026, 6, 15),
    summary:
        'Monthly budget: €4.2k income, €800 savings target, €627 discretionary.',
    starred: false,
  ),
];

// ─── Notes Notifier ───────────────────────────────────────────────────────────

class NotesNotifier extends Notifier<List<NoteModel>> {
  @override
  List<NoteModel> build() => List.of(_seedNotes);

  void addNote(NoteModel note) {
    state = [note, ...state];
  }

  void updateNote(NoteModel note) {
    state = [
      for (final n in state)
        if (n.id == note.id) note else n,
    ];
  }

  void saveNote(NoteModel note) {
    final idx = state.indexWhere((n) => n.id == note.id);
    if (idx >= 0) {
      updateNote(note);
    } else {
      addNote(note);
    }
  }

  void deleteNote(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  void toggleStar(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(starred: !n.starred) else n,
    ];
  }
}

final notesProvider =
    NotifierProvider<NotesNotifier, List<NoteModel>>(NotesNotifier.new);
