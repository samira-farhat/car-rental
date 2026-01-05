import 'package:flutter/material.dart';
import 'rental_service.dart';

class AdminRentalsPage extends StatefulWidget {
  const AdminRentalsPage({super.key});

  @override
  State<AdminRentalsPage> createState() => _AdminRentalsPageState();
}

class _AdminRentalsPageState extends State<AdminRentalsPage> {
  late Future<List<dynamic>> _pendingRentals;

  @override
  void initState() {
    super.initState();
    _pendingRentals = RentalService.fetchPendingPayments();
  }

  void _refresh() {
    setState(() {
      _pendingRentals = RentalService.fetchPendingPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Payments')),
      body: FutureBuilder<List<dynamic>>(
        future: _pendingRentals,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final rentals = snapshot.data!;
          if (rentals.isEmpty) {
            return const Center(child: Text('No pending payments'));
          }

          return ListView.builder(
            itemCount: rentals.length,
            itemBuilder: (context, index) {
              final r = rentals[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text('Rental #${r['rental_id']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer: ${r['customer']}'),
                      Text('Car: ${r['car']}'),
                      Text('Amount: \$${r['total_amount']}'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await RentalService.approvePayment(r['rental_id']);
                      _refresh();
                    },
                    child: const Text('Approve'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
