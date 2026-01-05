import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MakePaymentScreen extends StatefulWidget {
  final int bookingId; // reservation id

  const MakePaymentScreen({
    Key? key,
    required this.bookingId,
  }) : super(key: key);

  @override
  State<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  bool _isProcessing = false;
  bool _paymentSuccess = false;

  String? _receiptId;
  double? _backendTotal;
  String? _backendPaymentStatus;
  int? _backendRentalId;

  static const Color kPrimary = Color(0xFF49C5E0);
  static const Color kDarkBlue = Color(0xFF004760);

  String _today() {
    final d = DateTime.now();
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  Future<void> _confirmPayment() async {
    setState(() {
      _isProcessing = true;
      _paymentSuccess = false;
    });

    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'access');

      final response = await http.post(
        Uri.parse('http://localhost:8000/api/payments/make-payment/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "reservation": widget.bookingId,
          "method": "cash",
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _paymentSuccess = true;
          _receiptId = data['payment_id']?.toString();
          _backendRentalId = int.tryParse(data['rental_id'].toString());
          _backendTotal =
              double.tryParse(data['total_amount'].toString()) ?? 0.0;
          _backendPaymentStatus = data['payment_status'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Cash payment saved as Pending Verification."),
            backgroundColor: kPrimary,
          ),
        );
      } else {
        throw "Payment failed.";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _viewInvoice() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reservation Invoice"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Invoice ID: $_receiptId"),
            Text("Reservation ID: ${widget.bookingId}"),
            if (_backendRentalId != null)
              Text("Rental ID: $_backendRentalId"),
            Text("Amount: \$${_backendTotal?.toStringAsFixed(2)}"),
            const Text("Method: Cash"),
            Text("Status: ${_backendPaymentStatus?.toUpperCase()}"),
            Text("Date: ${_today()}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalText = (_backendTotal == null)
        ? "Will be calculated by backend"
        : "\$${_backendTotal!.toStringAsFixed(2)}";

    return Scaffold(
      body: Container(
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
              children: [
                // 🔙 BACK BUTTON
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 10),

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
                  "Make Payment",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Pay Date: ${_today()}",
                  style: const TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 24),

                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Payment Summary",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _row("Reservation ID", "#${widget.bookingId}"),
                      _row("Final Total", totalText, bold: true),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Payment Method",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      ListTile(
                        leading:
                        Icon(Icons.payments, color: Colors.green),
                        title: Text("Cash"),
                        subtitle: Text("Pay at pickup / office"),
                        trailing: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                        child: const Text("CANCEL"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (_isProcessing || _paymentSuccess)
                            ? null
                            : _confirmPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                        ),
                        child: const Text("CONFIRM PAYMENT"),
                      ),
                    ),
                  ],
                ),

                if (_paymentSuccess) ...[
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _viewInvoice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                    ),
                    icon: const Icon(Icons.receipt_long),
                    label: const Text("VIEW INVOICE"),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: child,
  );

  Widget _row(String l, String r, {bool bold = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(l, style: const TextStyle(color: Colors.black54)),
      Text(
        r,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    ],
  );
}
