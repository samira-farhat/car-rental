import 'package:flutter/material.dart';
import '../models/reservation_model.dart';
import 'AdminReservationDetailsPage.dart';
import 'reservation_service.dart';

class AdminReservationsPage extends StatefulWidget {
  const AdminReservationsPage({super.key});

  @override
  State<AdminReservationsPage> createState() => _AdminReservationsPageState();
}

class _AdminReservationsPageState extends State<AdminReservationsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _listController;
  List<Reservation> reservations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    fetchData('pending');

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      fetchData(['pending', 'approved', 'rejected'][_tabController.index]);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<void> fetchData(String status) async {
    setState(() => isLoading = true);
    try {
      reservations = await ReservationService.fetchReservations(status);
    } catch (e) {
      debugPrint(e.toString());
    }
    if (mounted) {
      setState(() => isLoading = false);
      _listController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: Column(
        children: [
          _buildTopBar(),
          _buildModernTabs(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : _buildContent(),
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
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("FLEET STATUS", style: TextStyle(color: Colors.grey.shade400, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text("Operations", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1A1C1E))),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 20),
          )
        ],
      ),
    );
  }

  Widget _buildModernTabs() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 50,
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(15)),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(color: const Color(0xFF49C5E0), borderRadius: BorderRadius.circular(12)),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        tabs: const [Tab(text: "PENDING"), Tab(text: "APPROVED"), Tab(text: "REJECTED")],
      ),
    );
  }

  Widget _buildContent() {
    if (reservations.isEmpty) return const Center(child: Text("No active logs found."));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final r = reservations[index];
        return AnimatedBuilder(
          animation: _listController,
          builder: (context, child) {
            final slide = Curves.easeOutCubic.transform((_listController.value - (index * 0.1)).clamp(0.0, 1.0));
            return Opacity(
              opacity: slide,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - slide)),
                child: child,
              ),
            );
          },
          child: _buildGlassCard(r),
        );
      },
    );
  }

  Widget _buildGlassCard(Reservation r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminReservationDetailsPage(reservationId: r.reservationid))),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network('http://localhost:8000/media/${r.carImage}', width: 90, height: 90, fit: BoxFit.contain),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.carName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(r.userName, style: const TextStyle(color: Color(0xFF49C5E0), fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                      child: Text("${r.startDate.day}/${r.startDate.month} - ${r.endDate.day}/${r.endDate.month}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                  ],
                ),
              ),
              if (r.status == 'pending')
                Column(
                  children: [
                    _miniActionBtn(Icons.check, Colors.green, () => ReservationService.approveReservation(r.reservationid).then((_) => fetchData('pending'))),
                    const SizedBox(height: 8),
                    _miniActionBtn(Icons.close, Colors.red, () => _showRejectDialog(r.reservationid)),
                  ],
                )
              else
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  void _showRejectDialog(int id) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Log Rejection"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Enter reason...")),
        actions: [TextButton(onPressed: () => ReservationService.rejectReservation(id, controller.text).then((_) { Navigator.pop(context); fetchData('pending'); }), child: const Text("Submit"))],
      ),
    );
  }
}