import 'package:car_management_frontend/screens/customer_screens/my_rentals_screen.dart';
import 'package:car_management_frontend/screens/customer_screens/profile_screen.dart';
import 'package:car_management_frontend/screens/customer_screens/search_screen.dart';
import 'package:car_management_frontend/screens/customer_screens/wishlist_screen.dart';
import 'package:flutter/material.dart';
import '../manager_screens/admin_dashboard.dart';
import '../manager_screens/admin_reservations_page.dart';
import '../manager_screens/car_manage_page.dart';
import '../screens/customer_screens/browse_screen.dart';
import '../screens/features/reviews_screen.dart';

class BottomNavScreen extends StatefulWidget {
  final bool isGuest; // true if browsing as guest
  BottomNavScreen({this.isGuest = true});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;

  final Color midnightBlue = Color(0xFF004760);

  // List of widgets to display for each tab
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      Builder(builder: (_) => BrowseScreen(isGuest: widget.isGuest)), // first tab: browse cars
      Builder(builder: (_) => SearchScreen()), // second tab: search
      Builder(builder: (_) => MyRentalsScreen()), // third tab: my rentals
      Builder(builder: (_) => WishlistScreen()), // fourth tab: wishlist
      Builder(builder: (_) => ProfileScreen()), // fifth tab: profile
    ];
  }

  void _onTabTapped(int index) {
    // If guest clicks on any tab other than browse (0), go to login
    if (widget.isGuest && index != 0) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: midnightBlue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),

          // CENTER – My Rentals
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: midnightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.receipt_long, // rentals icon
                color: Colors.white,
                size: 26,
              ),
            ),
            label: 'Rentals',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],

      ),
    );
  }
}
