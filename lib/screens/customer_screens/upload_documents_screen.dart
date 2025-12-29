import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class UploadDocumentsScreen extends StatefulWidget {
  const UploadDocumentsScreen({Key? key}) : super(key: key);

  @override
  State<UploadDocumentsScreen> createState() => _UploadDocumentsScreenState();
}

class _UploadDocumentsScreenState extends State<UploadDocumentsScreen> {
  String _selectedDocument = 'Driver\'s License';
  String? _selectedFileName;
  Uint8List? _selectedFileBytes;

  final TextEditingController _notesController = TextEditingController();
  bool _uploadSuccess = false;
  bool _isUploading = false;

  final List<String> _documentTypes = [
    'Driver\'s License',
    'ID Card',
    'Passport',
  ];

  // 🔐 TEMP: replace later with secure storage
  static const String ACCESS_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzY3MDM5NDA0LCJpYXQiOjE3NjcwMzkxMDQsImp0aSI6IjgxY2MzMDE5Mjg5ZjRhYTFhZmYzOTkyOTFlZGYwOTJkIiwidXNlcl9pZCI6IjEifQ.TRRIS0J_3KBkOjn1WdZ6WUnbDVDMxhfWeJadA94p188";

  // ================= FILE PICKER (WEB) =================
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedFileBytes = result.files.single.bytes;
        _selectedFileName = result.files.single.name;
        _uploadSuccess = false;
      });
    }
  }

  // ================= UPLOAD TO BACKEND =================
  Future<void> _uploadDocument() async {
    if (_selectedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose a file first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final uri =
      Uri.parse("http://127.0.0.1:8000/api/documents/upload/");

      final request = http.MultipartRequest("POST", uri);

      request.headers['Authorization'] = 'Bearer $ACCESS_TOKEN';

      request.fields['document_type'] = _selectedDocument;
      request.fields['notes'] = _notesController.text;

      request.files.add(
        http.MultipartFile.fromBytes(
          'document_image',
          _selectedFileBytes!,
          filename: _selectedFileName,
        ),
      );

      final response = await request.send();

      if (response.statusCode == 201) {
        setState(() {
          _uploadSuccess = true;
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception("Upload failed: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _isUploading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _cancel() {
    Navigator.pop(context);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000000),
              Color(0xFF218BA2),
              Color(0xFF004760),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // 🔹 Logo
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 42,
                    backgroundImage:
                    const AssetImage('assets/images/logo.jpg'),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Upload Documents",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                // 🔹 Document Type
                _whiteCard(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDocument,
                    items: _documentTypes
                        .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedDocument = value!),
                    decoration: const InputDecoration(
                      labelText: "Document Type",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 File Upload
                _whiteCard(
                  child: GestureDetector(
                    onTap: _pickFile,
                    child: Row(
                      children: [
                        const Icon(Icons.upload_file),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedFileName ?? "Choose file",
                            style:
                            const TextStyle(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Notes
                _whiteCard(
                  child: TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Notes (optional)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 🔹 Upload Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _uploadDocument,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF49C5E0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isUploading
                        ? const CircularProgressIndicator(
                        color: Colors.white)
                        : const Text(
                      "UPLOAD",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 🔹 Cancel
                OutlinedButton(
                  onPressed: _cancel,
                  child: const Text("CANCEL",
                      style: TextStyle(color: Colors.white)),
                ),

                if (_uploadSuccess) ...[
                  const SizedBox(height: 16),
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 36),
                  const Text(
                    "Document Uploaded Successfully",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _whiteCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}
