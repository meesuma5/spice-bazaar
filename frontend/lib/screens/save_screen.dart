import 'package:flutter/material.dart';

class SaveScreen extends StatelessWidget {
  const SaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Save')),
      body: const Center(
        child: Text('Save Screen'),
      ),
    );
  }
}