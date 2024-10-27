import 'package:flutter/material.dart';
import 'database_service.dart';

class NoteScreen extends StatefulWidget {
  final int topicId;
  final String topicTitle;

  const NoteScreen({Key? key, required this.topicId, required this.topicTitle})
      : super(key: key);

  @override
  NoteScreenState createState() => NoteScreenState();
}

class NoteScreenState extends State<NoteScreen> {
  final DatabaseService dbService = DatabaseService();
  List<Map<String, dynamic>> notes = [];
  TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final data = await dbService.getNotes(widget.topicId);
    setState(() {
      notes = data;
    });
  }

  void _addNote() async {
    if (noteController.text.isNotEmpty) {
      await dbService.addNote(widget.topicId, noteController.text);
      noteController.clear();
      _loadNotes();
    }
  }

  void deleteNoteConfirmation(int noteId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteNote(noteId); // Call the actual delete function
                Navigator.of(context).pop(); // Close the dialog after deletion
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote(int noteId) async {
    await DatabaseService().deleteNote(noteId);
    _loadNotes(); // Refresh notes after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes - ${widget.topicTitle}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return ListTile(
                  title: Text(note['content']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteNoteConfirmation(note['id']),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: noteController,
                    decoration:
                        const InputDecoration(hintText: 'Enter new note'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addNote,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

