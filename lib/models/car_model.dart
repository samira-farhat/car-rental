class Car {
  final int carId;
  final String vin;
  final String brand;
  final String model;
  final int year;
  final String rentalPricePerDay;
  final String availabilityStatus;
  final String imageUrl;
  final String categoryName;

  Car({
    required this.carId,
    required this.vin,
    required this.brand,
    required this.model,
    required this.year,
    required this.rentalPricePerDay,
    required this.availabilityStatus,
    required this.imageUrl,
    required this.categoryName,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      carId: json['carid'],
      vin: json['vin'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      rentalPricePerDay: json['rentalpriceperday'],
      availabilityStatus: json['availabilitystatus'],
      imageUrl: json['image_url'],
      categoryName: json['category']['categoryname'],
    );
  }
}
