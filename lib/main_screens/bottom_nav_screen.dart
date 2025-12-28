import 'package:car_management_frontend/screens/customer_screens/profile_screen.dart';
import 'package:car_management_frontend/screens/customer_screens/search_screen.dart';
import 'package:car_management_frontend/screens/customer_screens/wishlist_screen.dart';
import 'package:flutter/material.dart';
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
      Builder(builder: (_) => CarReviewPage()), // second tab: search
      Builder(builder: (_) => WishlistScreen()), // third tab: wishlist
      Builder(builder: (_) => ProfileScreen()), // fourth tab: profile
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
