import 'package:flutter/material.dart';
import 'database_service.dart';
import 'note_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notebook',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TopicListScreen(),
    );
  }
}

class TopicListScreen extends StatefulWidget {
  const TopicListScreen({super.key});

  @override
  TopicListScreenState createState() => TopicListScreenState();
}

class TopicListScreenState extends State<TopicListScreen> {
  final DatabaseService dbService = DatabaseService();
  List<Map<String, dynamic>> topics = [];

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    final data = await dbService.getTopics();
    setState(() {
      topics = data;
    });
  }

  void _addTopic(String title) async {
    await dbService.addTopic(title);
    _loadTopics();
  }

  void _deleteTopic(int topicId) async {
    await dbService.deleteTopic(topicId);
    _loadTopics();
  }

  void _renameTopic(int topicId, String newTitle) async {
    await dbService.renameTopic(topicId, newTitle);
    _loadTopics();
  }

  Future<String?> _showRenameTopicDialog(
      BuildContext context, String currentTitle) {
    TextEditingController controller =
        TextEditingController(text: currentTitle);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Topic'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter new title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notebook - Topics')),
      body: ListView.builder(
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          return ListTile(
            title: Text(topic['title']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteScreen(
                      topicId: topic['id'], topicTitle: topic['title']),
                ),
              );
            },
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'Delete') {
                  _deleteTopic(topic['id']);
                } else if (value == 'Rename') {
                  final newTitle =
                      await _showRenameTopicDialog(context, topic['title']);
                  if (newTitle != null && newTitle.isNotEmpty) {
                    _renameTopic(topic['id'], newTitle);
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'Rename', child: Text('Rename')),
                const PopupMenuItem(value: 'Delete', child: Text('Delete')),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final title = await _showAddTopicDialog(context);
          if (title != null && title.isNotEmpty) {
            _addTopic(title);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<String?> _showAddTopicDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Topic'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter topic title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
