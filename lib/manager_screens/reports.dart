import 'dart:convert';
import 'package:car_management_frontend/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

const String baseUrl = "http://localhost:8000/api";

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  final storage = const FlutterSecureStorage();

  String reportType = "financial";
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();

  bool loading = false;
  Map<String, dynamic> reportData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: Column(
        children: [
          _header(),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _filters(),
                  const SizedBox(height: 24),
                  if (reportData.isNotEmpty) _reportDefinition(),
                  if (reportData.isNotEmpty) _kpiSection(),
                  if (reportData.isNotEmpty) _chartsSection(),
                  if (reportData.isNotEmpty) _scopeNote(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* ───────────────────────── HEADER ───────────────────────── */

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("REPORTS",
                  style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold)),
              Text("Analytics Dashboard",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            ],
          ),
          IconButton(
            onPressed: _generateReport,
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: deepMidnightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  /* ───────────────────────── FILTERS ───────────────────────── */

  Widget _filters() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: reportType,
          decoration: _input("Report Type"),
          items: const [
            DropdownMenuItem(value: "financial", child: Text("FINANCIAL REPORT")),
            DropdownMenuItem(value: "rental_history", child: Text("RENTAL HISTORY REPORT")),
            DropdownMenuItem(value: "operational", child: Text("OPERATIONAL REPORT")),
          ],
          onChanged: (v) => setState(() => reportType = v!),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _datePicker("Start Date", startDate, (d) => startDate = d)),
            const SizedBox(width: 16),
            Expanded(child: _datePicker("End Date", endDate, (d) => endDate = d)),
          ],
        ),
      ],
    );
  }

  /* ───────────────────────── REPORT DEFINITION ───────────────────────── */

  Widget _reportDefinition() {
    final defs = {
      "financial":
      "Summarizes revenue and payments completed during the selected period.\n\n"
          "• Rentals are counted by creation date\n"
          "• Only completed payments are included\n"
          "• Rental status does not affect income",
      "rental_history":
      "Analyzes rentals that occurred within the selected period.\n\n"
          "• Rentals are counted by rental dates\n"
          "• Revenue includes only completed rentals\n"
          "• Focused on customer activity",
      "operational":
      "Evaluates fleet usage and operational performance.\n\n"
          "• Rentals counted if fully within the period\n"
          "• Includes all rental statuses\n"
          "• Focused on utilization and system health",
    };

    return _infoCard("Report Definition", defs[reportType]!);
  }

  /* ───────────────────────── KPI SECTION ───────────────────────── */

  Widget _kpiSection() {
    final summary = Map<String, dynamic>.from(reportData['summary'] ?? {});
    if (summary.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text("Key Metrics",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: summary.entries
              .where((e) => e.value is num || e.value is String)
              .map((e) => _kpiCard(_labelFor(e.key), _formatValue(e.key, e.value)))
              .toList(),
        ),
      ],
    );
  }

  Widget _kpiCard(String title, String value) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /* ───────────────────────── CHARTS ───────────────────────── */

  Widget _chartsSection() {
    final charts = Map<String, dynamic>.from(reportData['charts'] ?? {});

    if (reportType == "financial") {
      final List data = List.from(charts['monthly_income'] ?? []);
      return _lineChart(
        "Monthly Revenue Trend",
        data.map((e) => _Point(e['month'], (e['total'] as num).toDouble())).toList(),
      );
    }

    if (reportType == "rental_history") {
      final List data = List.from(charts['monthly_rentals'] ?? []);
      return _lineChart(
        "Monthly Rental Volume",
        data.map((e) => _Point(e['month'], (e['count'] as num).toDouble())).toList(),
      );
    }

    if (reportType == "operational") {
      final Map status = Map<String, dynamic>.from(
          reportData['summary']?['car_status_counts'] ?? {});
      return _pieChart(
        "Fleet Status Distribution",
        status.entries
            .map((e) => _Point(e.key, (e.value as num).toDouble()))
            .toList(),
      );
    }

    return const SizedBox();
  }

  /* ───────────────────────── HELPERS ───────────────────────── */

  Future<void> _generateReport() async {
    setState(() => loading = true);
    final token = await storage.read(key: "access");

    final uri = Uri.parse(
        "$baseUrl/reports/generate/?type=$reportType&start_date=${DateFormat('yyyy-MM-dd').format(startDate)}&end_date=${DateFormat('yyyy-MM-dd').format(endDate)}");

    final res = await http.get(uri, headers: {"Authorization": "Bearer $token"});

    setState(() {
      loading = false;
      reportData = res.statusCode == 200 ? jsonDecode(res.body) : {};
    });
  }

  String _labelFor(String key) {
    const labels = {
      "total_income": "Total Revenue",
      "total_rentals": "Rentals Counted",
      "total_revenue": "Rental Revenue",
      "avg_duration": "Avg Rental Duration (Days)",
      "total_cars": "Total Fleet Size",
      "total_damages": "Reported Damages",
      "open_claims": "Open Damage Claims",
    };
    return labels[key] ?? key.replaceAll('_', ' ').toUpperCase();
  }

  String _formatValue(String key, dynamic value) {
    if (key.contains("income") || key.contains("revenue")) {
      return "\$${NumberFormat('#,##0.00').format(value)}";
    }
    return value.toString();
  }

  Widget _scopeNote() {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Text(
        "Note: Metrics may differ across report types because each report "
            "uses distinct business rules and date logic.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
    );
  }
  Widget _datePicker(
      String label,
      DateTime value,
      ValueChanged<DateTime> onPicked,
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );

        if (picked != null) {
          setState(() => onPicked(picked));
        }
      },
      child: InputDecorator(
        decoration: _input(label).copyWith(
          prefixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          DateFormat('yyyy-MM-dd').format(value),
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Widget _infoCard(String title, String body) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _lineChart(String title, List<_Point> data) {
    return _chartContainer(
      title,
      SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        series: [
          SplineSeries<_Point, String>(
            dataSource: data,
            xValueMapper: (p, _) => p.x,
            yValueMapper: (p, _) => p.y,
          )
        ],
      ),
    );
  }

  Widget _pieChart(String title, List<_Point> data) {
    return _chartContainer(
      title,
      SfCircularChart(
        legend: const Legend(isVisible: true),
        series: [
          DoughnutSeries<_Point, String>(
            dataSource: data,
            xValueMapper: (p, _) => p.x,
            yValueMapper: (p, _) => p.y,
          )
        ],
      ),
    );
  }

  Widget _chartContainer(String title, Widget chart) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(height: 280, child: chart),
        ],
      ),
    );
  }

  InputDecoration _input(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none),
  );

  BoxDecoration _card() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
  );
}

class _Point {
  final String x;
  final double y;
  _Point(this.x, this.y);
}
