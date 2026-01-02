import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';

import '../globals.dart';

const String baseUrl = "http://localhost:8000/api";

class AdminDamagesPage extends StatefulWidget {
  const AdminDamagesPage({super.key});

  @override
  State<AdminDamagesPage> createState() => _AdminDamagesPageState();
}

class _AdminDamagesPageState extends State<AdminDamagesPage> with TickerProviderStateMixin {
  final storage = const FlutterSecureStorage();
  List damages = [];
  bool loading = true;
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    fetchDamages();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  Future<void> fetchDamages() async {
    setState(() => loading = true);
    final response = await http.get(Uri.parse("$baseUrl/damages/"));
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          damages = jsonDecode(response.body);
          loading = false;
        });
        _listController.forward(from: 0.0);
      }
    } else {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> deleteDamage(int damageId, String carName) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Confirm Delete", style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text("Are you sure you want to remove the damage report for $carName?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("DELETE", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final token = await storage.read(key: "access");
      final response = await http.delete(
        Uri.parse("$baseUrl/admin/damages/$damageId/"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 204) fetchDamages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: loading
                ? Center(
              child: CircularProgressIndicator(color: electricCyan),
            )
                : damages.isEmpty
                ? const Center(
              child: Text(
                'No listed damages',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: damages.length,
              itemBuilder: (context, index) =>
                  _buildAnimatedItem(index, damages[index]),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("DAMAGE REPORTS", style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
              Text("Management", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            ],
          ),
          IconButton(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditDamagePage()));
              fetchDamages();
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: electricCyan, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAnimatedItem(int index, Map damage) {
    return AnimatedBuilder(
      animation: _listController,
      builder: (context, child) {
        final slide = Curves.easeOutCubic.transform((_listController.value - (index * 0.05)).clamp(0.0, 1.0));
        return Opacity(
          opacity: slide,
          child: Transform.translate(offset: Offset(0, 30 * (1 - slide)), child: child),
        );
      },
      child: _buildDamageCard(damage),
    );
  }

  Widget _buildDamageCard(Map damage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: (damage['image_url'] != null)
                ? Image.network('${damage['image_url']}', width: 85, height: 85, fit: BoxFit.cover)
                : Container(width: 85, height: 85, color: Colors.grey.shade200, child: const Icon(Icons.car_crash, size: 30)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${damage['car']['brand']} ${damage['car']['model']}".toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                Text("Cost: \$${damage['repaircost'] ?? 0}", style: const TextStyle(color: Color(0xFF49C5E0), fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _statusBadge(damage['status']),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditDamagePage(damage: damage)));
                  fetchDamages();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () => deleteDamage(damage['damageid'], damage['car']['brand']),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color = status == 'reported'
        ? Colors.red
        : (status == 'under_repair' ? Colors.orange : Colors.green);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}

class AddEditDamagePage extends StatefulWidget {
  final Map? damage;
  const AddEditDamagePage({super.key, this.damage});

  @override
  State<AddEditDamagePage> createState() => _AddEditDamagePageState();
}

class _AddEditDamagePageState extends State<AddEditDamagePage> {
  final storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  // Image management
  Uint8List? imageBytes;
  File? imageFile;
  String? imageExtension;

  // Form controllers
  late TextEditingController descriptionCtrl;
  late TextEditingController repairCostCtrl;
  late TextEditingController reportDateCtrl;
  Map? selectedCar;
  List cars = [];
  String status = "reported";
  bool loadingCars = true;

  final List<String> statusOptions = ['reported', 'under_repair', 'resolved'];

  @override
  void initState() {
    super.initState();
    descriptionCtrl = TextEditingController(text: widget.damage?['description'] ?? "");
    repairCostCtrl = TextEditingController(text: widget.damage?['repaircost']?.toString() ?? "");
    reportDateCtrl = TextEditingController(text: widget.damage?['reportdate'] ?? "");
    status = widget.damage?['status'] ?? "reported";
    fetchCars();
  }

  @override
  void dispose() {
    descriptionCtrl.dispose();
    repairCostCtrl.dispose();
    reportDateCtrl.dispose();
    super.dispose();
  }

  Future<void> fetchCars() async {
    final res = await http.get(Uri.parse("$baseUrl/cars/"));
    if (res.statusCode == 200) {
      setState(() {
        cars = jsonDecode(res.body);
        // Preselect car if editing
        if (widget.damage != null) {
          selectedCar = cars.firstWhere((c) => c['carid'] == widget.damage!['car']['carid']);
        }
        loadingCars = false;
      });
    }
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: kIsWeb);
    if (result != null) {
      setState(() {
        imageExtension = result.files.single.extension;
        if (kIsWeb) {
          imageBytes = result.files.single.bytes;
        } else {
          imageFile = File(result.files.single.path!);
        }
      });
    }
  }

  Future<void> selectDate() async {
    DateTime initialDate = DateTime.now();
    if (reportDateCtrl.text.isNotEmpty) {
      initialDate = DateTime.parse(reportDateCtrl.text);
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      reportDateCtrl.text = picked.toIso8601String().split('T')[0];
    }
  }

  Future<void> confirmSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCar == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a car")));
      return;
    }
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Save Damage Report"),
        content: const Text("Do you want to finalize and save this damage report?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("SAVE", style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
    if (confirm == true) submit();
  }

  Future<void> submit() async {
    final token = await storage.read(key: "access");
    final isEdit = widget.damage != null;
    final uri = isEdit
        ? Uri.parse("$baseUrl/admin/damages/${widget.damage!['damageid']}/")
        : Uri.parse("$baseUrl/admin/damages/");

    final request = http.MultipartRequest(isEdit ? "PUT" : "POST", uri);
    request.headers["Authorization"] = "Bearer $token";
    request.fields.addAll({
      "car": selectedCar!['carid'].toString(),
      "reportdate": reportDateCtrl.text,
      "description": descriptionCtrl.text,
      "repaircost": repairCostCtrl.text.isEmpty ? "" : repairCostCtrl.text,
      "status": status,
    });

    if (kIsWeb && imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes("image", imageBytes!, filename: "damage.${imageExtension ?? 'png'}"));
    } else if (!kIsWeb && imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath("image", imageFile!.path));
    }

    final response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text("DAMAGE REPORT", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
      ),
      body: loadingCars
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImagePreview(),
              const SizedBox(height: 24),
              DropdownButtonFormField<Map>(
                value: selectedCar,
                decoration: _dropdownDecoration("Select Car", Icons.directions_car),
                items: cars.map<DropdownMenuItem<Map>>((c) {
                  return DropdownMenuItem<Map>(value: c, child: Text("${c['brand']} ${c['model']}"));
                }).toList(),
                onChanged: (v) => setState(() => selectedCar = v),
                validator: (v) => v == null ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: reportDateCtrl,
                readOnly: true,
                onTap: selectDate,
                decoration: InputDecoration(
                  labelText: "Report Date",
                  prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF49C5E0)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Description",
                  prefixIcon: const Icon(Icons.notes, color: Color(0xFF49C5E0)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
                validator: (v) => v!.length < 10 ? "Min 10 characters" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: repairCostCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Repair Cost",
                  prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF49C5E0)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: status,
                decoration: _dropdownDecoration("Status", Icons.info_outline),
                items: statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
                onChanged: (v) => setState(() => status = v!),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: confirmSubmit,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text("COMMIT CHANGES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF49C5E0)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
    );
  }

  Widget _buildImagePreview() {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade200)),
        child: (imageBytes != null || imageFile != null)
            ? ClipRRect(borderRadius: BorderRadius.circular(24), child: kIsWeb ? Image.memory(imageBytes!, fit: BoxFit.cover) : Image.file(imageFile!, fit: BoxFit.cover))
            : (widget.damage != null && widget.damage!['image_url'] != null)
            ? ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.network(widget.damage!['image_url'], fit: BoxFit.cover))
            : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey), Text("Damage Image", style: TextStyle(color: Colors.grey))]),
      ),
    );
  }
}
