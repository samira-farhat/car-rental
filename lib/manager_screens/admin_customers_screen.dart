import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:car_management_frontend/globals.dart';
import 'admin_customer_details_screen.dart' hide deepMidnightBlue;

class AdminCustomersListScreen extends StatefulWidget {
  const AdminCustomersListScreen({super.key});

  @override
  State<AdminCustomersListScreen> createState() =>
      _AdminCustomersListScreenState();
}

class _AdminCustomersListScreenState extends State<AdminCustomersListScreen> {
  bool loading = true;
  List customers = [];

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'access');
    if (token == null) return;

    final response = await http.get(
      Uri.parse('http://localhost:8000/api/accounts/admin/customers/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        customers = jsonDecode(response.body);
        loading = false;
      });
    } else {
      setState(() => loading = false);
      print("Failed to fetch customers: ${response.body}");
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
            child: loading
                ? const Padding(
              padding: EdgeInsets.only(top: 60),
              child: Center(child: CircularProgressIndicator()),
            )
                : customers.isEmpty
                ? const Padding(
              padding: EdgeInsets.only(top: 60),
              child: Center(child: Text('No customers found')),
            )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: List.generate(customers.length, (index) {
                  final c = customers[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminCustomerDetailsScreen(
                                    customerId: c['id']),
                          ),
                        );
                      },
                      child: _customerCard(c),
                    ),
                  );
                }),
              ),
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
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "ADMIN",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Customers",
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

  Widget _customerCard(Map c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            child: const Icon(Icons.person, color: Colors.white,),
            backgroundColor: deepMidnightBlue,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c['full_name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  c['email'],
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  c['phone'],
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey.shade400,
          )
        ],
      ),
    );
  }
}
