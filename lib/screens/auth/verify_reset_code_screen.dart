import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../globals.dart';
import 'reset_password_screen.dart';

class VerifyResetCodeScreen extends StatefulWidget {
  final String email;

  const VerifyResetCodeScreen({required this.email, super.key});

  @override
  State<VerifyResetCodeScreen> createState() => _VerifyResetCodeScreenState();
}

class _VerifyResetCodeScreenState extends State<VerifyResetCodeScreen>
    with TickerProviderStateMixin {
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;

  int resendCooldown = 0;
  Timer? _timer;

  // ---------------------
  // VERIFY RESET CODE
  // ---------------------
  Future<void> verify() async {
    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse('http://localhost:8000/api/accounts/verify-reset-code/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': widget.email,
        'code': codeController.text.trim(),
      }),
    );

    final data = jsonDecode(response.body);

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: widget.email),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['error'] ?? 'Invalid code')),
      );
    }
  }

  // ---------------------
  // RESEND RESET CODE
  // ---------------------
  Future<void> resendCode() async {
    if (resendCooldown > 0) return;

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse('http://localhost:8000/api/accounts/forgot-password/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': widget.email}),
    );

    setState(() {
      isLoading = false;
      resendCooldown = 60;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response.statusCode == 200
              ? 'Reset code sent'
              : 'Failed to resend code',
        ),
      ),
    );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCooldown == 0) {
        timer.cancel();
      } else {
        setState(() => resendCooldown--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(child: Center(child: _buildCard())),
          _buildLogo(),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text(
              "PASSWORD RESET",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Verify Code",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ]),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: deepMidnightBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.lock_outline, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          'Enter the 6-digit code sent to',
          style: TextStyle(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 4),
        Text(
          widget.email,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: codeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Reset Code',
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (resendCooldown > 0 || isLoading) ? null : resendCode,
            style: kElevatedButtonStyle.copyWith(
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            child: Text(
              resendCooldown > 0
                  ? 'Resend in $resendCooldown s'
                  : 'Resend Code',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF000000), // matches foreground color
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : verify,
            style: ElevatedButton.styleFrom(
              backgroundColor: deepMidnightBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
              'VERIFY',
              style:
              TextStyle(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildLogo() {
    return Container(
      margin: const EdgeInsets.only(bottom: 40, top: 20),
      child: const AppLogo(size: 100),
    );
  }
}
