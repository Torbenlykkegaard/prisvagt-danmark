import 'package:geolocator/geolocator.dart';

import '../models/fuel_station.dart';

class OverpassService {
  static Future<List<FuelStation>> fetchStations(Position position) async {
    return _fallbackStations(position);
  }

  static List<FuelStation> _fallbackStations(Position position) {
    final now = DateTime.now();

    final stations = [
      FuelStation(
        id: 'uno-x-hjoerring',
        name: 'Uno-X Hjørring',
        brand: 'Uno-X',
        address: 'Frederikshavnsvej 65',
        city: 'Hjørring',
        latitude: 57.4567,
        longitude: 9.9827,
        distanceKm: 0,
        petrol95: 14.49,
        diesel: 13.89,
        petrol100: 15.29,
        updatedAt: now,
      ),
      FuelStation(
        id: 'ok-hjoerring',
        name: 'OK Hjørring',
        brand: 'OK',
        address: 'Åstrupvej 5',
        city: 'Hjørring',
        latitude: 57.4593,
        longitude: 9.9895,
        distanceKm: 0,
        petrol95: 14.55,
        diesel: 13.95,
        petrol100: 15.35,
        updatedAt: now,
      ),
      FuelStation(
        id: 'q8-hjoerring',
        name: 'Q8 Hjørring',
        brand: 'Q8',
        address: 'Sct. Cathrine Vej',
        city: 'Hjørring',
        latitude: 57.4538,
        longitude: 9.9778,
        distanceKm: 0,
        petrol95: 14.69,
        diesel: 14.05,
        petrol100: 15.49,
        updatedAt: now,
      ),
      FuelStation(
        id: 'shell-hjoerring',
        name: 'Shell Hjørring',
        brand: 'Shell',
        address: 'Ringvejen',
        city: 'Hjørring',
        latitude: 57.4519,
        longitude: 9.9725,
        distanceKm: 0,
        petrol95: 14.75,
        diesel: 14.12,
        petrol100: 15.59,
        updatedAt: now,
      ),
      FuelStation(
        id: 'ingo-saeby',
        name: 'INGO Sæby',
        brand: 'INGO',
        address: 'Sæbygårdvej',
        city: 'Sæby',
        latitude: 57.3303,
        longitude: 10.5238,
        distanceKm: 0,
        petrol95: 14.61,
        diesel: 13.99,
        petrol100: 15.41,
        updatedAt: now,
      ),
      FuelStation(
        id: 'circle-k-frederikshavn',
        name: 'Circle K Frederikshavn',
        brand: 'Circle K',
        address: 'Knivholtvej',
        city: 'Frederikshavn',
        latitude: 57.4405,
        longitude: 10.5368,
        distanceKm: 0,
        petrol95: 14.89,
        diesel: 14.19,
        petrol100: 15.69,
        updatedAt: now,
      ),
    ];

    return stations
        .map(
          (station) => station.copyWith(
        distanceKm: Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          station.latitude,
          station.longitude,
        ) /
            1000,
      ),
    )
        .toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  }
}