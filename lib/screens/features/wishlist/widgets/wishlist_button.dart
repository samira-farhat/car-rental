import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WishlistButton extends StatefulWidget {
  final int carId;
  final bool initiallyWishlisted;

  const WishlistButton({required this.carId, this.initiallyWishlisted = false, Key? key}) : super(key: key);

  @override
  State<WishlistButton> createState() => _WishlistButtonState();
}

class _WishlistButtonState extends State<WishlistButton> {
  bool isWishlisted = false;

  @override
  void initState() {
    super.initState();
    isWishlisted = widget.initiallyWishlisted;
  }

  Future<void> toggleWishlist() async {
    final url = Uri.parse('http://192.168.10.20/api/wishlist/toggle/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token YOUR_USER_TOKEN', // token from login
        },
        body: jsonEncode({'car_id': widget.carId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          isWishlisted = data['wishlisted'];
        });
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Network error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isWishlisted ? Icons.favorite : Icons.favorite_border,
        color: isWishlisted ? Colors.red : Colors.black,
      ),
      onPressed: toggleWishlist,
    );
  }
}
