import 'package:flutter/material.dart';
import '../widgets/dashboard_summary_card.dart';
import 'admin_sidebar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final Color midnightBlue = const Color(0xFF004760);
  bool isSidebarOpen = false;

  void toggleSidebar() {
    setState(() {
      isSidebarOpen = !isSidebarOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double sidebarWidth = 260;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        IconButton(
                          icon: Icon(Icons.menu, color: midnightBlue, size: 28),
                          onPressed: toggleSidebar,
                        ),

                        SizedBox(width: 48),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Full-width image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/dashboard.jpeg',
                        width: double.infinity,
                        fit: BoxFit.cover, // makes it cover full width
                      ),
                    ),

                    SizedBox(height: 30),

                    // Dashboard cards grid
                    GridView.count(
                      shrinkWrap: true, // important: allows grid inside scrollview
                      physics: NeverScrollableScrollPhysics(), // scroll handled by parent
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        DashboardSummaryCard(
                          title: 'Total Cars',
                          value: '10',
                          icon: Icons.directions_car,
                        ),
                        DashboardSummaryCard(
                          title: 'Available Cars',
                          value: '4',
                          icon: Icons.car_rental,
                        ),
                        DashboardSummaryCard(
                          title: 'Rented Cars',
                          value: '5',
                          icon: Icons.car_crash,
                        ),
                        DashboardSummaryCard(
                          title: 'Pending Reservations',
                          value: '2',
                          icon: Icons.pending_actions,
                        ),
                        DashboardSummaryCard(
                          title: 'Approved Reservations',
                          value: '6',
                          icon: Icons.check_circle,
                        ),
                        DashboardSummaryCard(
                          title: 'Active Rentals',
                          value: '1',
                          icon: Icons.timer,
                        ),
                      ],
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),

            ),
          ),

          // Sidebar overlay
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            top: 0,
            bottom: 0,
            left: isSidebarOpen ? 0 : -sidebarWidth,
            child: GestureDetector(
              onTap: () {}, // prevents taps from closing accidentally
              child: Container(
                width: sidebarWidth,
                decoration: BoxDecoration(
                  color: midnightBlue.withOpacity(0.85),
                ),
                child: AdminSidebar(),
              ),
            ),
          ),

          // Dark overlay when sidebar is open
          if (isSidebarOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: toggleSidebar,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
