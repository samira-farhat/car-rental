import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../globals.dart';

class WishlistAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Your Wishlist',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          Icon(
            Icons.favorite,
            color: electricCyan,
            size: 24,
          ),
        ],
      ),
    );
  }
}
