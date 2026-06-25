import 'package:flutter/material.dart';

import '../services/price_service.dart';
import '../widgets/offer_card.dart';

class OffersScreen extends StatefulWidget {
  final Set<String> favoriteStores;

  const OffersScreen({super.key, required this.favoriteStores});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  String query = '';
  String category = 'Alle';

  @override
  Widget build(BuildContext context) {
    final products = PriceService.search(query: query, category: category, favoriteStores: widget.favoriteStores);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Tilbud', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Søg produkt, butik eller kategori', border: OutlineInputBorder()),
            onChanged: (value) => setState(() => query = value),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: PriceService.categories.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(item),
                    selected: category == item,
                    onSelected: (_) => setState(() => category = item),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          if (widget.favoriteStores.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Filtreret efter favoritbutikker: ${widget.favoriteStores.join(', ')}'),
            ),
          if (products.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Ingen tilbud matcher dine filtre.')))
          else
            ...products.map((product) => OfferCard(product: product)),
        ],
      ),
    );
  }
}
