import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../globals.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../globals.dart';
import '../screens/customer_screens/reservation_details_screen.dart';
import 'AdminReservationDetailsPage.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen>
    with TickerProviderStateMixin {
  final storage = const FlutterSecureStorage();

  List pendingPayments = [];
  List approvedPayments = [];
  List rejectedPayments = [];
  bool isLoading = true;

  late TabController _tabController;
  late AnimationController _listController;

  static const Color approveGreen = Color(0xFF2E7D32);
  static const Color rejectRed = Color(0xFFC62828);

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    fetchAllPayments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _listController.dispose();
    super.dispose();
  }

  /* ===================== API ===================== */

  Future<List> fetchPaymentsByStatus(String status) async {
    final token = await storage.read(key: 'access');
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/payments/$status/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  Future<void> fetchAllPayments() async {
    setState(() => isLoading = true);

    pendingPayments = await fetchPaymentsByStatus('pending');
    approvedPayments = await fetchPaymentsByStatus('approved');
    rejectedPayments = await fetchPaymentsByStatus('rejected');

    _listController.forward(from: 0);
    setState(() => isLoading = false);
  }

  Future<void> approvePayment(int id) async {
    final token = await storage.read(key: 'access');
    await http.post(
      Uri.parse('http://localhost:8000/api/payments/approve/$id/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    fetchAllPayments();
  }

  Future<void> rejectPayment(int id) async {
    final token = await storage.read(key: 'access');
    await http.post(
      Uri.parse('http://localhost:8000/api/payments/reject/$id/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    fetchAllPayments();
  }

  /* ===================== UI ===================== */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: Column(
        children: [
          _buildTopBar(),
          _buildModernTabs(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : TabBarView(
              controller: _tabController,
              children: [
                _buildPaymentsList(pendingPayments, allowActions: true),
                _buildPaymentsList(approvedPayments, allowActions: false),
                _buildPaymentsList(rejectedPayments, allowActions: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList(List payments, {required bool allowActions}) {
    if (payments.isEmpty) {
      return const Center(
        child: Text(
          'No payments here',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final p = payments[index];
        return AnimatedBuilder(
          animation: _listController,
          builder: (context, child) {
            final slide = Curves.easeOutCubic.transform(
              (_listController.value - (index * 0.1)).clamp(0.0, 1.0),
            );
            return Opacity(
              opacity: slide,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - slide)),
                child: child,
              ),
            );
          },
          child: _buildPaymentCard(p, allowActions: allowActions),
        );
      },
    );
  }

  Widget _buildModernTabs() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: deepMidnightBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        tabs: const [
          Tab(text: "PENDING"),
          Tab(text: "APPROVED"),
          Tab(text: "REJECTED"),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Map p, {required bool allowActions}) {
    return GestureDetector(
      onTap: () {
        if (p['reservationid'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminReservationDetailsPage(
                reservationId: p['reservationid'],
              ),
            ),
          ); // refresh after returning
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment #${p['paymentid']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                _statusBadge(p['status']),
              ],
            ),
            const SizedBox(height: 10),

            /// Customer
            Text(
              p['user_name'] ?? 'Unknown customer',
              style: const TextStyle(
                color: Color(0xFF49C5E0),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              p['user_email'] ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),

            /// Rental info
            Text('Car: ${p['car_name']}'),
            Text(
              'Period: ${p['startdate']} → ${p['enddate']}',
              style: const TextStyle(fontSize: 12),
            ),
            if (p['duration'] != null)
              Text(
                'Duration: ${p['duration']}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            const Divider(height: 24),

            /// Amount & method
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amount',
                        style: TextStyle(color: Colors.grey.shade600)),
                    Text(
                      '\$${p['amount']}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Method',
                        style: TextStyle(color: Colors.grey.shade600)),
                    Text(
                      p['method'],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            /// Actions (only for pending)
            if (allowActions)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _miniActionBtn(
                    Icons.close,
                    rejectRed,
                        () => rejectPayment(p['paymentid']),
                  ),
                  const SizedBox(width: 10),
                  _miniActionBtn(
                    Icons.check,
                    approveGreen,
                        () => approvePayment(p['paymentid']),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _miniActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'completed':
        color = approveGreen;
        label = 'APPROVED';
        break;
      case 'failed':
        color = rejectRed;
        label = 'REJECTED';
        break;
      default:
        color = Colors.orange;
        label = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "FINANCIAL STATUS",
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Payments",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1C1E),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: deepMidnightBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: Colors.white,
              size: 20,
            ),
          )
        ],
      ),
    );
  }
}
