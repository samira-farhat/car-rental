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

    try {
      final response = await http.get(
        Uri.parse('http://192.168.10.20:8000/api/rentals/rented-cars/'),
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
    } catch (e) {
      debugPrint('Error fetching rented cars: $e');
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
      reviewError = reviewController.text.trim().isEmpty
          ? 'Review cannot be empty'
          : null;
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
      Uri.parse('http://192.168.10.20:8000/api/reviews/submit/'),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      _resetForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${response.body}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _openCarSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Rented Car',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...rentedCars.map((car) {
              final isSelected = selectedCarId == car['car_id'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCarId = car['car_id'];
                    selectedCarName = car['car_name'];
                    selectedCarImage = car['car_image'];
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? electricCyan.withOpacity(0.2) : Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? electricCyan : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: car['car_image'] != null
                              ? DecorationImage(
                            image: NetworkImage(
                              'http://192.168.10.20:8000/media/${car['car_image']}',
                            ),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: car['car_image'] == null
                            ? const Icon(Icons.directions_car, color: Colors.white70)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          car['car_name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: electricCyan),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.black,
              deepMidnightBlue,
            ],
            stops: const [0, 0.3, 1],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const AppLogo(size: 40),
                          const SizedBox(width: 12),
                          const Text(
                            'Rate Your Ride',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Car Selection Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: carError != null ? Colors.red : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Car',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: rentedCars.isEmpty ? null : _openCarSheet,
                              child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white30,
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      if (selectedCarImage != null)
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                'http://192.168.10.20:8000/media/$selectedCarImage',
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      else
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.white10,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.directions_car,
                                            color: Colors.white70,
                                            size: 40,
                                          ),
                                        ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              selectedCarName ?? 'Choose rented car',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (selectedCarName != null)
                                              const SizedBox(height: 4),
                                            if (selectedCarName != null)
                                              const Text(
                                                'Tap to change',
                                                style: TextStyle(
                                                  color: Colors.white60,
                                                  fontSize: 12,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: Colors.white70,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (carError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8, left: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      carError!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Rating Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: ratingError != null ? Colors.red : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Experience *',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: Wrap(
                                spacing: 16,
                                runSpacing: 12,
                                children: List.generate(5, (index) {
                                  final isSelected = index < selectedRating;
                                  final isFiveStar = selectedRating == 5 && index == 4;
                                  final ratingLabels = [
                                    'Unacceptable',
                                    'Below Standard',
                                    'Satisfactory',
                                    'Reliable',
                                    'Outstanding'
                                  ];

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() => selectedRating = index + 1);
                                      if (index == 4) _fiveStarController.forward(from: 0);
                                      else _fiveStarController.reset();
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AnimatedBuilder(
                                          animation: _fiveStarController,
                                          builder: (_, child) => Transform.scale(
                                            scale: isFiveStar ? _fiveStarScale.value : 1.0,
                                            child: child,
                                          ),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 250),
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? electricCyan.withOpacity(0.9)
                                                  : Colors.black.withOpacity(0.5),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(
                                                color: isSelected
                                                    ? electricCyan
                                                    : Colors.white30,
                                                width: 2,
                                              ),
                                              boxShadow: isSelected
                                                  ? [
                                                BoxShadow(
                                                  color: electricCyan.withOpacity(0.3),
                                                  blurRadius: 10,
                                                  spreadRadius: 2,
                                                ),
                                              ]
                                                  : null,
                                            ),
                                            child: Center(
                                              child: Text(
                                                ['U', 'B', 'S', 'R', 'O'][index],
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.black
                                                      : Colors.white70,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          ratingLabels[index],
                                          style: TextStyle(
                                            color: isSelected
                                                ? electricCyan
                                                : Colors.white60,
                                            fontSize: 12,
                                            fontWeight:
                                            isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ),
                            if (ratingError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12, left: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      ratingError!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Review Input
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: reviewError != null ? Colors.red : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Write Your Review *',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: reviewController,
                              maxLines: 6,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Share your experience with this car...',
                                hintStyle: const TextStyle(color: Colors.white60),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                            if (reviewError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12, left: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      reviewError!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: submitReview,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: electricCyan,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Submit Review',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              onPressed: _resetForm,
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white70,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}