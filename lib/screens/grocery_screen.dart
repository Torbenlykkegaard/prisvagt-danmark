import 'package:flutter/material.dart';

import '../models/grocery_offer.dart';
import '../services/grocery_price_service.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  bool loading = true;
  String? error;
  String query = '';
  String selectedCategory = 'Alle';

  List<GroceryOffer> offers = [];

  final categories = const [
    'Alle',
    'Mejeri',
    'Drikkevarer',
    'Kød',
    'Brød',
    'Frugt & grønt',
    'Æg',
    'Andet',
  ];

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await GroceryPriceService.fetchLiveOffers(
        query: query,
        limit: 100,
      );

      setState(() {
        offers = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Kunne ikke hente live madvaretilbud: $e';
        offers = [];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleOffers = offers.where((offer) {
      if (selectedCategory == 'Alle') return true;
      return offer.category == selectedCategory;
    }).toList();

    final cheapest = visibleOffers.isEmpty ? null : visibleOffers.first;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadOffers,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Madvarer',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Opdater tilbud',
                  onPressed: _loadOffers,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Live tilbud fra eTilbudsavis/Tjek. Priser kan ændre sig og bør kontrolleres i butikken.'),
            const SizedBox(height: 12),

            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Søg efter mælk, kaffe, smør, kød...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                query = value;
              },
              onSubmitted: (_) => _loadOffers(),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = categories[index];

                  return ChoiceChip(
                    label: Text(category),
                    selected: selectedCategory == category,
                    onSelected: (_) {
                      setState(() => selectedCategory = category);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            if (error != null)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(error!),
                ),
              ),

            if (cheapest != null)
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Billigste i listen',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cheapest.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('${cheapest.store} · ${cheapest.price.toStringAsFixed(2)} kr.'),
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
            else if (visibleOffers.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Ingen madvaretilbud fundet. Prøv en anden søgning eller kategori.'),
                ),
              )
            else
              ...visibleOffers.map(
                    (offer) => _GroceryOfferCard(offer: offer),
              ),
          ],
        ),
      ),
    );
  }
}

class _GroceryOfferCard extends StatelessWidget {
  final GroceryOffer offer;

  const _GroceryOfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final hasImage = offer.imageUrl.trim().isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: hasImage
                  ? Image.network(
                offer.imageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
                  : _placeholder(),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    offer.store,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    offer.description.replaceAll('\n', ' '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offer.category,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${offer.price.toStringAsFixed(2)} kr.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (offer.beforePrice != null)
                  Text(
                    'før ${offer.beforePrice!.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                if (offer.saving > 0)
                  Text(
                    'spar ${offer.saving.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 72,
      height: 72,
      color: Colors.black12,
      child: const Icon(Icons.local_grocery_store_outlined),
    );
  }
}