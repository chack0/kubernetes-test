// Remove dart:html as we are not using localStorage anymore
// import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'dart:convert'; // For JSON encoding/decoding

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Kubernetes Backend Integration',
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
  String storageLocationInfo =
      'Initializing...'; // Will be updated from backend path

  // ** IMPORTANT: Replace with your actual backend URL **
  // Use the NodePort IP and port obtained in Part 2.
  // Example: 'http://192.168.64.27:30000' (your worker node IP and the assigned NodePort)
  final String backendUrl = 'http://192.168.64.27:31904';
  // For instance: 'http://192.168.64.27:31234' (replace with your actual values)

  @override
  void initState() {
    super.initState();
    _updateStorageLocationInfo(); // Set initial storage location info
    _loadInitialContentFromBackend(); // Load initial content from backend
  }

  // Helper method to set the storage location details (now derived from backend)
  void _updateStorageLocationInfo() {
    setState(() {
      storageLocationInfo =
          'Stored on Kubernetes PV at: /var/lib/flutter-app-data/app_logs/log.txt (on kubeworker01)';
    });
  }

  // New method to load content from the backend's /read endpoint
  Future<void> _loadInitialContentFromBackend() async {
    try {
      final response = await http.get(Uri.parse('$backendUrl/read'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          content = data['content'] ?? 'No content found.';
        });
      } else {
        setState(() {
          content =
              'Failed to load content from backend: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        content = 'Error communicating with backend: $e';
      });
    }
  }

  // Modified to send text to the backend's /save endpoint
  Future<void> _writeToFile(String input) async {
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text to save!')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$backendUrl/save'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'text': input}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Text saved!')),
        );
        setState(() {
          _controller.clear();
          _loadInitialContentFromBackend(); // Refresh content after saving
        });
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to save text: ${errorData['error'] ?? response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error communicating with backend: $e')),
      );
    }
  }

  // Modified to send clear request to the backend's /clear endpoint
  Future<void> _resetFile() async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/clear'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File cleared successfully!')),
        );
        setState(() {
          _controller.clear();
          _loadInitialContentFromBackend(); // Refresh content after clearing
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to clear file: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error communicating with backend: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter Web File Simulator")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 16),
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
