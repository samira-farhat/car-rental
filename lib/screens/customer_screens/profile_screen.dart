import 'package:car_management_frontend/globals.dart';
import 'package:car_management_frontend/main_screens/home_screen.dart';
import 'package:flutter/material.dart';
import '../../services/profile_service.dart';
import '../../services/document_service.dart';
import '../../services/review_service.dart';
import '../features/reviews_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ---------------- Personal Info
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool loading = true;

  // ---------------- Documents
  List<dynamic> documents = [];
  bool documentsLoading = true;

  // ---------------- Reviews
  List<dynamic> reviews = [];
  bool reviewsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadDocuments();
    _loadReviews();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // ---------------- Load profile
  Future<void> _loadProfile() async {
    try {
      final data = await ProfileService.getProfile();
      setState(() {
        firstNameController.text = data['first_name'] ?? '';
        middleNameController.text = data['middle_name'] ?? '';
        lastNameController.text = data['last_name'] ?? '';
        emailController.text = data['email'] ?? '';
        phoneController.text = data['phone'] ?? '';
        addressController.text = data['address'] ?? '';
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile')));
    }
  }

  // ---------------- Load documents
  Future<void> _loadDocuments() async {
    try {
      final data = await DocumentService.getMyDocuments();
      setState(() {
        documents = data;
        documentsLoading = false;
      });
    } catch (e) {
      setState(() => documentsLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load documents')));
    }
  }

  // ---------------- Load reviews
  Future<void> _loadReviews() async {
    try {
      final data = await ReviewService.getMyReviews();
      setState(() {
        reviews = data;
        reviewsLoading = false;
      });
    } catch (e) {
      setState(() => reviewsLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load reviews')));
    }
  }

  // ---------------- Zoomable image
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
              child: Center(
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Top Bar
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
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "MY PROFILE",
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
          ]),
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

  // ---------------- Category Card
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
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...children
        ],
      ),
    );
  }

  // ---------------- Document Card
  Widget _documentCard(Map doc) {
    Color statusColor;
    switch (doc['status']) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(doc['type'],
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            Chip(
              label: Text(doc['status'].toUpperCase()),
              backgroundColor: statusColor.withOpacity(0.2),
              labelStyle: TextStyle(color: statusColor),
            ),
          ]),
          const SizedBox(height: 8),
          if (doc['file'] != null)
            GestureDetector(
              onTap: () => _openZoomableImage(doc['file']),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  doc['file'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 6),
          Text('Uploaded: ${doc['uploaded_at']}',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  // ---------------- Review Card
  Widget _reviewCard(Map review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            review['car'] ?? '-',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            review['comment'] ?? '-',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...List.generate(
                review['rating'] ?? 0,
                    (_) => const Icon(Icons.star, color: Colors.amber, size: 18),
              ),
              const SizedBox(width: 4),
              Text(
                '${review['rating'] ?? '-'} / 5',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }


  // ---------------- Info Row
  Widget _infoRow(String label, TextEditingController controller,
      {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: Column(
        children: [
          _buildTopBar(),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Full Name
                  _buildCategoryCard(title: "Full Name", children: [
                    _infoRow("First Name", firstNameController),
                    _infoRow("Middle Name", middleNameController),
                    _infoRow("Last Name", lastNameController),
                  ]),

                  // Contact Info
                  _buildCategoryCard(title: "Contact Info", children: [
                    _infoRow("Email", emailController, readOnly: true),
                    _infoRow("Phone", phoneController),
                  ]),

                  // Address
                  _buildCategoryCard(title: "Address", children: [
                    _infoRow("Address", addressController),
                  ]),

                  // Save Button
                  ElevatedButton(
                    style:  ElevatedButton.styleFrom(
                        backgroundColor: deepMidnightBlue, // <-- Set your desired color here
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),),
                    onPressed: () async {
                      try {
                        await ProfileService.updateProfile({
                          "first_name": firstNameController.text,
                          "middle_name": middleNameController.text,
                          "last_name": lastNameController.text,
                          "phone": phoneController.text,
                          "address": addressController.text,
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Profile updated successfully')));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Update failed')));
                      }
                    },
                    child: const Text('Save Changes', style: TextStyle(color: Colors.white),),
                  ),

                  const SizedBox(height: 16),

                  // Documentation
                  _buildCategoryCard(
                    title: "Documentation",
                    children: documentsLoading
                        ? [const Center(child: CircularProgressIndicator())]
                        : documents.isEmpty
                        ? [const Text("No documents uploaded")]
                        : documents.map((doc) => _documentCard(doc)).toList(),
                  ),

                  // Reviews
                  _buildCategoryCard(
                    title: "Reviews",
                    children: reviewsLoading
                        ? [const Center(child: CircularProgressIndicator())]
                        : reviews.isEmpty
                        ? [const Text("No reviews yet")]
                        : reviews.map((r) => _reviewCard(r)).toList(),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity, // full width button
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: deepMidnightBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen()));
                          },
                          child: const Text(
                            'LOGOUT',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: electricCyan,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CarReviewPage())); // your review page widget
                          },
                          child: const Text(
                            'Submit A Review',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
