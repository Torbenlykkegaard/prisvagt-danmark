import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/price_service.dart';

class PriceHistoryScreen extends StatelessWidget {
  final List<PriceWatch> watches;

  const PriceHistoryScreen({super.key, required this.watches});

  @override
  Widget build(BuildContext context) {
    final products = PriceService.demoProducts;
    final bestDrops = [...products]..sort((a, b) => b.savingPercent.compareTo(a.savingPercent));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Prishistorik', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Se om et tilbud er stærkt, middel eller svagt baseret på demo-prishistorik.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Prisvagt-overblik', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (watches.isEmpty)
                  const Text('Du har ingen prisvagter endnu.')
                else
                  ...watches.map((watch) {
                    final product = PriceService.findBestMatch(watch);
                    final history = product == null ? <double>[] : PriceService.priceHistoryFor(product.id);
                    final lowest = history.isEmpty ? null : history.reduce((a, b) => a < b ? a : b);
                    final highest = history.isEmpty ? null : history.reduce((a, b) => a > b ? a : b);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(product != null && product.currentPrice <= watch.targetPrice ? Icons.check_circle : Icons.visibility_outlined),
                      title: Text(watch.productName, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(product == null
                          ? 'Ingen demo-pris fundet endnu'
                          : 'Nu ${product.currentPrice.toStringAsFixed(2)} kr. • lavest ${lowest!.toStringAsFixed(2)} kr. • højest ${highest!.toStringAsFixed(2)} kr.'),
                      trailing: Text(product == null ? '-' : PriceService.dealStrength(product)),
                    );
                  }),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Text('Bedste prisfald', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...bestDrops.map((product) => _HistoryCard(product: product)),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Product product;

  const _HistoryCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final history = PriceService.priceHistoryFor(product.id);
    final lowest = history.reduce((a, b) => a < b ? a : b);
    final highest = history.reduce((a, b) => a > b ? a : b);
    final strength = PriceService.dealStrength(product);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(product.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
              Chip(label: Text(strength)),
            ],
          ),
          const SizedBox(height: 4),
          Text('${product.store} • ${product.category}'),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _MiniStat(label: 'Nu', value: '${product.currentPrice.toStringAsFixed(2)} kr.'),
            _MiniStat(label: 'Lavest', value: '${lowest.toStringAsFixed(2)} kr.'),
            _MiniStat(label: 'Højest', value: '${highest.toStringAsFixed(2)} kr.'),
            _MiniStat(label: 'Sparer', value: '${product.savingPercent}%'),
          ]),
          const SizedBox(height: 14),
          _Sparkline(values: history),
        ]),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}

class _Sparkline extends StatelessWidget {
  final List<double> values;

  const _Sparkline({required this.values});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(values: values, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;

  _SparklinePainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = (maxValue - minValue) == 0 ? 1 : maxValue - minValue;
    final path = Path();

    for (var i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final y = size.height - (((values[i] - minValue) / range) * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), gridPaint);
    canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), gridPaint);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}
