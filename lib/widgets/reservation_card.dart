import 'package:car_management_frontend/screens/customer_screens/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../screens/customer_screens/reservation_details_screen.dart';

class ReservationCard extends StatelessWidget {
  final Map reservation;
  final VoidCallback onRefresh;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.onRefresh,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.lightBlue;
      case 'approved':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> cancelReservation(BuildContext context) async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access');

    await http.post(
      Uri.parse(
        'http://localhost:8000/api/reservations/${reservation['reservationid']}/cancel/',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final status = reservation['status'];
    final statusColor = _statusColor(status);
    final Color midnightBlue = Color(0xFF004760);

    return Container(
      margin: EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [

          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReservationDetailsScreen(
                    reservationId: reservation['reservationid'],
                  ),
                ),
              ).then((_) => onRefresh());
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: reservation['car_image'] != null
                      ? Image.network(
                    reservation['car_image'],
                    width: 90,
                    height: 70,
                    fit: BoxFit.contain,
                  )
                      : Container(
                    width: 90,
                    height: 70,
                    color: Colors.grey[200],
                    child: Icon(Icons.directions_car),
                  ),
                ),

                SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        reservation['car_name'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        reservation['category'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),

                      SizedBox(height: 6),

                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right,
                  size: 28,
                  color: Colors.grey,
                ),
              ],
            ),
          ),

          // buttons
          if (status == 'pending' || status == 'approved') ...[

            SizedBox(height: 12),

            Row(
              children: [

                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => cancelReservation(context),
                    child: Text('Cancel Reservation'),
                  ),
                ),

                if (status == 'approved') ...[

                  SizedBox(width: 10),

                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: midnightBlue,
                        side: BorderSide(color: midnightBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/payment');
                      },
                      child: Text('Rent Now'),
                    ),
                  ),

                ],
              ],
            ),
          ],
        ],
      ),
    );
  }


}
