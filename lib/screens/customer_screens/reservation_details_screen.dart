import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../globals.dart';
import 'make_payment_screen.dart';

class ReservationDetailsScreen extends StatefulWidget {
  final int reservationId;

  const ReservationDetailsScreen({super.key, required this.reservationId});

  @override
  State<ReservationDetailsScreen> createState() =>
      _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState
    extends State<ReservationDetailsScreen>
    with SingleTickerProviderStateMixin {
  final storage = const FlutterSecureStorage();
  late AnimationController _animController;
  final Color midnightBlue = const Color(0xFF004760);

  Map? reservation;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animController.forward();
    fetchReservation();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> fetchReservation() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final token = await storage.read(key: 'access');
      final response = await http.get(
        Uri.parse(
            'http://localhost:8000/api/reservations/${widget.reservationId}/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          reservation = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> cancelReservation() async {
    final token = await storage.read(key: 'access');

    await http.post(
      Uri.parse(
        'http://localhost:8000/api/reservations/${widget.reservationId}/cancel/',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError || reservation == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Failed to load reservation details',
            style: TextStyle(color: Colors.red.shade700, fontSize: 16),
          ),
        ),
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
        title: Text(
          'RESERVATION #${r['reservationid'] ?? 'N/A'}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // car image + status chip
            _animate(index: 0, child: _buildHeroSection(r)),

            const SizedBox(height: 25),

            // car details
            _animate(index: 1, child: _buildSectionTitle('Vehicle Details')),
            _animate(index: 2, child: _buildCarSpecsGrid(r)),

            const SizedBox(height: 25),

            // booking summary
            _animate(index: 3, child: _buildSectionTitle('Booking Summary')),
            _animate(index: 4, child: _buildBookingCard(r)),

            if ((r['rejectionreason'] ?? '').isNotEmpty) ...[
              const SizedBox(height: 25),
              _animate(index: 5, child: _buildSectionTitle('Rejection Reason')),
              _animate(
                index: 6,
                child: _buildRejectionCard(
                  r['rejectionreason'] ?? 'No reason provided',
                ),
              ),
            ],

            const SizedBox(height: 30),

            // buttons
            if (r['status'] == 'pending' || r['status'] == 'approved')
              _animate(index: 7, child: _buildActionButtons(r)),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // UI
  Widget _buildHeroSection(Map r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: DecorationImage(
              image: NetworkImage(
                  r['car_image'] ?? 'https://via.placeholder.com/400x220'),
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              r['car_name'] ?? 'Unknown Vehicle',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1C1E),
              ),
            ),
            _statusChip(r['status'] ?? 'pending'),
          ],
        ),
      ],
    );
  }

  Widget _buildCarSpecsGrid(Map r) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _specTile('Category', r['category'] ?? 'N/A', Icons.category_outlined),
        _specTile('Year', r['year']?.toString() ?? 'N/A', Icons.calendar_today_outlined),
        _specTile('Start Date', r['startdate'] ?? 'N/A', Icons.play_arrow),
        _specTile('End Date', r['enddate'] ?? 'N/A', Icons.stop),
      ],
    );
  }

  Widget _buildBookingCard(Map r) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: deepMidnightBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _darkInfoRow('Duration', '${r['duration'] ?? 0} days'),

          const Divider(color: Colors.white24, height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),

              Text(
                '\$${(r['total_amount'] ?? 0).toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRejectionCard(String reason) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: Text(
        reason,
        style: const TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map r) {
    return Column(
      children: [
        if (r['status'] == 'approved')
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/payment');
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                side: BorderSide(color: midnightBlue),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'RENT NOW',
                style: TextStyle(
                  color: midnightBlue,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => cancelReservation(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              side: const BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'CANCEL RESERVATION',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _animate({required int index, required Widget child}) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animController,
        curve: Interval(index * 0.05, 0.7, curve: Curves.easeIn),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animController,
            curve: Interval(index * 0.05, 0.7, curve: Curves.easeOutCubic),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 5),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
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
                Text(label,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 10)),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _darkInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color = status == 'pending'
        ? Colors.lightBlue
        : status == 'approved'
        ? Colors.orange
        : status == 'completed'
        ? Colors.green
        : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

}
