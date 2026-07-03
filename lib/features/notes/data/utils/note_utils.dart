import 'package:easy_localization/easy_localization.dart';
import 'package:notebook_ai/core/res/color_manager.dart';

// ─── Time Ago ─────────────────────────────────────────────────────────────────

String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  final days = diff.inDays;
  if (days == 0) return 'time.today'.tr();
  if (days == 1) return 'time.yesterday'.tr();
  if (days < 7) return plural('time.days_ago', days);
  // Same year → "15 Jun"; different year → "15 Jun 2025".
  final pattern = date.year == DateTime.now().year ? 'd MMM' : 'd MMM y';
  return DateFormat(pattern, Intl.getCurrentLocale()).format(date);
}

// ─── Generate ID ──────────────────────────────────────────────────────────────

String generateId() {
  return DateTime.now().millisecondsSinceEpoch.toRadixString(36) +
      (DateTime.now().microsecond).toRadixString(36);
}

// ─── Tag / folder display label ───────────────────────────────────────────────

/// Localized display label for a canonical tag/folder name. The stored value
/// stays English (it doubles as the DB folder and the Gemini allowed-tag list);
/// only the shown text is translated. Unknown labels fall back to themselves.
String localizedTag(String label) {
  final key = 'tags.$label';
  final translated = key.tr();
  return translated == key ? label : translated;
}

// ─── Folders ──────────────────────────────────────────────────────────────────

/// Special folder that collects notes with no tags.
const String kOthersFolder = 'Others';

/// One folder per tag — derived from [ColorM.tagColors] so the Folders grid
/// and the Search "Browse by tag" cloud always stay in sync (every tag has a
/// folder, and vice-versa).
List<String> get kFolders => ColorM.tagColors.keys.toList();

List<String> get gridFolders => [kOthersFolder, ...kFolders];
