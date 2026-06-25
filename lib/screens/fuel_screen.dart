import 'package:flutter/material.dart';

import '../models/fuel_station.dart';
import '../services/fuel_price_service.dart';

class FuelScreen extends StatefulWidget {
  const FuelScreen({super.key});

  @override
  State<FuelScreen> createState() => _FuelScreenState();
}

class _FuelScreenState extends State<FuelScreen> {
  FuelType selectedType = FuelType.petrol95;
  bool favoritesOnly = false;
  bool loading = true;
  List<FuelStation> stations = [];
  Set<String> favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    setState(() => loading = true);
    final result = await FuelPriceService.fetchNearbyStations(type: selectedType);
    setState(() {
      stations = result.map((station) => station.copyWith(favorite: favoriteIds.contains(station.id))).toList();
      loading = false;
    });
  }

  void _toggleFavorite(FuelStation station) {
    setState(() {
      if (favoriteIds.contains(station.id)) {
        favoriteIds.remove(station.id);
      } else {
        favoriteIds.add(station.id);
      }
      stations = stations.map((item) => item.id == station.id ? item.copyWith(favorite: favoriteIds.contains(item.id)) : item).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleStations = stations.where((station) => !favoritesOnly || station.favorite).toList();
    final cheapest = visibleStations.isEmpty ? null : visibleStations.first;

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
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Opdater priser',
                  onPressed: _loadStations,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Live-modul klar til API. Viser demo-priser, så appen kan testes på Android nu.'),
            const SizedBox(height: 12),
            SegmentedButton<FuelType>(
              segments: FuelType.values.map((type) => ButtonSegment(value: type, label: Text(type.label))).toList(),
              selected: {selectedType},
              onSelectionChanged: (value) {
                setState(() => selectedType = value.first);
                _loadStations();
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Vis kun favoritstationer'),
              value: favoritesOnly,
              onChanged: (value) => setState(() => favoritesOnly = value),
            ),
            if (cheapest != null)
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Billigst lige nu', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text('${cheapest.brand} · ${cheapest.priceFor(selectedType).toStringAsFixed(2)} kr./L', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text('${cheapest.address}, ${cheapest.city} · ${cheapest.distanceKm.toStringAsFixed(1)} km væk'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            if (loading)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (visibleStations.isEmpty)
              const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Ingen favoritstationer endnu. Tryk på stjernen ved en station.')))
            else
              ...visibleStations.map((station) => _FuelStationCard(
                    station: station,
                    type: selectedType,
                    onFavorite: () => _toggleFavorite(station),
                  )),
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

  const _FuelStationCard({required this.station, required this.type, required this.onFavorite});

  @override
  Widget build(BuildContext context) {
    final minutesAgo = DateTime.now().difference(station.updatedAt).inMinutes;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              child: Text(station.brand.isNotEmpty ? station.brand[0] : '?'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(station.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text('${station.address}, ${station.city}', maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text('${station.distanceKm.toStringAsFixed(1)} km · opdateret for $minutesAgo min. siden', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${station.priceFor(type).toStringAsFixed(2)} kr.', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  tooltip: station.favorite ? 'Fjern favorit' : 'Gem favorit',
                  onPressed: onFavorite,
                  icon: Icon(station.favorite ? Icons.star : Icons.star_border),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
