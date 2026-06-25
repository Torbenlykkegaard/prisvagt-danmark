import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/export_service.dart';
import '../services/notification_service.dart';
import '../services/price_service.dart';
import '../services/pwa_service.dart';

class ProfileScreen extends StatelessWidget {
  final List<PriceWatch> watches;
  final Set<String> favoriteStores;
  final bool darkMode;
  final double monthlyGoal;
  final Future<void> Function(String store) onToggleStore;
  final Future<void> Function(bool value) onToggleDarkMode;
  final Future<void> Function(double value) onUpdateMonthlyGoal;

  const ProfileScreen({
    super.key,
    required this.watches,
    required this.favoriteStores,
    required this.darkMode,
    required this.monthlyGoal,
    required this.onToggleStore,
    required this.onToggleDarkMode,
    required this.onUpdateMonthlyGoal,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Profil', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Installer som Edge-app', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(PwaService.isInstalled
                      ? 'Appen kører allerede som installeret PWA.'
                      : 'Installer PrisVagt Danmark på PC, så den åbner som et normalt program og kan bruges hurtigere.'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: PwaService.isInstalled
                        ? null
                        : () async {
                            final installed = await PwaService.install();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(installed ? 'Installeret i Edge.' : 'Edge viser kun installation, når appen køres som web-build på localhost eller HTTPS.')),
                            );
                          },
                    icon: const Icon(Icons.install_desktop),
                    label: const Text('Installer app'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Data og alarmer', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Eksporter dine prisvagter eller test browser-notifikationer for tilbud, der matcher dine ønskepriser.'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: watches.isEmpty ? null : () async {
                          final message = await ExportService.downloadCsv(watches);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        },
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Eksporter CSV'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final count = await NotificationService.notifyMatchingWatches(watches);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(count == 0 ? 'Ingen prisvagter matcher lige nu.' : '$count matchende prisvagter fundet.')),
                          );
                        },
                        icon: const Icon(Icons.notifications_active_outlined),
                        label: const Text('Test notifikationer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sparemål', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Månedligt mål: ${monthlyGoal.toStringAsFixed(0)} kr.'),
                  Slider(
                    value: monthlyGoal.clamp(100, 2000),
                    min: 100,
                    max: 2000,
                    divisions: 19,
                    label: '${monthlyGoal.toStringAsFixed(0)} kr.',
                    onChanged: (value) => onUpdateMonthlyGoal(value),
                  ),
                  const Text('Bruges på statistik-siden til at vise, om brugeren er på vej mod sit mål.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              title: const Text('Mørk tilstand'),
              subtitle: const Text('Gemmes lokalt i browseren'),
              value: darkMode,
              onChanged: onToggleDarkMode,
            ),
          ),
          const SizedBox(height: 16),
          Text('Favoritbutikker', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Vælg butikker du vil prioritere på tilbudssiden.'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PriceService.stores.map((store) {
              return FilterChip(
                label: Text(store),
                selected: favoriteStores.contains(store),
                onSelected: (_) => onToggleStore(store),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PrisVagt Danmark v2.3 PWA', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Gratis installérbar Edge-app med lokal lagring, statistik, sparemål, smart anbefalinger, CSV-eksport, browser-notifikationer og offline-cache.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
