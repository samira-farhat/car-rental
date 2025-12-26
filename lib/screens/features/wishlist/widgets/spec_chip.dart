import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../globals.dart';

class SpecChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const SpecChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: electricCyan),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
