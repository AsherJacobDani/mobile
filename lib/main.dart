import 'package:flutter/material.dart';

void main() {
  runApp(const InstaAIApp());
}

class InstaAIApp extends StatelessWidget {
  const InstaAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'InstaAI',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('InstaAI'),
        ),
        body: const Center(
          child: Text(
            'Instagram AI Assistant',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}