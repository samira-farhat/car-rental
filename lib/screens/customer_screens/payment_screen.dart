import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../globals.dart';

class PaymentScreen extends StatefulWidget {
  final int rentalId;

  const PaymentScreen({super.key, required this.rentalId});

  @override
  State<PaymentScreen> createState() => _CustomerPaymentScreenState();
}

class _CustomerPaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  final storage = const FlutterSecureStorage();
  bool isLoading = true;
  bool isPaid = false;
  bool isPaymentData = false; // true if we have payment, false if only rental

  Map<String, dynamic>? paymentData;
  String? selectedMethod;

  final paymentMethods = ['WISH', 'OMT', 'CASH'];
  final methodIcons = {
    'WISH': Icons.account_balance_wallet,
    'OMT': Icons.send_to_mobile,
    'CASH': Icons.money,
  };

  static Color deepBlue = deepMidnightBlue;
  static const Color approveGreen = Color(0xFF2E7D32);
  static const Color rejectRed = Color(0xFFC62828);

  @override
  void initState() {
    super.initState();
    fetchPaymentOrRental();
  }

  /// ===================== API =====================
  Future<void> fetchPaymentOrRental() async {
    setState(() => isLoading = true);
    try {
      final token = await storage.read(key: 'access');
      final response = await http.get(
        Uri.parse(
            'http://localhost:8000/api/payments/by_rental/${widget.rentalId}/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['payment_exists'] == true) {
          paymentData = data['payment'];
          isPaid = true;
          isPaymentData = true;
          selectedMethod = paymentData!['method'];
        } else {
          paymentData = data['rental'];
          isPaid = false;
          isPaymentData = false;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> makePayment() async {
    if (selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final token = await storage.read(key: 'access');

      final response = await http.post(
        Uri.parse('http://localhost:8000/api/payments/create/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'rental': widget.rentalId,
          'method': selectedMethod,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment completed successfully!')),
        );

        await fetchPaymentOrRental();
        isPaid = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Payment failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ===================== UI =====================
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

  Widget _buildInvoiceCard() {
    if (paymentData == null) return const SizedBox.shrink();

    final amount = isPaymentData
        ? paymentData!['amount']
        : paymentData!['totalamount']; // use rental total if no payment
    final method = isPaymentData ? paymentData!['method'] : 'N/A';
    final status = isPaymentData ? paymentData!['status'] : 'pending';

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isPaymentData
                      ? 'Payment #${paymentData!['paymentid']}'
                      : 'Rental #${paymentData!['rentalid']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                _statusBadge(status),
              ],
            ),
            const SizedBox(height: 10),

            // Customer info
            Text(
              paymentData!['user_name'] ??
                  paymentData!['user_id'].toString(),
              style: const TextStyle(
                color: Color(0xFF49C5E0),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (paymentData!['user_email'] != null)
              Text(
                paymentData!['user_email'],
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            const SizedBox(height: 10),

            // Car & rental
            Text('Car: ${paymentData!['car_name'] ?? ''}'),
            Text(
              'Period: ${paymentData!['startdate'] ?? 'N/A'} → ${paymentData!['enddate'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 12),
            ),
            if (paymentData!['duration'] != null)
              Text(
                'Duration: ${paymentData!['duration']}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            const Divider(height: 24),

            // Amount & method
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amount', style: TextStyle(color: Colors.grey.shade600)),
                    Text(
                      '\$${amount ?? 0}',
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
                    Text('Method', style: TextStyle(color: Colors.grey.shade600)),
                    Text(
                      method,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    if (paymentData == null || isPaid) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Choose a Payment Method",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: paymentMethods.map((method) {
            final selected = selectedMethod == method;
            return GestureDetector(
              onTap: () => setState(() => selectedMethod = method),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  color: selected ? deepBlue : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (selected)
                      BoxShadow(
                        color: deepBlue.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(methodIcons[method],
                        color: selected ? Colors.white : Colors.grey.shade700),
                    const SizedBox(width: 8),
                    Text(
                      method,
                      style: TextStyle(
                          color: selected ? Colors.white : Colors.grey.shade700,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: Column(
        children: [
          // Top bar
          Container(
            padding:
            const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PAYMENT STATUS",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Invoice",
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
                    Icons.receipt_long,
                    color: Colors.white,
                    size: 20,
                  ),
                )
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInvoiceCard(),
                  const SizedBox(height: 20),
                  _buildPaymentMethods(),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                      isPaid || isLoading ? null : makePayment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: deepMidnightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                          color: Colors.white)
                          : Text(
                        isPaid
                            ? 'Invoice Already Paid'
                            : 'Pay Now',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
