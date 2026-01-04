import 'package:car_management_frontend/globals.dart';
import 'package:flutter/material.dart';
import 'package:car_management_frontend/screens/customer_screens/reservation_list.dart';
import 'package:car_management_frontend/screens/customer_screens/active_rentals_list.dart';

class MyRentalsScreen extends StatefulWidget {
  const MyRentalsScreen({super.key});

  @override
  State<MyRentalsScreen> createState() => _MyRentalsScreenState();
}

class _MyRentalsScreenState extends State<MyRentalsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _listController;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Animate first tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listController.forward(from: 0.0);
    });

    // Track tab changes to trigger horizontal animation
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      _listController.forward(from: 0.0);
      _previousIndex = _tabController.previousIndex;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _listController.dispose();
    super.dispose();
  }

  // Determine slide direction
  double _getOffsetMultiplier(int index) {
    if (index == _tabController.index) return 0;
    return index > _previousIndex ? 1 : -1; // left->right: 1, right->left: -1
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: Column(
        children: [
          _buildTopBar(),
          _buildTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent(MyReservationsList(status: 'pending'), 0),
                _buildTabContent(MyReservationsList(status: 'approved'), 1),
                _buildTabContent(MyActiveRentalsList(), 2),
                _buildTabContent(MyReservationsList(status: 'cancelled'), 3),
                _buildTabContent(MyReservationsList(status: 'history'), 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "MY RENTALS",
                style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Your Fleet",
                style:
                TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1A1C1E)),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: deepMidnightBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.car_rental_outlined, color: Colors.white, size: 20),
          )
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 50,
      decoration: BoxDecoration(
          color: Colors.grey.shade200, borderRadius: BorderRadius.circular(15)),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
            color: deepMidnightBlue, borderRadius: BorderRadius.circular(12)),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        isScrollable: true,
        tabs: const [
          Tab(text: 'Pending'),
          Tab(text: 'Approved'),
          Tab(text: 'Active'),
          Tab(text: 'Cancelled'),
          Tab(text: 'History'),
        ],
      ),
    );
  }

  Widget _buildTabContent(Widget content, int tabIndex) {
    return AnimatedBuilder(
      animation: _listController,
      builder: (context, child) {
        final offsetMultiplier = _getOffsetMultiplier(tabIndex);
        final slide = Curves.easeOut.transform(_listController.value);
        return Transform.translate(
          offset: Offset(300 * (1 - slide) * offsetMultiplier, 0), // horizontal movement
          child: Opacity(opacity: slide, child: child),
        );
      },
      child: content,
    );
  }
}
