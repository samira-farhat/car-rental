import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:car_management_frontend/globals.dart';
import '../services/review_service.dart';


class AdminCustomerDetailsScreen extends StatefulWidget {
  final int customerId;
  const AdminCustomerDetailsScreen({super.key, required this.customerId});

  @override
  State<AdminCustomerDetailsScreen> createState() =>
      _AdminCustomerDetailsScreenState();
}

class _AdminCustomerDetailsScreenState
    extends State<AdminCustomerDetailsScreen> {
  bool loading = true;
  Map customer = {};
  List documents = [];

  // Track loading state per document
  Map<int, bool> docLoading = {};

  // Reviews
  List reviews = [];
  bool loadingReviews = true;

  @override
  void initState() {
    super.initState();
    fetchCustomerDetails();
    fetchReviews();
  }

  void _openZoomableImage(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              panEnabled: true,
              child: Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> fetchCustomerDetails() async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'access');
    if (token == null) return;

    final response = await http.get(
      Uri.parse(
          'http://localhost:8000/api/accounts/admin/customers/${widget.customerId}/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        customer = data;
        documents = data['documents'];
        // Initialize all document loading states
        docLoading = {for (var doc in documents) doc['id']: false};
        loading = false;
      });
    } else {
      setState(() => loading = false);
      print("Failed to fetch customer: ${response.body}");
    }
  }

  Future<void> fetchReviews() async {
    setState(() => loadingReviews = true);
    try {
      final data = await ReviewService.getMyReviews();
      // Filter reviews by this customer
      final customerReviews =
      data.where((r) => r['customer_id'] == widget.customerId).toList();
      setState(() {
        reviews = customerReviews;
        loadingReviews = false;
      });
    } catch (e) {
      setState(() => loadingReviews = false);
      print("Failed to load reviews: $e");
    }
  }

  Future<void> verifyDocument(int documentId, String action) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Action"),
        content: Text("Are you sure you want to $action this document?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Confirm")),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => docLoading[documentId] = true);

    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'access');

    final response = await http.post(
      Uri.parse('http://localhost:8000/api/accounts/admin/verify-document/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'document_id': documentId, 'action': action}),
    );

    if (response.statusCode == 200) {
      await fetchCustomerDetails();
    } else {
      print("Failed to update document status: ${response.body}");
      setState(() => docLoading[documentId] = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: Column(
        children: [
          _buildTopBar(),
          SizedBox(height: 20,),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Full Name
                _buildCategoryCard(
                  title: "Full Name",
                  children: [
                    _row("First Name", customer['first_name'] ?? '-'),
                    _row("Middle Name", customer['middle_name'] ?? '-'),
                    _row("Last Name", customer['last_name'] ?? '-'),
                  ],
                ),
                // Contact Info
                _buildCategoryCard(
                  title: "Contact Info",
                  children: [
                    _row("Email", customer['email'] ?? '-'),
                    _row("Phone", customer['phone'] ?? '-'),
                  ],
                ),
                // Address
                _buildCategoryCard(
                  title: "Address",
                  children: [
                    _row("Address", customer['address'] ?? '-'),
                  ],
                ),
                // Documentation
                _buildCategoryCard(
                  title: "Documentation",
                  children: documents.map((doc) => _documentCard(doc)).toList(),
                ),
                // Reviews
                _buildCategoryCard(
                  title: "Reviews",
                  children: loadingReviews
                      ? [const Center(child: CircularProgressIndicator())]
                      : reviews.isEmpty
                      ? [const Text("No reviews yet")]
                      : reviews
                      .map((review) => _reviewCard(review))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "CUSTOMER DETAILS",
                style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Profile",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1C1E)),
              ),
            ],
          ),
          Container(

            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: deepMidnightBlue, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      {required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _documentCard(Map doc) {
    bool isActioned = doc['status'] != 'pending';
    bool loadingDoc = docLoading[doc['id']] ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Document: ${doc['type']}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _openZoomableImage(doc['image']),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                doc['image'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 12),
          if (!isActioned)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                    loadingDoc ? null : () => verifyDocument(doc['id'], 'verified'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green),
                    child: loadingDoc
                        ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ))
                        : const Text("Verify", style: TextStyle(color: Colors.white),),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                    loadingDoc ? null : () => verifyDocument(doc['id'], 'rejected'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: loadingDoc
                        ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ))
                        : const Text("Reject",style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          else
            Text(
              "Status: ${doc['status'].toUpperCase()}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: doc['status'] == 'verified' ? Colors.green : Colors.red),
            )
        ],
      ),
    );
  }

  Widget _reviewCard(Map review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(review['title'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(review['comment'] ?? '-'),
          const SizedBox(height: 4),
          Text("Rating: ${review['rating'] ?? '-'}", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
