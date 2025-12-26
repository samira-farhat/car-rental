import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../globals.dart';

class EmptyWishlist extends StatelessWidget {
  const EmptyWishlist();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border,
              size: 64, color: electricCyan.withOpacity(0.6)),
          const SizedBox(height: 16),
          const Text(
            'Your wishlist is empty',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Save cars you love and rent them anytime.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: kElevatedButtonStyle,
            onPressed: () {},
            child: const Text('Explore Cars'),
          ),
        ],
      ),
    );
  }
}
