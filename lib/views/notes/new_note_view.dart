import 'package:flutter/material.dart';

class NewNoteView extends StatefulWidget {
  const new({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: false,
        title: const Text('New Note')
      ),
      body: const Text('Write your new note here...')
    );
  }
}