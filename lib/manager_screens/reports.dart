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
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
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
                  if (reportData.isNotEmpty) _summarySection(),
                  if (reportData.isNotEmpty) _chartsSection(),
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
                color: electricCyan,
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
            DropdownMenuItem(value: "financial", child: Text("FINANCIAL")),
            DropdownMenuItem(value: "rental_history", child: Text("RENTAL HISTORY")),
            DropdownMenuItem(value: "operational", child: Text("OPERATIONAL")),
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

  Widget _datePicker(String label, DateTime value, Function(DateTime) onPick) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) setState(() => onPick(picked));
      },
      child: AbsorbPointer(
        child: TextFormField(
          decoration: _input(label).copyWith(prefixIcon: const Icon(Icons.calendar_today)),
          controller: TextEditingController(text: DateFormat('yyyy-MM-dd').format(value)),
        ),
      ),
    );
  }

  /* ───────────────────────── SUMMARY ───────────────────────── */

  Widget _summarySection() {
    final Map<String, dynamic> summary =
    Map<String, dynamic>.from(reportData['summary'] ?? {});

    final scalarMetrics = summary.entries
        .where((e) => e.value is num || e.value is String)
        .toList();

    if (scalarMetrics.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Summary", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: scalarMetrics
              .map((e) => _summaryCard(e.key, e.value))
              .toList(),
        ),
      ],
    );
  }

  Widget _summaryCard(String key, dynamic value) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(key.replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(_formatValue(key, value),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        "Monthly Income",
        data.map((e) => _Point(e['month'], (e['total'] as num).toDouble())).toList(),
        isCurrency: true,
      );
    }

    if (reportType == "rental_history") {
      final List data = List.from(charts['rental_counts'] ?? []);
      return _lineChart(
        "Rental History",
        data.map((e) => _Point(e['date'], (e['count'] as num).toDouble())).toList(),
      );
    }

    if (reportType == "operational") {
      final Map status = Map<String, dynamic>.from(
          reportData['summary']?['car_status'] ?? {});

      if (status.isEmpty) {
        return _empty("No operational data available.");
      }

      final points = status.entries
          .map((e) => _Point(e.key, (e.value as num).toDouble()))
          .toList();

      return _pieChart("Car Status", points);
    }

    return const SizedBox();
  }

  /* ───────────────────────── CHART WIDGETS ───────────────────────── */

  Widget _lineChart(String title, List<_Point> data, {bool isCurrency = false}) {
    if (data.isEmpty) return _empty("No data available.");

    return _chartContainer(
      title,
      SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: [
          SplineSeries<_Point, String>(
            dataSource: data,
            xValueMapper: (p, _) => p.x,
            yValueMapper: (p, _) => p.y,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
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
            dataLabelSettings: const DataLabelSettings(isVisible: true),
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

  Widget _empty(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Center(child: Text(text, style: const TextStyle(color: Colors.grey))),
    );
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

  String _formatValue(String key, dynamic value) {
    if (key.contains("income") || key.contains("revenue")) {
      return "\$${NumberFormat('#,##0.00').format(value)}";
    }
    return value.toString();
  }

  InputDecoration _input(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
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
