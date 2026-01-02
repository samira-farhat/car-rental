import 'package:flutter/material.dart';

class MakePaymentScreen extends StatefulWidget {
  final int bookingId; // rental/reservation id
  final double totalAmount; // final total

  const MakePaymentScreen({
    Key? key,
    required this.bookingId,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

enum PaymentMethod { card, cash }

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  PaymentMethod _method = PaymentMethod.card;

  final _formKey = GlobalKey<FormState>();
  final _cardNumber = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();

  bool _isProcessing = false;
  bool _paymentSuccess = false;
  String? _receiptId; // dummy for frontend

  @override
  void dispose() {
    _cardNumber.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  String _today() {
    final d = DateTime.now();
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  Future<void> _confirmPayment() async {
    // For cash: no card validation needed.
    if (_method == PaymentMethod.card) {
      if (!_formKey.currentState!.validate()) return;
    }

    setState(() {
      _isProcessing = true;
      _paymentSuccess = false;
      _receiptId = null;
    });

    // fake processing time
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isProcessing = false;
      _paymentSuccess = true;
      _receiptId = "RCPT-${DateTime.now().millisecondsSinceEpoch}";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _method == PaymentMethod.cash
              ? "Payment saved as Pending Verification (cash)."
              : "Payment Successful.",
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _viewReceipt() {
    if (_receiptId == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Payment Receipt"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Receipt ID: $_receiptId"),
            const SizedBox(height: 8),
            Text("Booking ID: ${widget.bookingId}"),
            const SizedBox(height: 8),
            Text("Amount: \$${widget.totalAmount.toStringAsFixed(2)}"),
            const SizedBox(height: 8),
            Text("Method: ${_method == PaymentMethod.card ? "Card" : "Cash"}"),
            const SizedBox(height: 8),
            Text("Date: ${_today()}"),
            const SizedBox(height: 12),
            const Text(
              "Note: This is frontend only for now. Backend receipt will come later.",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            )
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),

                // Logo
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 42,
                    backgroundImage: const AssetImage('assets/images/logo.jpg'),
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

                const SizedBox(height: 8),

                Text(
                  "Pay Date: ${_today()}",
                  style: const TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 24),

                // Summary card
                _whiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Payment Summary",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      _summaryRow("Booking ID", "#${widget.bookingId}"),
                      const SizedBox(height: 8),
                      _summaryRow(
                        "Final Total",
                        "\$${widget.totalAmount.toStringAsFixed(2)}",
                        isBold: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Method selector
                _whiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Payment Method",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _methodTile(
                              title: "Card",
                              icon: Icons.credit_card,
                              selected: _method == PaymentMethod.card,
                              onTap: () => setState(() => _method = PaymentMethod.card),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _methodTile(
                              title: "Cash",
                              icon: Icons.payments,
                              selected: _method == PaymentMethod.cash,
                              onTap: () => setState(() => _method = PaymentMethod.cash),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _method == PaymentMethod.cash
                            ? "Cash payments will be marked as Pending Verification."
                            : "Enter your card details below.",
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Card fields only if card selected
                if (_method == PaymentMethod.card) ...[
                  _whiteCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Card Details",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 12),

                          _fieldWithTitle(
                            title: "Card Number",
                            controller: _cardNumber,
                            hint: "XXXX XXXX XXXX XXXX",
                            keyboard: TextInputType.number,
                            validator: (v) {
                              final value = (v ?? "").replaceAll(" ", "");
                              if (value.isEmpty) return "Card number is required";
                              if (value.length < 12) return "Card number is too short";
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: _fieldWithTitle(
                                  title: "Expiry (MM/YY)",
                                  controller: _expiry,
                                  hint: "MM/YY",
                                  keyboard: TextInputType.number,
                                  validator: (v) {
                                    final value = (v ?? "").trim();
                                    if (value.isEmpty) return "Expiry is required";
                                    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                                      return "Use MM/YY";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _fieldWithTitle(
                                  title: "CVV",
                                  controller: _cvv,
                                  hint: "123",
                                  keyboard: TextInputType.number,
                                  validator: (v) {
                                    final value = (v ?? "").trim();
                                    if (value.isEmpty) return "CVV is required";
                                    if (!RegExp(r'^\d{3}$').hasMatch(value)) {
                                      return "CVV must be 3 digits";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // Processing / success
                if (_isProcessing) ...[
                  const SizedBox(height: 6),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  const Text(
                    "Processing transaction...",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 14),
                ],

                if (_paymentSuccess) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green, size: 22),
                      SizedBox(width: 8),
                      Text(
                        "Payment Completed",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  const SizedBox(height: 14),
                ],

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white70),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _isProcessing ? null : _cancel,
                          child: const Text(
                            "CANCEL",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF49C5E0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _isProcessing ? null : _confirmPayment,
                          child: const Text(
                            "CONFIRM PAYMENT",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Receipt button (only after success)
                if (_paymentSuccess)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _viewReceipt,
                      icon: const Icon(Icons.receipt_long, color: Colors.white),
                      label: const Text(
                        "VIEW RECEIPT",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- UI Helpers ----------

  Widget _whiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }

  Widget _summaryRow(String left, String right, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left, style: const TextStyle(color: Colors.black54)),
        Text(
          right,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _methodTile({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF49C5E0).withOpacity(0.18) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF49C5E0) : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? const Color(0xFF004760) : Colors.black54),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? const Color(0xFF004760) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldWithTitle({
    required String title,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
