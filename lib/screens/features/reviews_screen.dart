import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../globals.dart';

class CarReviewPage extends StatefulWidget {
  const CarReviewPage({super.key});

  @override
  State<CarReviewPage> createState() => _CarReviewPageCombinedState();
}

class _CarReviewPageCombinedState extends State<CarReviewPage>
    with SingleTickerProviderStateMixin {
  final storage = const FlutterSecureStorage();
  final TextEditingController reviewController = TextEditingController();

  List<Map<String, dynamic>> rentedCars = [];
  int selectedRating = 0;
  int? selectedCarId;
  String? selectedCarName;
  String? selectedCarImage;

  late AnimationController _fiveStarController;
  late Animation<double> _fiveStarScale;

  String? carError;
  String? ratingError;
  String? reviewError;

  @override
  void initState() {
    super.initState();

    _fiveStarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fiveStarScale = Tween<double>(begin: 1.0, end: 1.25)
        .chain(CurveTween(curve: Curves.easeOutBack))
        .animate(_fiveStarController);

    fetchRentedCars();
  }

  @override
  void dispose() {
    _fiveStarController.dispose();
    reviewController.dispose();
    super.dispose();
  }

  Future<void> fetchRentedCars() async {
    final token = await storage.read(key: 'access');
    if (token == null) return;

    final response = await http.get(
      Uri.parse('http://localhost:8000/api/rentals/rented-cars/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      setState(() {
        rentedCars = data.map<Map<String, dynamic>>((e) => {
          'car_id': e['car_id'],
          'car_name': e['car_name'],
          'car_image': e['car_image'],
        }).toList();

        if (rentedCars.isNotEmpty && selectedCarId == null) {
          selectedCarId = rentedCars[0]['car_id'];
          selectedCarName = rentedCars[0]['car_name'];
          selectedCarImage = rentedCars[0]['car_image'];
        }
      });
    }
  }

  void _resetForm() {
    setState(() {
      reviewController.clear();
      selectedRating = 0;
      carError = ratingError = reviewError = null;
    });
  }

  bool _validateInputs() {
    bool isValid = true;
    setState(() {
      carError = selectedCarId == null ? 'Please select a car' : null;
      ratingError = selectedRating == 0 ? 'Please select a rating' : null;
      reviewError =
      reviewController.text.trim().isEmpty ? 'Review cannot be empty' : null;
      if ([carError, ratingError, reviewError].any((e) => e != null)) {
        isValid = false;
      }
    });
    return isValid;
  }

  Future<void> submitReview() async {
    if (!_validateInputs()) return;

    final token = await storage.read(key: 'access');
    if (token == null) return;

    final response = await http.post(
      Uri.parse('http://localhost:8000/api/reviews/submit/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'car': selectedCarId,
        'rating': selectedRating,
        'description': reviewController.text.trim(),
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Review submitted successfully'),
          backgroundColor: electricCyan,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      _resetForm();
    }
  }

  void _openCarSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ...rentedCars.map((car) {
              final isSelected = selectedCarId == car['car_id'];
              return ListTile(
                leading: car['car_image'] != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    'http://localhost:8000/${car['car_image']}',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(Icons.directions_car),
                title: Text(car['car_name']),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: electricCyan)
                    : null,
                onTap: () {
                  setState(() {
                    selectedCarId = car['car_id'];
                    selectedCarName = car['car_name'];
                    selectedCarImage = car['car_image'];
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _lightCard(
                    child: ListTile(
                      onTap: rentedCars.isEmpty ? null : _openCarSheet,
                      leading: selectedCarImage != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          'http://localhost:8000/$selectedCarImage',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                          : const Icon(Icons.directions_car),
                      title: Text(
                        selectedCarName ?? 'Select rented car',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Tap to change'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _lightCard(
                    child: Column(
                      children: List.generate(5, (index) {
                        final selected = index < selectedRating;
                        return ListTile(
                          onTap: () {
                            setState(() => selectedRating = index + 1);
                            if (index == 4) {
                              _fiveStarController.forward(from: 0);
                            }
                          },
                          leading: Icon(
                            Icons.star,
                            color:
                            selected ? electricCyan : Colors.grey.shade400,
                          ),
                          title: Text(
                            ['Unacceptable', 'Below Standard', 'Satisfactory',
                              'Reliable', 'Outstanding'][index],
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _lightCard(
                    child: TextField(
                      controller: reviewController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Write your review...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: submitReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: deepMidnightBlue,
                            foregroundColor: Colors.white,
                            padding:
                            const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Submit Review',
                            style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: _resetForm,
                        icon: const Icon(Icons.refresh),
                      )
                    ],
                  )
                ],
              ),
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
          const Text(
            "Rate Your Ride",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1C1E),
            ),
          ),
          Icon(Icons.rate_review_rounded, color: deepMidnightBlue,),
        ],
      ),
    );
  }

  Widget _lightCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }
}
