import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class Note {
  final String id;
  final String title;
  final String body;
  final int createdAtMs;
  final int updatedAtMs;
  final bool pinned;

  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.pinned,
  });

  Note copyWith({
    String? id,
    String? title,
    String? body,
    int? createdAtMs,
    int? updatedAtMs,
    bool? pinned,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      pinned: pinned ?? this.pinned,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAtMs': createdAtMs,
        'updatedAtMs': updatedAtMs,
        'pinned': pinned,
      };

  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: (map['title'] as String?) ?? 'Untitled',
      body: (map['body'] as String?) ?? '',
      createdAtMs: (map['createdAtMs'] as int?) ?? 0,
      updatedAtMs: (map['updatedAtMs'] as int?) ?? 0,
      pinned: (map['pinned'] as bool?) ?? false,
    );
  }
}

class NotesService {
  static const _storageKey = 'baseone_notes_v2';
  static const _uuid = Uuid();

  Note createEmpty() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Note(
      id: _uuid.v4(),
      title: 'Untitled',
      body: '',
      createdAtMs: now,
      updatedAtMs: now,
      pinned: false,
    );
  }

  Future<List<Note>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.trim().isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      final notes = decoded
          .whereType<Map>()
          .map((m) => Note.fromMap(m.cast<String, dynamic>()))
          .toList();

      _sortNotes(notes);
      return notes;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAll(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final list = notes.map((n) => n.toMap()).toList();
    final raw = jsonEncode(list);
    await prefs.setString(_storageKey, raw);
  }

  List<Note> upsert(List<Note> notes, Note note) {
    final copy = [...notes];
    final idx = copy.indexWhere((n) => n.id == note.id);
    if (idx >= 0) {
      copy[idx] = note;
    } else {
      copy.add(note);
    }
    _sortNotes(copy);
    return copy;
  }

  List<Note> deleteById(List<Note> notes, String id) {
    final copy = notes.where((n) => n.id != id).toList();
    _sortNotes(copy);
    return copy;
  }

  void _sortNotes(List<Note> notes) {
    notes.sort((a, b) {
      if (a.pinned != b.pinned) {
        return a.pinned ? -1 : 1;
      }
      return b.updatedAtMs.compareTo(a.updatedAtMs);
    });
  }
}