import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/shopping_item.dart';
import '../services/price_service.dart';

class ShoppingListScreen extends StatefulWidget {
  final List<ShoppingItem> items;
  final Future<void> Function(ShoppingItem item) onSaveItem;
  final Future<void> Function(String id) onDeleteItem;
  final Future<void> Function() onClearChecked;

  const ShoppingListScreen({
    super.key,
    required this.items,
    required this.onSaveItem,
    required this.onDeleteItem,
    required this.onClearChecked,
  });

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items.where((item) {
      final text = '${item.name} ${item.store} ${item.category}'.toLowerCase();
      return text.contains(query.trim().toLowerCase());
    }).toList()
      ..sort((a, b) => a.checked == b.checked ? a.name.compareTo(b.name) : a.checked ? 1 : -1);

    final total = widget.items.fold<double>(0, (sum, item) => sum + item.estimatedPrice);
    final checkedTotal = widget.items.where((item) => item.checked).fold<double>(0, (sum, item) => sum + item.estimatedPrice);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: Text('Indkøbsliste', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold))),
              FilledButton.icon(
                onPressed: () => _showItemSheet(context),
                icon: const Icon(Icons.add),
                label: const Text('Tilføj'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _Metric(label: 'Estimeret total', value: '${total.toStringAsFixed(0)} kr.'),
                  _Metric(label: 'Markeret købt', value: '${checkedTotal.toStringAsFixed(0)} kr.'),
                  _Metric(label: 'Varer', value: '${widget.items.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Søg i indkøbslisten', border: OutlineInputBorder()),
            onChanged: (value) => setState(() => query = value),
          ),
          const SizedBox(height: 12),
          if (widget.items.any((item) => item.checked))
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: widget.onClearChecked,
                icon: const Icon(Icons.cleaning_services_outlined),
                label: const Text('Fjern købte varer'),
              ),
            ),
          const SizedBox(height: 8),
          if (filtered.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Ingen varer endnu. Tilføj dine faste varer eller lav en indkøbsliste ud fra tilbud.')))
          else
            ...filtered.map((item) => Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      children: [
                        Checkbox(
                          value: item.checked,
                          onChanged: (value) => widget.onSaveItem(item.copyWith(checked: value ?? false)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  decoration: item.checked ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.store} · ${item.category}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.estimatedPrice.toStringAsFixed(2)} kr.',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _showItemSheet(context, item: item)),
                        IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => widget.onDeleteItem(item.id)),
                      ],
                    ),
                  ),
                )),
          const SizedBox(height: 16),
          Text('Hurtig tilføjelse fra tilbud', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...PriceService.demoProducts.take(6).map((product) => Card(
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text('${product.store} · spar ${product.saving.toStringAsFixed(0)} kr.'),
                  trailing: FilledButton.tonal(
                    onPressed: () => widget.onSaveItem(ShoppingItem(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      name: product.name,
                      store: product.store,
                      category: product.category,
                      estimatedPrice: product.currentPrice,
                    )),
                    child: const Text('Tilføj'),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _showItemSheet(BuildContext context, {ShoppingItem? item}) {
    final name = TextEditingController(text: item?.name ?? '');
    final store = TextEditingController(text: item?.store ?? '');
    final price = TextEditingController(text: item?.estimatedPrice.toStringAsFixed(2) ?? '');
    String category = item?.category ?? 'Dagligvarer';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item == null ? 'Tilføj vare' : 'Rediger vare', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Produkt', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: store, decoration: const InputDecoration(labelText: 'Butik', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Estimeret pris', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                items: PriceService.categories.where((category) => category != 'Alle').map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
                onChanged: (value) => setSheetState(() => category = value ?? category),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  final parsedPrice = double.tryParse(price.text.replaceAll(',', '.')) ?? 0;
                  if (name.text.trim().isEmpty) return;
                  widget.onSaveItem(ShoppingItem(
                    id: item?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                    name: name.text.trim(),
                    store: store.text.trim().isEmpty ? 'Alle butikker' : store.text.trim(),
                    category: category,
                    estimatedPrice: parsedPrice,
                    checked: item?.checked ?? false,
                    createdAt: item?.createdAt,
                  ));
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text('Gem vare'),
              ),
            ],
          ),
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
    return SizedBox(
      width: 150,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        Text(label),
      ]),
    );
  }
}
