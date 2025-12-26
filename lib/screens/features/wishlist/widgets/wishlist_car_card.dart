import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'car_image.dart';
import 'spec_chip.dart';
import '../../../../globals.dart';

class WishlistCarCard extends StatelessWidget {
  final int carId;

  const WishlistCarCard({required this.carId});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(carId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        wishlistedCarsNotifier.value =
        List.from(wishlistedCarsNotifier.value)..remove(carId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from wishlist')),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.08),
          boxShadow: [
            BoxShadow(
              color: jetBlack.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarImage(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tesla Model S',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      SpecChip(icon: Icons.event_seat, label: '5'),
                      SpecChip(icon: Icons.settings, label: 'Auto'),
                      SpecChip(icon: Icons.flash_on, label: 'Electric'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$120 / day',
                        style: TextStyle(
                          color: electricCyan,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ElevatedButton(
                        style: kElevatedButtonStyle,
                        onPressed: () {},
                        child: const Text('Rent Now'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

