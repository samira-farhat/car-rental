import 'package:flutter/material.dart';
import '../widgets/dashboard_summary_card.dart';
import 'admin_sidebar.dart';
import 'admin_rentals_page.dart';

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
              padding: const EdgeInsets.all(20.0),
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
                        const SizedBox(width: 48),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Full-width image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/dashboard.jpeg',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // 🔵 GO TO RENTALS APPROVAL BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.assignment_turned_in),
                        label: const Text(
                          'MANAGE RENTALS & PAYMENTS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminRentalsPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: midnightBlue,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Dashboard cards grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: const [
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

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          // Sidebar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: 0,
            bottom: 0,
            left: isSidebarOpen ? 0 : -sidebarWidth,
            child: Container(
              width: sidebarWidth,
              color: midnightBlue.withOpacity(0.85),
              child: AdminSidebar(),
            ),
          ),

          // Overlay
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
