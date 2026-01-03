import 'package:flutter/material.dart';
import '../../services/profile_service.dart';
import '../../services/document_service.dart';
import '../../services/review_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ---------------- Personal Info
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool isLoading = true;

  // ---------------- Documents
  List<dynamic> documents = [];
  bool documentsLoading = true;

  // ---------------- Reviews
  List<dynamic> reviews = [];
  bool reviewsLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _loadProfile();
    _loadDocuments();
    _loadReviews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    nameController.dispose();
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
        nameController.text =
        '${data['first_name']} ${data['last_name']}';
        emailController.text = data['email'];
        phoneController.text = data['phone'];
        addressController.text = data['address'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load documents')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load reviews')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Personal Info', icon: Icon(Icons.person)),
            Tab(text: 'Documents', icon: Icon(Icons.description)),
            Tab(text: 'Reviews', icon: Icon(Icons.star)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPersonalInfoTab(),
          _buildDocumentsTab(),
          _buildReviewsTab(),
        ],
      ),
    );
  }

  /// ------------------ TAB 1: PERSONAL INFO ------------------
  Widget _buildPersonalInfoTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const CircleAvatar(
            radius: 45,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: emailController,
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Email (Read only)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () async {
              try {
                await ProfileService.updateProfile({
                  "first_name": nameController.text.split(' ').first,
                  "last_name": nameController.text.split(' ').last,
                  "phone": phoneController.text,
                  "address": addressController.text,
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Update failed')),
                );
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  /// ------------------ TAB 2: DOCUMENTS ------------------
  Widget _buildDocumentsTab() {
    if (documentsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (documents.isEmpty) {
      return const Center(child: Text('No documents uploaded'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];

        Icon icon;
        Color color;

        switch (doc['status']) {
          case 'verified':
            icon = const Icon(Icons.check_circle);
            color = Colors.green;
            break;
          case 'rejected':
            icon = const Icon(Icons.cancel);
            color = Colors.red;
            break;
          default:
            icon = const Icon(Icons.hourglass_empty);
            color = Colors.orange;
        }

        return Card(
          child: ListTile(
            leading: const Icon(Icons.description),
            title: Text(doc['type']),
            subtitle: Text('Status: ${doc['status']}'),
            trailing: Icon(icon.icon, color: color),
          ),
        );
      },
    );
  }

  /// ------------------ TAB 3: REVIEWS ------------------
  Widget _buildReviewsTab() {
    if (reviewsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reviews.isEmpty) {
      return const Center(child: Text('No reviews yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];

        return Card(
          child: ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: Text(review['car']),
            subtitle: Text(review['comment']),
            trailing: Text('${review['rating']}★'),
          ),
        );
      },
    );
  }
}
