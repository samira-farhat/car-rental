import 'package:flutter/material.dart';

class UploadDocumentsScreen extends StatefulWidget {
  const UploadDocumentsScreen({Key? key}) : super(key: key);

  @override
  State<UploadDocumentsScreen> createState() => _UploadDocumentsScreenState();
}

class _UploadDocumentsScreenState extends State<UploadDocumentsScreen> {
  String _selectedDocument = 'Driver\'s License';
  String? _selectedFileName;
  final TextEditingController _notesController = TextEditingController();
  bool _uploadSuccess = false;

  final List<String> _documentTypes = [
    'Driver\'s License',
    'ID Card',
    'Passport',
  ];

  void _pickFile() {
    // FRONTEND MOCK (no real picker yet)
    setState(() {
      _selectedFileName = 'document_sample.pdf';
      _uploadSuccess = false;
    });
  }

  void _uploadDocument() {
    if (_selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose a file first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _uploadSuccess = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document uploaded successfully (frontend only)'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _cancel() {
    Navigator.pop(context);
  }

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
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Document Type",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedDocument,
                        items: _documentTypes
                            .map(
                              (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDocument = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 File Upload
                _whiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "File Upload",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      GestureDetector(
                        onTap: _pickFile,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.upload_file),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _selectedFileName ?? "Choose file",
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (_selectedFileName != null) ...[
                        const SizedBox(height: 10),
                        const Text(
                          "Preview ready (image / PDF)",
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Notes
                _whiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Notes (optional)",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: "Add any additional information",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 🔹 Upload Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF49C5E0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _uploadDocument,
                    child: const Text(
                      "UPLOAD",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 🔹 Cancel Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _cancel,
                    child: const Text(
                      "CANCEL",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                if (_uploadSuccess) ...[
                  const SizedBox(height: 16),
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 36),
                  const SizedBox(height: 6),
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

  // ================= HELPERS =================

  Widget _whiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}
