import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../globals.dart';

class CarImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Stack(
        children: [
          Image.asset(
            'assets/images/car_placeholder.png',
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Icon(
              Icons.favorite,
              color: electricCyan,
            ),
          ),
        ],
      ),
    );
  }
}
