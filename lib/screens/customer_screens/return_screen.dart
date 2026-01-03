import 'package:flutter/material.dart';

class ReturnScreen extends StatelessWidget {
  const ReturnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Return Car'),
      ),
      body: const Center(
        child: Text(
          'Return Screen',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
