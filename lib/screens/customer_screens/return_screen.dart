import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReturnScreen extends StatefulWidget {
  final int rentalId;

  const ReturnScreen({Key? key, required this.rentalId}) : super(key: key);

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mileageController = TextEditingController();
  final _commentsController = TextEditingController();
  final storage = const FlutterSecureStorage();

  String _condition = 'excellent';
  bool _isSubmitting = false;

  final Color midnightBlue = const Color(0xFF004760);

  @override
  void dispose() {
    _mileageController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _submitReturn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final token = await storage.read(key: 'access');

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/returns/request/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "rental_id": widget.rentalId,
          "returndatetime": DateTime.now().toIso8601String(),
          "mileage": int.parse(_mileageController.text),
          "condition": _condition,
          "comments": _commentsController.text,
        }),
      );

      if (response.statusCode == 201) {
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Return Submitted"),
            content: const Text(
              "Your return request has been submitted successfully.\n\n"
                  "A manager will review and approve it shortly.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              )
            ],
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        _showError(data['error'] ?? 'Failed to submit return');
      }
    } catch (e) {
      _showError("Network error. Please try again.");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Return Car"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Return Information"),

              _infoRow("Rental ID", "#${widget.rentalId}"),
              _infoRow("Return Date", DateTime.now().toString().substring(0, 16)),

              const SizedBox(height: 25),

              _sectionTitle("Mileage at Return"),
              TextFormField(
                controller: _mileageController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Enter current mileage"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Mileage is required";
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return "Enter a valid mileage";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              _sectionTitle("Car Condition"),
              DropdownButtonFormField<String>(
                value: _condition,
                decoration: _inputDecoration("Condition"),
                items: const [
                  DropdownMenuItem(value: 'excellent', child: Text("Excellent")),
                  DropdownMenuItem(value: 'minor_damage', child: Text("Minor Damage")),
                  DropdownMenuItem(value: 'major_damage', child: Text("Major Damage")),
                ],
                onChanged: (value) => setState(() => _condition = value!),
              ),

              const SizedBox(height: 20),

              _sectionTitle("Comments (Optional)"),
              TextFormField(
                controller: _commentsController,
                maxLines: 3,
                decoration: _inputDecoration("Additional notes"),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReturn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: midnightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "CONFIRM RETURN",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- UI Helpers ----------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
