import 'dart:typed_data'; // ✅ REQUIRED FOR WEB

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
  bool _isUploading = false;

  Uint8List? _fileBytes;
  String? _fileName;

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
      withData: true, // 🔴 REQUIRED FOR WEB
    );

    if (result == null) return;

    setState(() {
      _fileBytes = result.files.single.bytes;
      _fileName = result.files.single.name;
    });
  }

  // ---------------- UPLOAD ----------------
  Future<void> _uploadDocument() async {
    if (_fileBytes == null || _fileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await DocumentService.uploadDocument(
        fileBytes: _fileBytes!,
        fileName: _fileName!,
        documentType: _selectedDocumentType,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document uploaded successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // return success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
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
                        _fileName ?? 'Choose file (PDF / JPG / PNG)',
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
