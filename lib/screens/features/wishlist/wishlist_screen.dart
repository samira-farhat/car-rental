import 'package:car_management_frontend/screens/features/wishlist/widgets/empty_wishlist.dart';
import 'package:car_management_frontend/screens/features/wishlist/widgets/wishlist_app_bar.dart';
import 'package:car_management_frontend/screens/features/wishlist/widgets/wishlist_car_card.dart';
import 'package:car_management_frontend/screens/features/wishlist/widgets/wishlist_header.dart';
import 'package:flutter/material.dart';
import '../../../globals.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: jetBlack,
      body: Container(
        decoration: const BoxDecoration(
          gradient: kBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WishlistAppBar(),
              const SizedBox(height: 12),
              WishlistHeader(),
              const SizedBox(height: 16),
              Expanded(
                child: ValueListenableBuilder<List<int>>(
                  valueListenable: wishlistedCarsNotifier,
                  builder: (context, wishlist, _) {
                    if (wishlist.isEmpty) {
                      return const EmptyWishlist();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: wishlist.length,
                      itemBuilder: (context, index) {
                        return WishlistCarCard(carId: wishlist[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
