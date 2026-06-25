import 'dart:io';

import '../models/product.dart';
import 'price_service.dart';

class ExportService {
  static Future<String> downloadCsv(List<PriceWatch> watches) async {
    final rows = <String>[
      'Produkt;Kategori;Butik;Ønskepris;Aktuel pris;Status;Mulig besparelse',
      ...watches.map((watch) {
        final product = PriceService.findBestMatch(watch);
        final current = product?.currentPrice;
        final status = watch.statusLabel(current);
        final saving = current == null ? 0 : (watch.targetPrice - current).clamp(0, double.infinity);
        return [
          _escape(watch.productName),
          _escape(watch.category),
          _escape(watch.store ?? 'Alle butikker'),
          watch.targetPrice.toStringAsFixed(2),
          current?.toStringAsFixed(2) ?? '',
          _escape(status),
          saving.toStringAsFixed(2),
        ].join(';');
      }),
    ];

    final file = File('${Directory.systemTemp.path}${Platform.pathSeparator}prisvagt_danmark_export.csv');
    await file.writeAsString(rows.join('\n'));
    return 'CSV gemt midlertidigt her: ${file.path}';
  }

  static String _escape(String value) {
    final cleaned = value.replaceAll('"', '""');
    return '"$cleaned"';
  }
}
