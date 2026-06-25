import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/price_service.dart';

class StatisticsScreen extends StatelessWidget {
  final List<PriceWatch> watches;
  final double monthlyGoal;

  const StatisticsScreen({super.key, required this.watches, required this.monthlyGoal});

  @override
  Widget build(BuildContext context) {
    final products = PriceService.search(query: '', category: 'Alle', favoriteStores: {});
    final totalSaving = PriceService.totalPotentialSaving(products);
    final monthlyEstimate = totalSaving * 4;
    final progress = monthlyGoal <= 0 ? 0.0 : (monthlyEstimate / monthlyGoal).clamp(0.0, 1.0);
    final matched = watches.where((watch) {
      final product = PriceService.findBestMatch(watch);
      return product != null && product.currentPrice <= watch.targetPrice;
    }).length;
    final byCategory = PriceService.savingByCategory(products);
    final bestProducts = products.take(5).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Statistik', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Månedligt sparemål', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${monthlyEstimate.toStringAsFixed(0)} kr. estimeret / ${monthlyGoal.toStringAsFixed(0)} kr. mål'),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: progress, minHeight: 14),
                const SizedBox(height: 8),
                Text(progress >= 1 ? 'Målet er nået med demo-tilbuddene.' : 'Du mangler ca. ${(monthlyGoal - monthlyEstimate).clamp(0, monthlyGoal).toStringAsFixed(0)} kr. for at nå målet.'),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(label: 'Mulig besparelse pr. uge', value: '${totalSaving.toStringAsFixed(0)} kr.'),
              _StatCard(label: 'Aktive prisvagter', value: '${watches.length}'),
              _StatCard(label: 'Matcher lige nu', value: '$matched'),
            ],
          ),
          const SizedBox(height: 20),
          Text('Smart anbefalinger', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._buildRecommendations(bestProducts, matched).map((text) => Card(
                child: ListTile(
                  leading: const Icon(Icons.tips_and_updates_outlined),
                  title: Text(text),
                ),
              )),
          const SizedBox(height: 12),
          Text('Besparelse efter kategori', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: byCategory.entries.map((entry) {
                  final percent = totalSaving == 0 ? 0.0 : entry.value / totalSaving;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _BarRow(label: entry.key, value: entry.value, percent: percent),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Top 5 tilbud', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...bestProducts.map((product) => Card(
                child: ListTile(
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${product.store} • ${product.category} • normalpris ${product.normalPrice.toStringAsFixed(2)} kr.'),
                  trailing: Text('${product.saving.toStringAsFixed(0)} kr.'),
                ),
              )),
        ],
      ),
    );
  }

  List<String> _buildRecommendations(List<Product> products, int matched) {
    final list = <String>[];
    if (products.isNotEmpty) {
      list.add('Start med ${products.first.name} hos ${products.first.store}. Den giver den største procentvise besparelse lige nu.');
    }
    if (matched > 0) {
      list.add('$matched af dine prisvagter matcher allerede din ønskede pris.');
    } else {
      list.add('Sænk ikke målet endnu. Prøv at tilføje flere butikker til dine favoritbutikker først.');
    }
    list.add('Tjek kategorien Dagligvarer først, fordi små ugentlige køb ofte giver størst samlet effekt.');
    return list;
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label),
          ]),
        ),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final double value;
  final double percent;

  const _BarRow({required this.label, required this.value, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text('${value.toStringAsFixed(0)} kr.'),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(value: percent.clamp(0.0, 1.0), minHeight: 12),
        ),
      ],
    );
  }
}
