import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../models/car_model.dart';
import '../../globals.dart';

class ReserveScreen extends StatefulWidget {
  final Car car;

  const ReserveScreen({required this.car, Key? key}) : super(key: key);

  @override
  State<ReserveScreen> createState() => _ReserveScreenState();
}

class _ReserveScreenState extends State<ReserveScreen> {
  final Color midnightBlue = Color(0xFF004760);

  // Form fields
  DateTime? startDate;
  DateTime? endDate;

  bool isLoading = false; // for loading indicator

  List<DateTime> reservedDates = []; // holds all already reserved dates

  double get pricePerDay => double.tryParse(widget.car.rentalPricePerDay) ?? 0.0;

  int get rentalDays {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays + 1;
  }

  double get totalPrice => rentalDays * pricePerDay;

  @override
  void initState() {
    super.initState();
    fetchReservedDates();
  }

  Future<void> fetchReservedDates() async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'access');
    if (token == null) return;

    final url = Uri.parse('http://localhost:8000/api/reservations/car/${widget.car.carId}/dates/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<DateTime> tempDates = [];
      for (var reservation in data) {
        DateTime start = DateTime.parse(reservation['startdate']);
        DateTime end = DateTime.parse(reservation['enddate']);
        for (int i = 0; i <= end.difference(start).inDays; i++) {
          tempDates.add(start.add(Duration(days: i)));
        }
      }
      setState(() {
        reservedDates = tempDates;
      });
    }
  }

  bool isDateReserved(DateTime date) {
    return reservedDates.any((d) =>
    d.year == date.year && d.month == date.month && d.day == date.day);
  }

  Future<DateTime?> pickDate(BuildContext context, DateTime? initialDate) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      selectableDayPredicate: (date) {
        return !isDateReserved(date);
      },
    );
    return picked;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: midnightBlue),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Reservation Screen Image
            Image.asset(
              'assets/images/reservation.jpeg',
              width: double.infinity,
              height: 250,
              fit: BoxFit.contain,
            ),

            SizedBox(height: 20),

            // Car Summary
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: ExpansionTile(
                title: Text(
                  'View Car Summary',
                  style: TextStyle(
                    color: midnightBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Car image small
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(
                              widget.car.imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          '${widget.car.brand} ${widget.car.model}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: midnightBlue),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${widget.car.year} • ${widget.car.categoryName}',
                          style: TextStyle(color: midnightBlue),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '\$${widget.car.rentalPricePerDay} / day',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: midnightBlue),
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.car.availabilityStatus,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: widget.car.availabilityStatus.toLowerCase() ==
                                  "available"
                                  ? Colors.green
                                  : Colors.red),
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.car.description.isNotEmpty
                              ? widget.car.description
                              : 'No description available',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Reservation Form Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: midnightBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Start Date Picker
                    Text(
                      'Start Date',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    GestureDetector(
                      onTap: () async {
                        DateTime? picked = await pickDate(context, startDate);
                        if (picked != null) {
                          setState(() {
                            startDate = picked;
                            if (endDate != null && endDate!.isBefore(startDate!)) {
                              endDate = null;
                            }
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Text(
                              startDate != null
                                  ? '${startDate!.year}-${startDate!.month.toString().padLeft(2,'0')}-${startDate!.day.toString().padLeft(2,'0')}'
                                  : 'Select start date',
                              style: TextStyle(color: midnightBlue),
                            ),

                            Icon(Icons.calendar_today, color: midnightBlue),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // End Date Picker
                    Text(
                      'End Date',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    GestureDetector(
                      onTap: () async {
                        DateTime? picked = await pickDate(context, endDate);
                        if (picked != null) {
                          setState(() {
                            endDate = picked;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            Text(
                              endDate != null
                                  ? '${endDate!.year}-${endDate!.month.toString().padLeft(2,'0')}-${endDate!.day.toString().padLeft(2,'0')}'
                                  : 'Select end date',
                              style: TextStyle(color: midnightBlue),
                            ),

                            Icon(Icons.calendar_today, color: midnightBlue),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Rental Days & Price
                    if (rentalDays > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rental Days: $rentalDays',
                              style: TextStyle(color: Colors.white)),
                          SizedBox(height: 4),
                          Text('Total Price: \$${totalPrice.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.white)),
                          SizedBox(height: 16),
                        ],
                      ),

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () async {
                          if (startDate == null || endDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please select start and end dates')),
                            );
                            return;
                          }

                          setState(() => isLoading = true);

                          final storage = const FlutterSecureStorage();
                          final token = await storage.read(key: 'access');

                          if (token == null) {
                            Navigator.pushNamed(context, '/login');
                            return;
                          }

                          final url = Uri.parse('http://localhost:8000/api/reservations/');
                          final response = await http.post(
                            url,
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization': 'Bearer $token',
                            },
                            body: jsonEncode({
                              'car': widget.car.carId,
                              'startdate':
                              '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}',
                              'enddate':
                              '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}',
                            }),
                          );

                          setState(() => isLoading = false);

                          if (response.statusCode == 200 || response.statusCode == 201) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Reservation created successfully!')),
                            );

                            // Navigate back to browse screen
                            Navigator.pop(context);

                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to create reservation.')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                          'Confirm Reservation',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
