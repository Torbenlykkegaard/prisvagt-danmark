class FuelStation {
  final String id;
  final String name;
  final String brand;
  final String address;
  final String city;
  final double distanceKm;
  final double petrol95;
  final double diesel;
  final double petrol100;
  final DateTime updatedAt;
  final bool favorite;

  const FuelStation({
    required this.id,
    required this.name,
    required this.brand,
    required this.address,
    required this.city,
    required this.distanceKm,
    required this.petrol95,
    required this.diesel,
    required this.petrol100,
    required this.updatedAt,
    this.favorite = false,
  });

  double priceFor(FuelType type) {
    switch (type) {
      case FuelType.petrol95:
        return petrol95;
      case FuelType.diesel:
        return diesel;
      case FuelType.petrol100:
        return petrol100;
    }
  }

  FuelStation copyWith({bool? favorite}) {
    return FuelStation(
      id: id,
      name: name,
      brand: brand,
      address: address,
      city: city,
      distanceKm: distanceKm,
      petrol95: petrol95,
      diesel: diesel,
      petrol100: petrol100,
      updatedAt: updatedAt,
      favorite: favorite ?? this.favorite,
    );
  }
}

enum FuelType { petrol95, diesel, petrol100 }

extension FuelTypeLabel on FuelType {
  String get label {
    switch (this) {
      case FuelType.petrol95:
        return 'Benzin 95';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.petrol100:
        return 'Benzin 100';
    }
  }
}
