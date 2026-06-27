import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/fuel_station.dart';
import '../services/overpass_service.dart';

class FuelScreen extends StatefulWidget {
  const FuelScreen({super.key});

  @override
  State<FuelScreen> createState() => _FuelScreenState();
}

class _FuelScreenState extends State<FuelScreen> {
  FuelType selectedType = FuelType.petrol95;
  bool favoritesOnly = false;
  bool loading = true;
  String? locationMessage;

  double radiusKm = 25;
  Position? userPosition;

  List<FuelStation> stations = [];
  Set<String> favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    setState(() {
      loading = true;
      locationMessage = null;
    });

    try {
      final position = await _getCurrentPosition();

      if (position == null) {
        setState(() {
          stations = [];
          loading = false;
        });
        return;
      }

      final result = await OverpassService.fetchStations(position);

      final mapped = result
          .map(
            (station) => station.copyWith(
          favorite: favoriteIds.contains(station.id),
        ),
      )
          .toList()
        ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      setState(() {
        userPosition = position;
        stations = mapped;
        loading = false;
      });
    } catch (e) {
      setState(() {
        locationMessage = 'Kunne ikke hente stationer: $e';
        stations = [];
        loading = false;
      });
    }
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        locationMessage = 'GPS er slået fra. Slå placering til på telefonen.';
        return null;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        locationMessage = 'Placeringstilladelse blev afvist.';
        return null;
      }

      if (permission == LocationPermission.deniedForever) {
        locationMessage =
        'Placering er permanent afvist. Åbn app-indstillinger og tillad placering.';
        return null;
      }

      return Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      locationMessage = 'Kunne ikke hente placering: $e';
      return null;
    }
  }

  void _toggleFavorite(FuelStation station) {
    setState(() {
      if (favoriteIds.contains(station.id)) {
        favoriteIds.remove(station.id);
      } else {
        favoriteIds.add(station.id);
      }

      stations = stations
          .map(
            (item) => item.id == station.id
            ? item.copyWith(favorite: favoriteIds.contains(item.id))
            : item,
      )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleStations = stations
        .where((station) => !favoritesOnly || station.favorite)
        .where((station) => station.distanceKm <= radiusKm)
        .toList();

    final nearest = visibleStations.isEmpty ? null : visibleStations.first;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadStations,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Brændstof',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Opdater placering',
                  onPressed: _loadStations,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              userPosition == null
                  ? 'Henter din placering og stationer i nærheden.'
                  : 'Viser stationer omkring din placering.',
            ),
            if (locationMessage != null) ...[
              const SizedBox(height: 8),
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(locationMessage!),
                ),
              ),
            ],
            const SizedBox(height: 12),
            SegmentedButton<FuelType>(
              segments: FuelType.values
                  .map(
                    (type) => ButtonSegment(
                  value: type,
                  label: Text(type.label),
                ),
              )
                  .toList(),
              selected: {selectedType},
              onSelectionChanged: (value) {
                setState(() => selectedType = value.first);
              },
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Afstand',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: radiusKm,
                      min: 2,
                      max: 50,
                      divisions: 48,
                      label: '${radiusKm.toStringAsFixed(0)} km',
                      onChanged: (value) => setState(() => radiusKm = value),
                    ),
                    Text(
                      'Viser stationer inden for ${radiusKm.toStringAsFixed(0)} km',
                    ),
                  ],
                ),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Vis kun favoritstationer'),
              value: favoritesOnly,
              onChanged: (value) => setState(() => favoritesOnly = value),
            ),
            if (nearest != null)
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nærmeste station',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        nearest.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${nearest.address}, ${nearest.city} · ${nearest.distanceKm.toStringAsFixed(1)} km væk',
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${selectedType.label}: ${nearest.priceFor(selectedType).toStringAsFixed(2)} kr./L',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            if (loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (visibleStations.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    favoritesOnly
                        ? 'Ingen favoritstationer inden for ${radiusKm.toStringAsFixed(0)} km.'
                        : 'Ingen stationer fundet inden for ${radiusKm.toStringAsFixed(0)} km.',
                  ),
                ),
              )
            else
              ...visibleStations.map(
                    (station) => _FuelStationCard(
                  station: station,
                  type: selectedType,
                  onFavorite: () => _toggleFavorite(station),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FuelStationCard extends StatelessWidget {
  final FuelStation station;
  final FuelType type;
  final VoidCallback onFavorite;

  const _FuelStationCard({
    required this.station,
    required this.type,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final brand = station.brand.trim().isEmpty ? 'Station' : station.brand;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              child: Text(brand.isNotEmpty ? brand[0] : '?'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${station.address}, ${station.city}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${station.distanceKm.toStringAsFixed(1)} km væk',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${type.label}: ${station.priceFor(type).toStringAsFixed(2)} kr./L',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: station.favorite ? 'Fjern favorit' : 'Gem favorit',
              onPressed: onFavorite,
              icon: Icon(station.favorite ? Icons.star : Icons.star_border),
            ),
          ],
        ),
      ),
    );
  }
}