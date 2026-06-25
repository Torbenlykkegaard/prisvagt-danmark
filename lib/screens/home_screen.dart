import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/price_service.dart';
import '../widgets/offer_card.dart';

class HomeScreen extends StatelessWidget {
  final List<PriceWatch> watches;
  final Set<String> favoriteStores;

  const HomeScreen({super.key, required this.watches, required this.favoriteStores});

  @override
  Widget build(BuildContext context) {
    final products = PriceService.search(query: '', category: 'Alle', favoriteStores: favoriteStores);
    final totalSaving = PriceService.totalPotentialSaving(products.take(5).toList());
    final matches = watches.where((watch) {
      final product = PriceService.findBestMatch(watch);
      return product != null && product.currentPrice <= watch.targetPrice;
    }).length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('PrisVagt Danmark', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Spar penge hver dag', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          _DashboardCard(totalSaving: totalSaving, activeWatches: watches.length, matchedWatches: matches),
          const SizedBox(height: 16),
          Text('Bedste tilbud lige nu', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...products.take(5).map((product) => OfferCard(product: product)),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final double totalSaving;
  final int activeWatches;
  final int matchedWatches;

  const _DashboardCard({required this.totalSaving, required this.activeWatches, required this.matchedWatches});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dit overblik', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colors.onPrimaryContainer)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _Metric(label: 'Mulig besparelse', value: '${totalSaving.toStringAsFixed(0)} kr.'),
                _Metric(label: 'Aktive prisvagter', value: '$activeWatches'),
                _Metric(label: 'Matcher nu', value: '$matchedWatches'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        Text(label),
      ]),
    );
  }
}
