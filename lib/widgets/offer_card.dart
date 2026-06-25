import 'package:flutter/material.dart';

import '../models/product.dart';

class OfferCard extends StatelessWidget {
  final Product product;

  const OfferCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colors.secondaryContainer,
          child: Icon(Icons.savings_outlined, color: colors.onSecondaryContainer),
        ),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${product.store} • ${product.category} • Normalpris ${product.normalPrice.toStringAsFixed(2)} kr.'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${product.currentPrice.toStringAsFixed(2)} kr.', style: TextStyle(fontWeight: FontWeight.bold, color: colors.secondary)),
            Text('-${product.savingPercent}%', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
