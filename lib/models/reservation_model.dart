// Represents ONE reservation returned from the backend
// This matches the AdminReservationListSerializer JSON

class Reservation {
  final int id;
  final String userName;
  final String carName;
  final String carImage;
  final double pricePerDay;
  final String status;
  final DateTime startDate;
  final DateTime endDate;

  Reservation({
    required this.id,
    required this.userName,
    required this.carName,
    required this.carImage,
    required this.pricePerDay,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  // Factory constructor to convert JSON → Dart object
  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['reservationid'],
      userName: json['user_name'],
      carName: json['car']['car_name'],
      carImage: json['car']['image'] ?? '',
      pricePerDay: double.parse(json['car']['rentalpriceperday']),
      status: json['status'],
      startDate: DateTime.parse(json['startdate']),
      endDate: DateTime.parse(json['enddate']),
    );
  }
}
