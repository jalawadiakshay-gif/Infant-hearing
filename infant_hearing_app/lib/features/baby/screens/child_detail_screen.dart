import 'package:flutter/material.dart';

class ChildDetailScreen extends StatelessWidget {
  const ChildDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Details'),
      ),
      body: const Center(
        child: Text('Child Detail Screen'),
      ),
    );
  }
}
