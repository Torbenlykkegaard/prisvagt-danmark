import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/shopping_item.dart';

class ReceiptScannerScreen extends StatefulWidget {
  final Future<void> Function(ShoppingItem item) onAddShoppingItem;

  const ReceiptScannerScreen({super.key, required this.onAddShoppingItem});

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _receiptImage;
  bool _isScanning = false;
  List<_ReceiptLine> _lines = [];

  Future<void> _pickReceipt(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 85);
    if (image == null) return;

    setState(() {
      _receiptImage = image;
      _isScanning = true;
      _lines = [];
    });

    await Future.delayed(const Duration(milliseconds: 900));

    setState(() {
      _isScanning = false;
      _lines = _demoReceiptLines();
    });
  }

  Future<void> _addAllToShoppingList() async {
    for (final line in _lines) {
      await widget.onAddShoppingItem(
        ShoppingItem(
          id: 'receipt-${DateTime.now().microsecondsSinceEpoch}-${line.name}',
          name: line.name,
          store: line.store,
          category: 'Dagligvarer',
          estimatedPrice: line.price,
          checked: false,
        ),
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_lines.length} varer er tilføjet til indkøbslisten')),
    );
  }

  double get _total => _lines.fold(0, (sum, line) => sum + line.price);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kvitteringsscanner')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Scan kvittering', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Tag et billede eller vælg en kvittering. I v3.0 bruges en lokal demo-scanning, så funktionen kan testes uden backend.'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _pickReceipt(ImageSource.camera),
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text('Tag billede'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _pickReceipt(ImageSource.gallery),
                        icon: const Icon(Icons.upload_file_outlined),
                        label: const Text('Vælg billede'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_receiptImage != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.receipt_long),
                title: Text(_receiptImage!.name.isEmpty ? 'Kvittering valgt' : _receiptImage!.name),
                subtitle: const Text('Billedet er klar til lokal demo-scanning'),
              ),
            ),
          if (_isScanning)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_lines.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text('Fundne varer', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
                        Text('${_total.toStringAsFixed(2)} kr.', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._lines.map((line) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(line.name),
                          subtitle: Text(line.store),
                          trailing: Text('${line.price.toStringAsFixed(2)} kr.'),
                        )),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _addAllToShoppingList,
                      icon: const Icon(Icons.playlist_add),
                      label: const Text('Tilføj til indkøbsliste'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Næste udvidelse', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Senere kan vi koble rigtig OCR på, så appen automatisk læser produktnavne og priser fra kvitteringsbilledet.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_ReceiptLine> _demoReceiptLines() {
    final stores = ['Netto', 'Rema 1000', 'Føtex', 'Bilka'];
    final items = [
      _ReceiptLine('Mælk 1L', 12.95, stores[Random().nextInt(stores.length)]),
      _ReceiptLine('Kaffe', 39.00, stores[Random().nextInt(stores.length)]),
      _ReceiptLine('Rugbrød', 18.50, stores[Random().nextInt(stores.length)]),
      _ReceiptLine('Bananer', 16.75, stores[Random().nextInt(stores.length)]),
      _ReceiptLine('Kærgården', 21.95, stores[Random().nextInt(stores.length)]),
    ];
    return items;
  }
}

class _ReceiptLine {
  final String name;
  final double price;
  final String store;

  _ReceiptLine(this.name, this.price, this.store);
}
