import 'package:flutter/material.dart';
import 'package:car_management_frontend/screens/customer_screens/reservation_list.dart';
import 'package:car_management_frontend/screens/customer_screens/active_rentals_list.dart';

class MyRentalsScreen extends StatelessWidget {
  const MyRentalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Active'),
              Tab(text: 'Cancelled'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MyReservationsList(status: 'pending'),
            MyReservationsList(status: 'approved'),
            MyActiveRentalsList(),
            MyReservationsList(status: 'cancelled'),
            MyReservationsList(status: 'history'),
          ],
        ),
      ),
    );
  }
}
