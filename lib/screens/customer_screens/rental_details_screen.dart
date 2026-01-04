import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../globals.dart';
import 'return_screen.dart';

class RentalDetailsScreen extends StatefulWidget {
  final int rentalId;

  const RentalDetailsScreen({super.key, required this.rentalId});

  @override
  State<RentalDetailsScreen> createState() => _RentalDetailsScreenState();
}

class _RentalDetailsScreenState extends State<RentalDetailsScreen>
    with SingleTickerProviderStateMixin {
  final storage = const FlutterSecureStorage();
  late AnimationController _animController;
  final Color midnightBlue = const Color(0xFF004760);

  Map<String, dynamic>? rental;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _animController.forward();
    fetchRental();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> fetchRental() async {
    try {
      final token = await storage.read(key: 'access');

      final response = await http.get(
        Uri.parse('http://localhost:8000/api/rentals/${widget.rentalId}/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          rental = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError || rental == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Failed to load rental details',
            style: TextStyle(color: Colors.red.shade700, fontSize: 16),
          ),
        ),
      );
    }

    final r = rental!;

    final total = double.tryParse(r['totalamount']?.toString() ?? '0') ?? 0;

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
          'RENTAL #${r['rentalid'] ?? 'N/A'}',
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

            // Hero section (car image + status)
            _animate(index: 0, child: _buildHeroSection(r)),

            const SizedBox(height: 25),

            // Vehicle details
            _animate(index: 1, child: _buildSectionTitle('Vehicle Details')),
            _animate(index: 2, child: _buildCarSpecsGrid(r)),

            const SizedBox(height: 25),

            // Rental summary
            _animate(index: 3, child: _buildSectionTitle('Rental Summary')),
            _animate(index: 4, child: _buildBookingCard(r, total)),

            const SizedBox(height: 30),

            // Return button if active
            if (r['status'] == 'active')
              _animate(index: 5, child: _buildReturnButton()),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // ================= UI =================

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
                r['car_image'] ?? 'https://via.placeholder.com/400x220',
              ),
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
              ),
            ),
            _statusChip(r['status'] ?? 'active'),
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
        _specTile('Start Date', r['startdate'] ?? 'N/A', Icons.play_arrow),
        _specTile('End Date', r['enddate'] ?? 'N/A', Icons.stop),
        _specTile('Status', r['status'] ?? 'N/A', Icons.info_outline),
      ],
    );
  }

  Widget _buildBookingCard(Map r, double total) {
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
              const Text('Total Amount', style: TextStyle(color: Colors.white70)),
              Text(
                '\$${total.toStringAsFixed(2)}',
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

  Widget _buildReturnButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReturnScreen(rentalId: widget.rentalId),
            ),

          );
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          side: BorderSide(color: midnightBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          'RETURN NOW',
          style: TextStyle(
            color: midnightBlue,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  // Animations
  Widget _animate({required int index, required Widget child}) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animController,
        curve: Interval(index * 0.05, 0.7, curve: Curves.easeIn),
      ),
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.1), end: Offset.zero)
            .animate(_animController),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _darkInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60)),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _statusChip(String status) {
    Color color = status == 'active'
        ? Colors.green
        : status == 'completed'
        ? Colors.blue
        : Colors.orange;

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
