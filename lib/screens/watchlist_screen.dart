import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/price_service.dart';

class WatchlistScreen extends StatelessWidget {
  final List<PriceWatch> watches;
  final Future<void> Function(PriceWatch watch) onSaveWatch;
  final Future<void> Function(String id) onDeleteWatch;

  const WatchlistScreen({super.key, required this.watches, required this.onSaveWatch, required this.onDeleteWatch});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Prisvagter', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Opret alarmer for produkter, du vil købe billigere.'),
            const SizedBox(height: 16),
            if (watches.isEmpty)
              const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Du har ingen prisvagter endnu.')))
            else
              ...watches.map((watch) => _WatchCard(watch: watch, onEdit: () => _openEditor(context, watch), onDelete: () => onDeleteWatch(watch.id))),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openEditor(context, null),
          icon: const Icon(Icons.add),
          label: const Text('Ny prisvagt'),
        ),
      ),
    );
  }

  void _openEditor(BuildContext context, PriceWatch? watch) {
    showDialog(
      context: context,
      builder: (context) => _WatchEditor(watch: watch, onSave: onSaveWatch),
    );
  }
}

class _WatchCard extends StatelessWidget {
  final PriceWatch watch;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WatchCard({required this.watch, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final product = PriceService.findBestMatch(watch);
    final status = watch.statusFor(product?.currentPrice);
    final statusText = switch (status) {
      WatchStatus.belowTarget => 'Under din ønskede pris',
      WatchStatus.closeToTarget => 'Tæt på',
      WatchStatus.tooExpensive => 'For dyr',
    };
    final icon = switch (status) {
      WatchStatus.belowTarget => Icons.check_circle,
      WatchStatus.closeToTarget => Icons.info,
      WatchStatus.tooExpensive => Icons.hourglass_bottom,
    };

    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(watch.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${watch.category} • Ønskepris ${watch.targetPrice.toStringAsFixed(2)} kr. • ${watch.store ?? 'Alle butikker'}\n$statusText${product == null ? '' : ' • Nu ${product.currentPrice.toStringAsFixed(2)} kr.'}'),
        isThreeLine: true,
        trailing: Wrap(
          children: [
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline)),
          ],
        ),
      ),
    );
  }
}

class _WatchEditor extends StatefulWidget {
  final PriceWatch? watch;
  final Future<void> Function(PriceWatch watch) onSave;

  const _WatchEditor({required this.watch, required this.onSave});

  @override
  State<_WatchEditor> createState() => _WatchEditorState();
}

class _WatchEditorState extends State<_WatchEditor> {
  late final TextEditingController nameController;
  late final TextEditingController priceController;
  String? store;
  String category = 'Dagligvarer';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.watch?.productName ?? '');
    priceController = TextEditingController(text: widget.watch?.targetPrice.toStringAsFixed(2) ?? '');
    store = widget.watch?.store;
    category = widget.watch?.category ?? 'Dagligvarer';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.watch == null ? 'Ny prisvagt' : 'Rediger prisvagt'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Produktnavn')),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Ønskepris'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: PriceService.categories.where((item) => item != 'Alle').map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: (value) => setState(() => category = value ?? category),
            ),
            DropdownButtonFormField<String?>(
              value: store,
              decoration: const InputDecoration(labelText: 'Butik'),
              items: [const DropdownMenuItem<String?>(value: null, child: Text('Alle butikker')), ...PriceService.stores.map((item) => DropdownMenuItem<String?>(value: item, child: Text(item)))],
              onChanged: (value) => setState(() => store = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuller')),
        FilledButton(
          onPressed: () async {
            final price = double.tryParse(priceController.text.replaceAll(',', '.'));
            if (nameController.text.trim().isEmpty || price == null) return;
            await widget.onSave(PriceWatch(
              id: widget.watch?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
              productName: nameController.text.trim(),
              targetPrice: price,
              store: store,
              category: category,
              createdAt: widget.watch?.createdAt,
            ));
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Gem'),
        ),
      ],
    );
  }
}
