// CSV-eksport til Flutter Web.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

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

    final blob = html.Blob([rows.join('\n')], 'text/csv;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'prisvagt_danmark_export.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
    return 'CSV-download startet.';
  }

  static String _escape(String value) {
    final cleaned = value.replaceAll('"', '""');
    return '"$cleaned"';
  }
}
