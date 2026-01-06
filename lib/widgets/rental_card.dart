import 'package:flutter/material.dart';
import '../screens/customer_screens/return_screen.dart';
import '../screens/customer_screens/rental_details_screen.dart';

class RentalCard extends StatelessWidget {
  final Map rental;
  final VoidCallback onRefresh;

  const RentalCard({
    super.key,
    required this.rental,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
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
                  builder: (_) => RentalDetailsScreen(
                    rentalId: rental['rentalid'],
                  ),
                ),
              ).then((_) => onRefresh());
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: rental['car_image'] != null
                      ? Image.network(
                    rental['car_image'],
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
                        rental['car_name'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        "${rental['startdate']} → ${rental['enddate']}",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),

                      SizedBox(height: 6),

                      Text(
                        'ACTIVE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
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

          // RETURN button
          SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: midnightBlue,
                side: BorderSide(color: midnightBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReturnScreen(rentalId: rental['rentalid']),
                  ),
                );
              },
              child: Text('Return Now'),
            ),
          ),
        ],
      ),
    );
  }
}
