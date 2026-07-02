import 'package:flutter/material.dart';
import 'package:notebook_ai/core/res/color_manager.dart';

// ─── AI Tag ───────────────────────────────────────────────────────────────────

class AITag {
  final String label;
  final Color color;

  const AITag({required this.label, required this.color});

  factory AITag.fromLabel(String label) {
    return AITag(
      label: label,
      color: ColorM.tagColors[label] ?? ColorM.tagWork,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AITag &&
          runtimeType == other.runtimeType &&
          label == other.label;

  @override
  int get hashCode => label.hashCode;
}

// ─── Note Model ───────────────────────────────────────────────────────────────

class NoteModel {
  final String id;
  final String title;
  final String body;
  final List<AITag> tags;
  final String folder;
  final DateTime createdAt;
  final String? summary;
  final bool starred;

  const NoteModel({
    required this.id,
    required this.title,
    required this.body,
    required this.tags,
    required this.folder,
    required this.createdAt,
    this.summary,
    this.starred = false,
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? body,
    List<AITag>? tags,
    String? folder,
    DateTime? createdAt,
    String? summary,
    bool? starred,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      tags: tags ?? this.tags,
      folder: folder ?? this.folder,
      createdAt: createdAt ?? this.createdAt,
      summary: summary ?? this.summary,
      starred: starred ?? this.starred,
    );
  }
}
