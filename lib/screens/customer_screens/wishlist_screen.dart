import 'package:flutter/material.dart';
import '../../globals.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<List<int>>(
        valueListenable: wishlistedCarsNotifier,
        builder: (context, wishlisted, child) {
          if (wishlisted.isEmpty) {
            return Center(child: Text("No cars wishlisted yet"));
          }

          // For now, we just display IDs
          return ListView.builder(
            itemCount: wishlisted.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(Icons.directions_car),
                title: Text("Car ID: ${wishlisted[index]}"),
              );
            },
          );
        },
      ),
    );
  }
}
