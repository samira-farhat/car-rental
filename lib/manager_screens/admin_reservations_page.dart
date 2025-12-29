import 'package:flutter/material.dart';
import '../models/reservation_model.dart';

import 'reservation_service.dart';

class AdminReservationsPage extends StatefulWidget {
  const AdminReservationsPage({super.key});

  @override
  State<AdminReservationsPage> createState() =>
      _AdminReservationsPageState();
}

class _AdminReservationsPageState extends State<AdminReservationsPage>
    with SingleTickerProviderStateMixin {
  // Controls the status tabs (Pending / Approved / Rejected)
  late TabController _tabController;

  // Holds reservations fetched from backend
  List<Reservation> reservations = [];

  // Loading indicator flag
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // Initialize tabs
    _tabController = TabController(length: 3, vsync: this);

    // Load pending reservations by default
    fetchData('pending');

    // Reload data when tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;

      final statuses = ['pending', 'approved', 'rejected'];
      fetchData(statuses[_tabController.index]);
    });
  }

  /// Fetch reservations from backend
  Future<void> fetchData(String status) async {
    setState(() => isLoading = true);

    try {
      reservations =
      await ReservationService.fetchReservations(status);
    } catch (e) {
      // In production, show snackbar or error UI
    }

    setState(() => isLoading = false);
  }

  /// Approve handler
  Future<void> approve(int id) async {
    await ReservationService.approveReservation(id);
    fetchData('pending'); // refresh list
  }

  /// Reject handler with dialog
  Future<void> reject(int id) async {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reject Reservation"),
        content: TextField(
          controller: controller,
          decoration:
          const InputDecoration(hintText: "Reason for rejection"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ReservationService.rejectReservation(
                  id, controller.text);
              Navigator.pop(context);
              fetchData('pending');
            },
            child: const Text("Submit"),
          )
        ],
      ),
    );
  }

  /// Single reservation card UI
  Widget reservationCard(Reservation r) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            leading: r.carImage.isNotEmpty
                ? Image.network(r.carImage, width: 60, fit: BoxFit.cover)
                : const Icon(Icons.directions_car),
            title: Text(r.carName),
            subtitle: Text(
              "${r.userName}\n"
                  "${r.startDate.toLocal()} → ${r.endDate.toLocal()}",
            ),
          ),
          if (r.status == 'pending')
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => approve(r.id),
                  child: const Text("Approve"),
                ),
                TextButton(
                  onPressed: () => reject(r.id),
                  child: const Text("Reject"),
                ),
              ],
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Reservations"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Pending"),
            Tab(text: "Approved"),
            Tab(text: "Rejected"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: reservations.length,
        itemBuilder: (_, i) => reservationCard(reservations[i]),
      ),
    );
  }
}
