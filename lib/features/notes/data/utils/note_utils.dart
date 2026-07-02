import 'package:intl/intl.dart';
import 'package:notebook_ai/core/res/color_manager.dart';
import 'package:notebook_ai/features/notes/data/models/note_model.dart';

// ─── Time Ago ─────────────────────────────────────────────────────────────────

String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  final days = diff.inDays;
  if (days == 0) return 'Today';
  if (days == 1) return 'Yesterday';
  if (days < 7) return '$days days ago';
  // Same year → "15 Jun"; different year → "15 Jun 2025".
  final pattern = date.year == DateTime.now().year ? 'd MMM' : 'd MMM y';
  return DateFormat(pattern).format(date);
}

// ─── Infer Tags ───────────────────────────────────────────────────────────────

List<AITag> inferTags(String text) {
  final lower = text.toLowerCase();
  final matches = <String>[];

  if (RegExp(r'meeting|deadline|sprint|launch|ship|stakeholder|roadmap')
      .hasMatch(lower)) {
    matches.add('Work');
  }
  if (RegExp(r'idea|concept|what if|imagine|prototype|could be')
      .hasMatch(lower)) {
    matches.add('Ideas');
  }
  if (RegExp(r'family|friend|personal|diary|feeling|journal')
      .hasMatch(lower)) {
    matches.add('Personal');
  }
  if (RegExp(r'study|paper|research|analysis|data|source').hasMatch(lower)) {
    matches.add('Research');
  }
  if (RegExp(r'buy|shop|store|order|cart|price').hasMatch(lower)) {
    matches.add('Shopping');
  }
  if (RegExp(r'health|gym|workout|diet|meal|nutrition|sleep')
      .hasMatch(lower)) {
    matches.add('Health');
  }
  if (RegExp(r'trip|travel|flight|hotel|airbnb|city|country')
      .hasMatch(lower)) {
    matches.add('Travel');
  }
  if (RegExp(r'budget|expense|income|saving|invoice|tax|money')
      .hasMatch(lower)) {
    matches.add('Finance');
  }
  if (RegExp(r'book|read|chapter|author|novel|page').hasMatch(lower)) {
    matches.add('Reading');
  }
  if (RegExp(r'code|coding|programming|bug|api|function|deploy|git|server|database')
      .hasMatch(lower)) {
    matches.add('Coding');
  }
  if (RegExp(r'recipe|cook|restaurant|cuisine|dish|dinner|breakfast')
      .hasMatch(lower)) {
    matches.add('Food');
  }
  if (RegExp(r'music|song|album|playlist|guitar|piano|lyrics|band')
      .hasMatch(lower)) {
    matches.add('Music');
  }
  if (RegExp(r'movie|film|series|episode|cinema|show|watchlist')
      .hasMatch(lower)) {
    matches.add('Movies');
  }
  if (RegExp(r'learn|course|tutorial|lesson|skill|practice|class')
      .hasMatch(lower)) {
    matches.add('Learning');
  }
  if (RegExp(r'goal|resolution|target|milestone|objective|habit')
      .hasMatch(lower)) {
    matches.add('Goals');
  }
  if (RegExp(r'event|party|birthday|wedding|celebration|meetup|conference')
      .hasMatch(lower)) {
    matches.add('Events');
  }
  if (RegExp(r'quote|saying|wisdom|inspiration|motivat').hasMatch(lower)) {
    matches.add('Quotes');
  }
  if (RegExp(r'project|task|todo|feature|backlog|milestone').hasMatch(lower)) {
    matches.add('Projects');
  }

  if (matches.isEmpty) matches.add('Personal');

  return matches.take(3).map((label) => AITag.fromLabel(label)).toList();
}

// ─── Summarize ────────────────────────────────────────────────────────────────

String summarize(String text) {
  final sentences = text
      .split(RegExp(r'[.!?\n]+'))
      .map((s) => s.trim())
      .where((s) => s.length > 20)
      .toList();

  if (sentences.length <= 2) {
    return text.length > 120 ? '${text.substring(0, 120)}…' : text;
  }
  return '${sentences.take(2).join('. ')}.';
}

// ─── Generate ID ──────────────────────────────────────────────────────────────

String generateId() {
  return DateTime.now().millisecondsSinceEpoch.toRadixString(36) +
      (DateTime.now().microsecond).toRadixString(36);
}

// ─── Folders ──────────────────────────────────────────────────────────────────

/// Special folder that collects notes with no tags.
const String kOthersFolder = 'Others';

/// One folder per tag — derived from [ColorM.tagColors] so the Folders grid
/// and the Search "Browse by tag" cloud always stay in sync (every tag has a
/// folder, and vice-versa).
List<String> get kFolders => ColorM.tagColors.keys.toList();

List<String> get gridFolders => [kOthersFolder, ...kFolders];
