import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:car_management_frontend/globals.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../main_screens/bottom_nav_screen.dart';
import 'auth_service.dart';

class VerifyAccountScreen extends StatefulWidget {
  final String email;
  final String password;

  const VerifyAccountScreen({required this.email, required this.password, super.key});


  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen>
    with TickerProviderStateMixin {
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;

  // RESEND CODE COOLDOWN
  int resendCooldown = 0;
  Timer? _timer;

  // ---------------------
  // VERIFY ACCOUNT
  // ---------------------
  Future<void> verify() async {
    setState(() => isLoading = true);

    // Step 1: Verify the code
    final verifyResult = await verifyAccount(
      email: widget.email,
      code: codeController.text.trim(),
    );

    if (verifyResult['success'] != true) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(verifyResult['message'] ?? 'Verification failed')),
      );
      return;
    }

    // Step 2: Automatically log in the user and get token
    try {
      final url = Uri.parse('http://localhost:8000/api/accounts/login/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email, 'password': widget.password ?? ''}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save access token
        await const FlutterSecureStorage().write(key: 'access', value: data['access']);

        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account verified and logged in!')),
        );

        // Navigate to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BottomNavScreen(isGuest: false),
          ),
        );
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Login after verification failed')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error connecting to server')),
      );
    }
  }


  Future<Map<String, dynamic>> resendVerificationCode({required String email}) async {
    final uri = Uri.parse('http://localhost:8000/api/accounts/send-verification-code/');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "message": data['message'] ?? "Verification code sent"};
      } else {
        final data = jsonDecode(response.body);
        return {"success": false, "message": data['error'] ?? "Failed to send code"};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
  // ---------------------
  // RESEND VERIFICATION CODE
  // ---------------------
  Future<void> resendCode() async {
    if (resendCooldown > 0) return; // prevent spam

    setState(() {
      isLoading = true;
    });

    final result = await resendVerificationCode(email: widget.email);

    setState(() {
      isLoading = false;
      resendCooldown = 60; // 60-second cooldown
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Unknown error')),
    );

    // Start the countdown
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCooldown == 0) {
        timer.cancel();
      } else {
        setState(() {
          resendCooldown--;
        });
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
          Expanded(
            child: Center(
              child: _buildCard(),
            ),
          ),
          _buildLogoPlaceholder(),
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
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ACCOUNT VERIFICATION",
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Verify Your Email",
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
              Icons.email_outlined,
              color: Colors.white,
              size: 20,
            ),
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
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Enter the 6-digit code sent to',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            widget.email,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: deepMidnightBlue),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: codeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Verification Code',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),

          // -----------------------
          // RESEND VERIFICATION CODE BUTTON WITH COOLDOWN
          // -----------------------
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (isLoading || resendCooldown > 0) ? null : resendCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // or any background color you want
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Colors.grey), // optional border to match design
              ),
              child: Text(
                resendCooldown > 0
                    ? 'Resend in $resendCooldown s'
                    : 'Resend Verification Code',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: resendCooldown > 0 ? Colors.grey : deepMidnightBlue,
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
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(
                color: Colors.white,
              )
                  : const Text(
                'VERIFY',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return Container(
      margin: const EdgeInsets.only(bottom: 40, top: 20),
      child: const AppLogo(size: 100),
    );
  }
}
