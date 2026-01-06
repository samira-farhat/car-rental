import 'package:car_management_frontend/manager_screens/reports.dart';
import 'package:car_management_frontend/manager_screens/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../globals.dart';
import '../main_screens/bottom_nav_screen.dart';
import '../notifications/notifications.dart';
import '../screens/auth/admin_document_screen.dart';
import 'admin_customers_screen.dart';
import 'admin_damages_page.dart';
import 'admin_manage_payments.dart';
import 'admin_reservations_page.dart';
import 'admin_returns_page.dart';
import 'car_manage_page.dart';

class AdminGridDashboard extends StatelessWidget {
  const AdminGridDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_GridItem> items = [
      _GridItem(
        icon: Icons.car_rental,
        title: 'Manage Rentals',
        gradient: LinearGradient(colors: [electricCyan, steelBlue]),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminReservationsPage()),
        ),
      ),
      _GridItem(
        icon: Icons.directions_car,
        title: 'Car Inventory',
        gradient: LinearGradient(colors: [deepMidnightBlue, electricCyan]),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminCarsPage()),
        ),
      ),
      _GridItem(
        icon: Icons.report,
        title: 'Manage Damages',
        gradient: LinearGradient(colors: [steelBlue, electricCyan]),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminDamagesPage()),
        ),
      ),
      _GridItem(
        icon: Icons.people,
        title: 'Customer Info',
        gradient: LinearGradient(colors: [electricCyan, deepMidnightBlue]),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminCustomersListScreen()),
        ),
      ),

      // ===== NEW BUTTONS (NO EXISTING NAVIGATION TOUCHED) =====

      _GridItem(
        icon: Icons.payments,
        title: 'Manage Payments',
        gradient: LinearGradient(colors: [deepMidnightBlue, steelBlue]),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AdminPaymentsScreen()));
        },
      ),
      _GridItem(
        icon: Icons.assignment_return,
        title: 'Return Car',
        gradient: LinearGradient(colors: [electricCyan, deepMidnightBlue]),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AdminReturnsPage()));        },
      ),
      _GridItem(
        icon: Icons.notifications,
        title: 'Notifications',
        gradient: LinearGradient(colors: [steelBlue, electricCyan]),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UserNotificationsPage()));
        },
      ),

      // ===== EXISTING =====

      _GridItem(
        icon: Icons.analytics,
        title: 'Reports',
        gradient: LinearGradient(colors: [deepMidnightBlue, steelBlue]),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminReportsPage()),
        ),
      ),
      _GridItem(
        icon: Icons.settings,
        title: 'Settings',
        gradient: LinearGradient(colors: [electricCyan, steelBlue]),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminSystemSettingsPage()),
        ),
      ),
    ];


    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: kBackgroundGradientLight),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // === NEW TOP BAR ===
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                      // Left Texts
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "DRIVE WITH KHACHAB",
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 10,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Admin Dashboard",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1A1C1E),
                            ),
                          ),
                        ],
                      ),
                      // Right Logo
                      const AppLogo(size: 50),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // === GRID ===
                GridView.builder(
                  itemCount: items.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ElevatedButton(
                      onPressed: item.onTap,
                      style: kElevatedButtonStyle.copyWith(
                        backgroundColor: MaterialStateProperty.all(null),
                        padding: MaterialStateProperty.all(EdgeInsets.zero),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: item.gradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item.icon, size: 48, color: Colors.white),
                              const SizedBox(height: 12),
                              Text(
                                item.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BottomNavScreen(isGuest: false), // admin browsing as customer
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: deepMidnightBlue, // button background
                      foregroundColor: Colors.white, // text color
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'View as Customer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper class to hold grid info
class _GridItem {
  final IconData icon;
  final String title;
  final LinearGradient gradient;
  final VoidCallback onTap;

  _GridItem({
    required this.icon,
    required this.title,
    required this.gradient,
    required this.onTap,
  });
}
