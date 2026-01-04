import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../globals.dart';
import 'admin_damages_page.dart' hide baseUrl; // for colors, etc.

class AdminSystemSettingsPage extends StatefulWidget {
  const AdminSystemSettingsPage({super.key});

  @override
  State<AdminSystemSettingsPage> createState() =>
      _AdminSystemSettingsPageState();
}

class _AdminSystemSettingsPageState extends State<AdminSystemSettingsPage>
    with TickerProviderStateMixin {
  final storage = const FlutterSecureStorage();
  bool isLoading = true;
  Map<String, List<dynamic>> settingsByCategory = {}; // grouped by category
  late TabController _tabController;
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    fetchSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<void> fetchSettings() async {
    final token = await storage.read(key: 'access');

    setState(() => isLoading = true);

    final response = await http.get(
      Uri.parse('$baseUrl/settings/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> allSettings = json.decode(response.body);

      final Map<String, List<dynamic>> grouped = {};
      for (var s in allSettings) {
        grouped.putIfAbsent(s['category'], () => []).add(s);
      }

      if (!mounted) return;

      _listController.reset(); // reset BEFORE rendering new widgets

      setState(() {
        settingsByCategory = grouped;
        isLoading = false;
      });

      _listController.forward(); // animate cards in
    } else {
      throw Exception('Failed to load settings');
    }
  }

  Future<void> saveSetting(Map<String, dynamic> setting, String newValue) async {
    final token = await storage.read(key: 'access');
    final response = await http.patch(
      Uri.parse('$baseUrl/settings/${setting['setting_id']}/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'value': newValue}),
    );

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save ${setting['key_name']}'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Refetch to ensure fresh value immediately
      fetchSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          _buildTopBar(),
          _buildModernTabs(),
          Expanded(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF49C5E0)),
            )
                : TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryTab('general'),
                _buildCategoryTab('security'),
                _buildCategoryTab('system'),
                _buildCategoryTab('notification'),
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
                "SYSTEM CONTROLS",
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Settings",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1C1E),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: electricCyan,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
          )
        ],
      ),
    );
  }

  Widget _buildModernTabs() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF49C5E0),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        tabs: const [
          Tab(text: "GENERAL"),
          Tab(text: "SECURITY"),
          Tab(text: "SYSTEM"),
          Tab(text: "NOTIFICATION"),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String category) {
    final settings = settingsByCategory[category] ?? [];
    if (settings.isEmpty) {
      return const Center(child: Text("No settings found."));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: List.generate(settings.length, (index) {
          final s = settings[index];
          return AnimatedBuilder(
            animation: _listController,
            builder: (context, child) {
              final slide = Curves.easeOutCubic
                  .transform((_listController.value - (index * 0.05)).clamp(0.0, 1.0));
              return Opacity(
                opacity: slide,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - slide)),
                  child: child,
                ),
              );
            },
            child: _buildSettingTile(s),
          );
        }),
      ),
    );
  }

  Widget _buildSettingTile(Map<String, dynamic> s) {
    Widget input;

    switch (s['data_type']) {
      case 'boolean':
        input = Switch(
          value: s['value'].toString().toLowerCase() == 'true',
          onChanged: (v) {
            s['value'] = v.toString();
            saveSetting(s, v.toString());
          },
        );
        break;
      default:
        input = SizedBox(
          width: 250, // Wider text field
          child: TextFormField(
            initialValue: s['value'],
            onFieldSubmitted: (v) => saveSetting(s, v),
          ),
        );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Text(s['key_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: input,
      ),
    );
  }
}
