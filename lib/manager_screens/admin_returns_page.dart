import 'package:flutter/material.dart';
import 'return_service.dart';

class AdminReturnsPage extends StatefulWidget {
  const AdminReturnsPage({super.key});

  @override
  State<AdminReturnsPage> createState() => _AdminReturnsPageState();
}

class _AdminReturnsPageState extends State<AdminReturnsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List returns = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    fetchData('pending');

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      fetchData(_tabController.index == 0 ? 'pending' : 'approved');
    });
  }

  Future<void> fetchData(String status) async {
    setState(() => isLoading = true);
    try {
      returns = await ReturnService.fetchReturns(status);
    } catch (_) {}
    setState(() => isLoading = false);
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildList(),
          ),
        ],
      ),
    );
  }

  // ================= UI =================

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
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Returns Management",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          Icon(Icons.assignment_return, size: 28),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF49C5E0),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(text: "PENDING"),
          Tab(text: "APPROVED"),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (returns.isEmpty) {
      return const Center(child: Text("No returns found"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: returns.length,
      itemBuilder: (context, index) {
        final r = returns[index];
        return _returnCard(r);
      },
    );
  }

  Widget _returnCard(Map r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Rental #${r['rental']}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text("Mileage: ${r['mileage']}"),
          Text("Condition: ${r['condition']}"),
          const SizedBox(height: 10),
          if (!r['approved'])
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () async {
                  await ReturnService.approveReturn(r['returnid']);
                  fetchData('pending');
                },
                child: const Text("Approve"),
              ),
            ),
        ],
      ),
    );
  }
}