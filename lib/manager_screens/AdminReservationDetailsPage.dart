import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../globals.dart';


class AdminReservationDetailsPage extends StatefulWidget {
  final int reservationId;

  const AdminReservationDetailsPage({
    super.key,
    required this.reservationId,
  });

  @override
  State<AdminReservationDetailsPage> createState() =>
      _AdminReservationDetailsPageState();
}

class _AdminReservationDetailsPageState
    extends State<AdminReservationDetailsPage> with SingleTickerProviderStateMixin {
  final storage = const FlutterSecureStorage();
  bool isLoading = true;
  Map<String, dynamic>? reservation;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    fetchReservationDetails();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> fetchReservationDetails() async {
    final token = await storage.read(key: 'access');
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/admin/reservations/${widget.reservationId}/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          reservation = json.decode(response.body);
          isLoading = false;
        });
        _animController.forward();
      }
    } else {
      throw Exception('Failed to load reservation details');
    }
  }

  Future<void> adminAction(String action) async {
    final token = await storage.read(key: 'access');
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/admin/reservations/${widget.reservationId}/$action/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      fetchReservationDetails();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Action failed'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> approveReservation() => adminAction('approve');
  Future<void> rejectReservation() => adminAction('reject');

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Color(0xFF49C5E0))),
      );
    }

    final r = reservation!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('RESERVATION #${r['reservationid']}',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1.5)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _animate(index: 0, child: _buildHeroSection(r)),
            const SizedBox(height: 25),
            _animate(index: 1, child: _buildSectionTitle('Vehicle Specifications')),
            _animate(index: 2, child: _buildCarSpecsGrid(r['car'])),
            const SizedBox(height: 25),
            _animate(index: 3, child: _buildSectionTitle('Customer Information')),
            _animate(index: 4, child: _buildUserCard(r)),
            if (r['license'] != null) ...[
              _animate(index: 5, child: _buildSectionTitle('Driver License')),
              _animate(index: 6, child: _buildLicenseCard(r['license'])),
            ],
            const SizedBox(height: 25),
            _animate(index: 7, child: _buildSectionTitle('Booking Summary')),
            _animate(index: 8, child: _buildBookingCard(r)),
            const SizedBox(height: 20),
            _animate(index: 9, child: Center(
                child: Text('Booked on: ${r['createdat']}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12)))),
            const SizedBox(height: 30),
            if (r['status'] == 'pending')
              _animate(index: 10, child: _buildActionButtons()),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildHeroSection(Map<String, dynamic> r) {
    return Column(
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: DecorationImage(
              image: NetworkImage('${r['car']['image_url']}'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(r['car']['car_name'],
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1A1C1E))),
            _statusChip(r['status']),
          ],
        ),
      ],
    );
  }

  Widget _buildCarSpecsGrid(Map<String, dynamic> car) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _specTile('VIN', car['vin'].toString(), Icons.fingerprint),
        _specTile('Rate', '\$${car['rentalpriceperday']}/day', Icons.sell_outlined),
        _specTile('Status', car['availabilitystatus'], Icons.info_outline),
        _specTile('Type', 'Premium', Icons.star_border),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> r) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _infoRow(Icons.person_outline, 'Name', r['user_name']),
          const Divider(height: 24),
          _infoRow(Icons.phone_android_outlined, 'Phone', r['user_phone']),
          const Divider(height: 24),
          _infoRow(Icons.email_outlined, 'Email', r['user_email']),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> r) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: deepMidnightBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _darkInfoRow('Start Date', r['startdate']),
          _darkInfoRow('End Date', r['enddate']),
          _darkInfoRow('Duration', '${r['duration']} days'),
          const Divider(color: Colors.white24, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(color: Colors.white70, fontSize: 16)),
              Text('\$${r['total_amount']}',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: rejectReservation,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              side: const BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('REJECT', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            onPressed: approveReservation,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF49C5E0),
              padding: const EdgeInsets.symmetric(vertical: 18),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('APPROVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildLicenseCard(Map<String, dynamic> license) {
    final String url = license['image_url'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge_outlined, color: Color(0xFF49C5E0)),
              const SizedBox(width: 10),
              Text(
                'STATUS: ${license['status'].toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              url,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER UI ---
  Widget _animate({required int index, required Widget child}) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _animController, curve: Interval(index * 0.05, 0.6, curve: Curves.easeIn)),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Interval(index * 0.05, 0.6, curve: Curves.easeOutCubic)),
        ),
        child: child,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 5),
      child: Text(title.toUpperCase(),
          style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
    );
  }

  Widget _specTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF49C5E0)),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
      ],
    );
  }

  Widget _darkInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color = status == 'pending' ? Colors.orange : (status == 'approved' ? Colors.green : Colors.red);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(),
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
