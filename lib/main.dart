import 'dart:html' as html;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const String storageKey = 'flutter_file_sim';

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Local File Sim',
      home: FileSimulatorPage(),
    );
  }
}

class FileSimulatorPage extends StatefulWidget {
  const FileSimulatorPage({super.key});

  @override
  State<FileSimulatorPage> createState() => _FileSimulatorPageState();
}

class _FileSimulatorPageState extends State<FileSimulatorPage> {
  final TextEditingController _controller = TextEditingController();
  String content = '';
  // New variable to hold the storage location information
  String storageLocationInfo = '';

  @override
  void initState() {
    super.initState();
    _updateStorageLocationInfo(); // Set the storage location info on init
    _loadInitialContent();
  }

  // Helper method to set the storage location details
  void _updateStorageLocationInfo() {
    // In Flutter Web, localStorage is tied to the browser's origin (URL)
    // There isn't a traditional 'file path'. We show the origin and the key.
    setState(() {
      storageLocationInfo =
          'Stored in: Browser Local Storage\nOrigin: ${html.window.location.origin}\nKey: ${MyApp.storageKey}';
    });
  }

  void _loadInitialContent() {
    final savedContent = html.window.localStorage[MyApp.storageKey];
    if (savedContent == null) {
      _resetFile(); // First time - set default content
    } else {
      setState(() {
        content = savedContent;
      });
    }
  }

  void _writeToFile(String input) {
    final now = DateTime.now().toString();
    final newContent = '$content\n[$now] $input';
    html.window.localStorage[MyApp.storageKey] = newContent.trim();
    setState(() {
      content = newContent.trim();
      _controller.clear();
    });
  }

  void _resetFile() {
    final now = DateTime.now().toString();
    final emptyMessage = '[$now] File is empty';
    html.window.localStorage[MyApp.storageKey] = emptyMessage;
    setState(() {
      content = emptyMessage;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter Web File Simulator")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align content to the start
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter text',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _writeToFile(_controller.text),
                  child: const Text('Submit'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _resetFile,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'File Content:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: Text(content),
                ),
              ),
            ),
            const SizedBox(height: 16), // Space before location info
            const Text(
              'Storage Location:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              storageLocationInfo,
              style: TextStyle(
                  fontStyle: FontStyle.italic, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
