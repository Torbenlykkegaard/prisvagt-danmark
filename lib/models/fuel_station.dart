class FuelStation {
  final String id;
  final String name;
  final String brand;
  final String address;
  final String city;

  /// Afstand til bruger (beregnes dynamisk)
  final double distanceKm;

  /// GPS-koordinater
  final double latitude;
  final double longitude;

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
    required this.latitude,
    required this.longitude,
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

  FuelStation copyWith({
    String? id,
    String? name,
    String? brand,
    String? address,
    String? city,
    double? distanceKm,
    double? latitude,
    double? longitude,
    double? petrol95,
    double? diesel,
    double? petrol100,
    DateTime? updatedAt,
    bool? favorite,
  }) {
    return FuelStation(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      address: address ?? this.address,
      city: city ?? this.city,
      distanceKm: distanceKm ?? this.distanceKm,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      petrol95: petrol95 ?? this.petrol95,
      diesel: diesel ?? this.diesel,
      petrol100: petrol100 ?? this.petrol100,
      updatedAt: updatedAt ?? this.updatedAt,
      favorite: favorite ?? this.favorite,
    );
  }
}

enum FuelType {
  petrol95,
  diesel,
  petrol100,
}

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