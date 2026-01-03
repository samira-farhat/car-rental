import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../services/document_service.dart';

class UploadDocumentsScreen extends StatefulWidget {
  const UploadDocumentsScreen({super.key});

  @override
  State<UploadDocumentsScreen> createState() => _UploadDocumentsScreenState();
}

class _UploadDocumentsScreenState extends State<UploadDocumentsScreen> {
  String _selectedDocumentType = 'DL';
  File? _selectedFile;
  bool _isUploading = false;

  final Map<String, String> _documentTypes = {
    'DL': 'Driving License',
    'ID': 'National ID',
    'PP': 'Passport',
  };

  // ---------------- PICK FILE ----------------
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  // ---------------- UPLOAD ----------------
  Future<void> _uploadDocument() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await DocumentService.uploadDocument(
        file: _selectedFile!,
        documentType: _selectedDocumentType,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document uploaded successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // 🔄 return success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload failed'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Document type
            DropdownButtonFormField<String>(
              value: _selectedDocumentType,
              items: _documentTypes.entries
                  .map(
                    (e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value),
                ),
              )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedDocumentType = value!),
              decoration: const InputDecoration(
                labelText: 'Document Type',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // File picker
            InkWell(
              onTap: _pickFile,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.upload_file),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedFile != null
                            ? _selectedFile!.path.split('/').last
                            : 'Choose file (PDF / JPG / PNG)',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Upload button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadDocument,
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('UPLOAD'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
