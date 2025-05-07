// lib/main.dart

import 'package:flutter/material.dart';
import 'web_iframe.dart'; // Import the helper

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String viewId = 'my-iframe';
  final String url = 'https://flutter.dev'; // Use an embeddable URL

  MyApp({super.key}) {
    registerIFrame(viewId, url); // Register the iframe
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chacko Kubernetes Test',
      home: Scaffold(
        appBar: AppBar(title: const Text('Susan Thomas Kubernetes Test')),
        body: const SizedBox.expand(
          child: HtmlElementView(viewType: 'my-iframe'),
        ),
      ),
    );
  }
}
