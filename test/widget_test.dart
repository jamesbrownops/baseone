import 'package:flutter/material.dart';

void main() {
  runApp(const BaseOneApp());
}

class BaseOneApp extends StatelessWidget {
  const BaseOneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BaseOne',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BaseOneHome(),
    );
  }
}

class BaseOneHome extends StatelessWidget {
  const BaseOneHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BaseOne Home'),
        backgroundColor: Colors.deepPurple.shade200,
      ),
      body: const Center(
        child: Text(
          'BaseOne is alive.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}