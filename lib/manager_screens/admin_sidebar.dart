import 'package:car_management_frontend/manager_screens/admin_dashboard.dart';
import 'package:car_management_frontend/manager_screens/admin_reservations_page.dart';
import 'package:car_management_frontend/manager_screens/car_manage_page.dart';
import 'package:flutter/material.dart';

class AdminSidebar extends StatelessWidget {
  AdminSidebar({super.key});

  final Color midnightBlue = const Color(0xFF004760);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: midnightBlue.withOpacity(0.20), // lighter for transparency
      ),
      child: Column(
        children: [
          // logo
          SizedBox(
            width: 80, // adjust size
            height: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50), // optional rounding
              child: Image.asset(
                'assets/images/logo.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(height: 12),

          Text(
            "Admin Panel",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 40),

          // menu items
          _sidebarItem(
            icon: Icons.dashboard,
            title: "Dashboard",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminDashboard()),
              );
            },
          ),
          _sidebarItem(
            icon: Icons.car_rental,
            title: "Manage Rentals",
            onTap: () {},
          ),
          _sidebarItem(
            icon: Icons.directions_car,
            title: "Manage Car Inventory",
            onTap: () {},
          ),
          _sidebarItem(
            icon: Icons.report,
            title: "Manage Damages",
            onTap: () {},
          ),
          _sidebarItem(
            icon: Icons.people,
            title: "View Customer Info",
            onTap: () {},
          ),
          _sidebarItem(
            icon: Icons.analytics,
            title: "Generate Reports",
            onTap: () {},
          ),
          _sidebarItem(
            icon: Icons.settings,
            title: "System Settings",
            onTap: () {},
          ),

          Spacer(),

          Divider(color: Colors.white24),

          _sidebarItem(
            icon: Icons.swap_horiz,
            title: "Switch to Customer View",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [

            Icon(icon, color: Colors.white, size: 22),

            SizedBox(width: 16),

            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
