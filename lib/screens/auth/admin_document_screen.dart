import 'package:flutter/material.dart';
import 'admin_document_service.dart';
import '../../globals.dart';

class AdminDocumentsScreen extends StatefulWidget {
  const AdminDocumentsScreen({super.key});

  @override
  State<AdminDocumentsScreen> createState() => _AdminDocumentsScreenState();
}

class _AdminDocumentsScreenState extends State<AdminDocumentsScreen> {
  bool isLoading = true;
  List<dynamic> documents = [];

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    try {
      final data = await AdminDocumentService.getAllDocuments();
      setState(() {
        documents = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load documents')),
      );
    }
  }

  Future<void> _updateStatus(int docId, String status) async {
    try {
      await AdminDocumentService.updateDocumentStatus(docId, status);
      fetchDocuments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Action failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildTopBar()),
          SliverToBoxAdapter(
            child: isLoading
                ? const Padding(
              padding: EdgeInsets.only(top: 60),
              child: Center(child: CircularProgressIndicator()),
            )
                : documents.isEmpty
                ? const Padding(
              padding: EdgeInsets.only(top: 60),
              child: Center(child: Text('No documents found')),
            )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: documents.map(_buildDocumentCard).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(dynamic doc) {
    Color statusColor;
    switch (doc['status']) {
      case 'verified':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doc['user_email'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text("Type: ${doc['document_type']}"),
            const SizedBox(height: 6),
            Text(
              "Status: ${doc['status']}",
              style: TextStyle(color: statusColor),
            ),
            const SizedBox(height: 14),

            if (doc['status'] == 'pending')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () =>
                          _updateStatus(doc['id'], 'verified'),
                      child: const Text('VERIFY'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () =>
                          _updateStatus(doc['id'], 'rejected'),
                      child: const Text('REJECT'),
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "ADMIN PANEL",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "User Documents",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1C1E),
            ),
          ),
        ],
      ),
    );
  }
}
