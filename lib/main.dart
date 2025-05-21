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

  @override
  void initState() {
    super.initState();
    _loadInitialContent();
  }

  void _loadInitialContent() {
    final savedContent = html.window.localStorage[MyApp.storageKey];
    if (savedContent == null) {
      _resetFile(); // First time - set default
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
          ],
        ),
      ),
    );
  }
}

// // lib/main.dart

// import 'package:flutter/material.dart';
// import 'web_iframe.dart'; // Import the helper

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   final String viewId = 'my-iframe';
//   final String url = 'https://flutter.dev'; // Use an embeddable URL

//   MyApp({super.key}) {
//     registerIFrame(viewId, url); // Register the iframe
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Chacko Kubernetes Test',
//       home: Scaffold(
//         appBar: AppBar(title: const Text('Jacob Chacko 123 Kubernetes')),
//         body: const SizedBox.expand(
//           child: HtmlElementView(viewType: 'my-iframe'),
//         ),
//       ),
//     );
//   }
// }
