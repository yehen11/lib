import 'package:flutter/material.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Inbox')),
        body: const Center(
          child: Text(
            'This is Inbox Screen',
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
}
