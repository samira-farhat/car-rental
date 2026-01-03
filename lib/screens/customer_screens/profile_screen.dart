import 'package:flutter/material.dart';
import 'upload_documents_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
            onPressed: () {
      Navigator.push(
      context,
      MaterialPageRoute(
      builder: (_) => const UploadDocumentsScreen(),
      ),
      );
      },
        child: const Text('Upload Documents'),
      )

          ],
        ),
      ),
    );
  }
}
