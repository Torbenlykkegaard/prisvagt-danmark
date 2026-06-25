import '../models/fuel_station.dart';

class FuelPriceService {
  /// Demo-data til Android-test. Når der opnås API-adgang, kan denne metode
  /// erstattes af http-kald til en rigtig brændstofpris-kilde.
  static Future<List<FuelStation>> fetchNearbyStations({FuelType type = FuelType.petrol95}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final now = DateTime.now();
    return [
      FuelStation(id: 'uno-x-1', name: 'Uno-X Glostrup', brand: 'Uno-X', address: 'Hovedvejen 112', city: 'Glostrup', distanceKm: 1.2, petrol95: 14.49, diesel: 13.89, petrol100: 15.29, updatedAt: now.subtract(const Duration(minutes: 12))),
      FuelStation(id: 'ok-1', name: 'OK Albertslund', brand: 'OK', address: 'Roskildevej 55', city: 'Albertslund', distanceKm: 2.1, petrol95: 14.59, diesel: 13.95, petrol100: 15.39, updatedAt: now.subtract(const Duration(minutes: 22))),
      FuelStation(id: 'ingo-1', name: 'INGO Rødovre', brand: 'INGO', address: 'Tårnvej 88', city: 'Rødovre', distanceKm: 3.4, petrol95: 14.65, diesel: 13.99, petrol100: 15.45, updatedAt: now.subtract(const Duration(minutes: 34))),
      FuelStation(id: 'circlek-1', name: 'Circle K Valby', brand: 'Circle K', address: 'Gammel Køge Landevej 210', city: 'Valby', distanceKm: 4.8, petrol95: 14.79, diesel: 14.09, petrol100: 15.59, updatedAt: now.subtract(const Duration(minutes: 41))),
      FuelStation(id: 'q8-1', name: 'Q8 Hvidovre', brand: 'Q8', address: 'Avedøre Havnevej 12', city: 'Hvidovre', distanceKm: 5.2, petrol95: 14.85, diesel: 14.15, petrol100: 15.65, updatedAt: now.subtract(const Duration(hours: 1, minutes: 8))),
      FuelStation(id: 'shell-1', name: 'Shell Brøndby', brand: 'Shell', address: 'Park Allé 160', city: 'Brøndby', distanceKm: 6.0, petrol95: 14.89, diesel: 14.19, petrol100: 15.69, updatedAt: now.subtract(const Duration(hours: 1, minutes: 20))),
    ]..sort((a, b) => a.priceFor(type).compareTo(b.priceFor(type)));
  }
}
