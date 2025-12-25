import 'package:flutter/material.dart';


class WishlistScreen extends StatelessWidget {
  final List<int> wishlistedCars; // list of car IDs
  const WishlistScreen({required this.wishlistedCars, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wishlist')),
      body: ListView.builder(
        itemCount: wishlistedCars.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.directions_car),
            title: Text('Car wishlisted: ${wishlistedCars[index]}'),
          );
        },
      ),
    );
  }
}
