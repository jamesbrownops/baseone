import 'dart:async';
import 'package:flutter/material.dart';
import 'notes_service.dart';

void main() {
  runApp(const BaseOneApp());
}

class BaseOneApp extends StatelessWidget {
  const BaseOneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BaseOne',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final NotesService _service = NotesService();

  List<Note> _notes = [];
  Note? _selected;
  String _searchQuery = '';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _titleController.addListener(_scheduleSave);
    _bodyController.addListener(_scheduleSave);
  }

  Future<void> _loadNotes() async {
    final notes = await _service.loadAll();

    setState(() {
      _notes = notes;

      if (_notes.isNotEmpty) {
        _selected = _notes.first;
        _titleController.text = _selected!.title;
        _bodyController.text = _selected!.body;
      }
    });
  }

  Future<void> _createNote() async {
    final note = _service.createEmpty();

    setState(() {
      _notes = _service.upsert(_notes, note);
      _selected = note;
      _titleController.text = note.title;
      _bodyController.text = note.body;
      _searchQuery = '';
    });

    await _service.saveAll(_notes);
  }

  void _selectNote(Note note) {
    setState(() {
      _selected = note;
      _titleController.text = note.title;
      _bodyController.text = note.body;
    });
  }

  void _scheduleSave() {
    if (_selected == null) return;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _saveNote);
  }

  Future<void> _saveNote() async {
    if (_selected == null) return;

    final updated = _selected!.copyWith(
      title: _titleController.text.trim().isEmpty
          ? 'Untitled'
          : _titleController.text.trim(),
      body: _bodyController.text,
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() {
      _notes = _service.upsert(_notes, updated);
      _selected = updated;
    });

    await _service.saveAll(_notes);
  }

  Future<void> _deleteNote(Note note) async {
    setState(() {
      _notes = _service.deleteById(_notes, note.id);

      if (_selected?.id == note.id) {
        if (_notes.isNotEmpty) {
          _selected = _notes.first;
          _titleController.text = _selected!.title;
          _bodyController.text = _selected!.body;
        } else {
          _selected = null;
          _titleController.clear();
          _bodyController.clear();
        }
      }
    });

    await _service.saveAll(_notes);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _notes.where((note) {
      final q = _searchQuery.toLowerCase();
      return note.title.toLowerCase().contains(q) ||
          note.body.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("BaseOne Notes")),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNote,
        child: const Icon(Icons.add),
      ),
      body: Row(
        children: [
          Container(
            width: 320,
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Search notes...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];

                      return ListTile(
                        title: Text(
                          note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          note.body.isEmpty
                              ? "(empty note)"
                              : note.body.split('\n').first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        selected: _selected?.id == note.id,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteNote(note),
                        ),
                        onTap: () => _selectNote(note),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: "Note title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TextField(
                      controller: _bodyController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        hintText: "Write your note...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}