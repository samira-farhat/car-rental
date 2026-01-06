import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:car_management_frontend/globals.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';

const String baseUrl = "http://localhost:8000/api";

class AdminCarsPage extends StatefulWidget {
  const AdminCarsPage({super.key});

  @override
  State<AdminCarsPage> createState() => _AdminCarsPageState();
}

class _AdminCarsPageState extends State<AdminCarsPage> with TickerProviderStateMixin {
  final storage = const FlutterSecureStorage();
  List cars = [];
  bool loading = true;
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    fetchCars();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  Future<void> fetchCars() async {
    setState(() => loading = true);
    final response = await http.get(Uri.parse("$baseUrl/cars/"));
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          cars = jsonDecode(response.body);
          loading = false;
        });
        _listController.forward(from: 0.0);
      }
    } else {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> deleteCar(int carId, String carName) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Confirm Delete", style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text("Are you sure you want to remove the $carName?"),
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
        Uri.parse("$baseUrl/admin/cars/$carId/"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 204) fetchCars();
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
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: cars.length,
              itemBuilder: (context, index) => _buildAnimatedItem(index, cars[index]),
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
              Text("FLEET STATUS", style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
              Text("Inventory", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            ],
          ),
          IconButton(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditCarPage()));
              fetchCars();
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: deepMidnightBlue, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAnimatedItem(int index, Map car) {
    return AnimatedBuilder(
      animation: _listController,
      builder: (context, child) {
        final slide = Curves.easeOutCubic.transform((_listController.value - (index * 0.05)).clamp(0.0, 1.0));
        return Opacity(
          opacity: slide,
          child: Transform.translate(offset: Offset(0, 30 * (1 - slide)), child: child),
        );
      },
      child: _buildCarCard(car),
    );
  }

  Widget _buildCarCard(Map car) {
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
            child: Image.network('${car['image_url']}', width: 85, height: 85, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${car['brand']} ${car['model']}".toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                Text("\$${car['rentalpriceperday']}/day", style: const TextStyle(color: Color(0xFF49C5E0), fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _statusBadge(car['availabilitystatus']),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditCarPage(car: car)));
                  fetchCars();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () => deleteCar(car['carid'], car['brand']),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color = status == 'available' ? Colors.green : (status == 'rented' ? Colors.orange : Colors.red);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}

class AddEditCarPage extends StatefulWidget {
  final Map? car;
  const AddEditCarPage({super.key, this.car});

  @override
  State<AddEditCarPage> createState() => _AddEditCarPageState();
}

class _AddEditCarPageState extends State<AddEditCarPage> {
  final storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  Uint8List? imageBytes;
  File? imageFile;
  String? imageExtension;

  late TextEditingController vin, brand, model, year, price, description;
  int? selectedCategoryId;
  String availabilityStatus = "available";
  List categories = [];
  bool loadingCategories = true;

  final List<String> availabilityOptions = ['available', 'rented', 'maintenance'];

  @override
  void initState() {
    super.initState();
    vin = TextEditingController(text: widget.car?["vin"] ?? "");
    brand = TextEditingController(text: widget.car?["brand"] ?? "");
    model = TextEditingController(text: widget.car?["model"] ?? "");
    year = TextEditingController(text: widget.car?["year"]?.toString() ?? "");
    price = TextEditingController(text: widget.car?["rentalpriceperday"]?.toString() ?? "");
    description = TextEditingController(text: widget.car?["description"] ?? "");
    availabilityStatus = widget.car?["availabilitystatus"] ?? "available";
    selectedCategoryId = widget.car?["category"]?["categoryid"];
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final res = await http.get(Uri.parse("$baseUrl/carcategories/"));
    if (res.statusCode == 200) {
      if (mounted) {
        setState(() {
          categories = jsonDecode(res.body);
          loadingCategories = false;
        });
      }
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

  Future<void> confirmSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Save Data"),
        content: const Text("Do you want to finalize and save these vehicle details?"),
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
    final isEdit = widget.car != null;
    final uri = isEdit ? Uri.parse("$baseUrl/admin/cars/${widget.car!["carid"]}/") : Uri.parse("$baseUrl/admin/cars/");

    final request = http.MultipartRequest(isEdit ? "PUT" : "POST", uri);
    request.headers["Authorization"] = "Bearer $token";
    request.fields.addAll({
      "vin": vin.text,
      "brand": brand.text,
      "model": model.text,
      "year": year.text,
      "description": description.text,
      "rentalpriceperday": price.text,
      "availabilitystatus": availabilityStatus,
      "categoryid": selectedCategoryId.toString(),
    });

    if (kIsWeb && imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes("image", imageBytes!, filename: "car.${imageExtension ?? 'png'}"));
    } else if (!kIsWeb && imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath("image", imageFile!.path));
    }

    final response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (mounted) Navigator.pop(context);
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
          title: const Text("CAR SPECIFICATIONS", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2))
      ),
      body: loadingCategories ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImagePreview(),
              const SizedBox(height: 24),
              _buildField(vin, "VIN", Icons.fingerprint),
              _buildField(brand, "Brand", Icons.branding_watermark_outlined),
              _buildField(model, "Model", Icons.directions_car_filled_outlined),
              Row(children: [
                Expanded(child: _buildField(year, "Year", Icons.calendar_month, isNum: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildField(price, "Price/Day", Icons.attach_money, isNum: true)),
              ]),
              _buildField(description, "Description", Icons.notes, maxLines: 3),

              // --- AVAILABILITY STATUS FIELD ---
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: availabilityStatus,
                decoration: _dropdownDecoration("Availability", Icons.info_outline),
                items: availabilityOptions.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
                onChanged: (v) => setState(() => availabilityStatus = v!),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                dropdownColor: Colors.white,
                value: selectedCategoryId,
                decoration: _dropdownDecoration("Category", Icons.category_outlined),
                items: categories.map<DropdownMenuItem<int>>((c) => DropdownMenuItem<int>(value: c["categoryid"], child: Text(c["categoryname"]))).toList(),
                onChanged: (v) => setState(() => selectedCategoryId = v),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 32),
              SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: confirmSubmit, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text("COMMIT CHANGES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
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
        fillColor: const Color(0xFFF8FAFC)
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
            : (widget.car != null)
            ? ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.network(widget.car!['image_url'], fit: BoxFit.cover))
            : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey), Text("Vehicle Image", style: TextStyle(color: Colors.grey))]),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1, bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: const Color(0xFF49C5E0)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), filled: true, fillColor: const Color(0xFFF8FAFC)),
        validator: (v) => v!.isEmpty ? "Required" : null,
      ),
    );
  }
}