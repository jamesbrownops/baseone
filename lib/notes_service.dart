import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class Note {
  final String id;
  final String title;
  final String body;
  final int createdAtMs;
  final int updatedAtMs;

  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAtMs,
    required this.updatedAtMs,
  });

  Note copyWith({
    String? id,
    String? title,
    String? body,
    int? createdAtMs,
    int? updatedAtMs,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAtMs': createdAtMs,
        'updatedAtMs': updatedAtMs,
      };

  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: (map['title'] as String?) ?? 'Untitled',
      body: (map['body'] as String?) ?? '',
      createdAtMs: (map['createdAtMs'] as int?) ?? 0,
      updatedAtMs: (map['updatedAtMs'] as int?) ?? 0,
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

      notes.sort((a, b) => b.updatedAtMs.compareTo(a.updatedAtMs));
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
    copy.sort((a, b) => b.updatedAtMs.compareTo(a.updatedAtMs));
    return copy;
  }

  List<Note> deleteById(List<Note> notes, String id) {
    final copy = notes.where((n) => n.id != id).toList();
    copy.sort((a, b) => b.updatedAtMs.compareTo(a.updatedAtMs));
    return copy;
  }
}