// Browser-notifikationer til Flutter Web.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import '../models/product.dart';
import 'price_service.dart';

class NotificationService {
  static bool get isSupported => html.Notification.supported;

  static Future<bool> requestPermission() async {
    if (!isSupported) return false;
    final permission = await html.Notification.requestPermission();
    return permission == 'granted';
  }

  static Future<int> notifyMatchingWatches(List<PriceWatch> watches) async {
    final allowed = await requestPermission();
    if (!allowed) return 0;

    var count = 0;
    for (final watch in watches) {
      final product = PriceService.findBestMatch(watch);
      if (product != null && product.currentPrice <= watch.targetPrice) {
        html.Notification(
          'PrisVagt: ${watch.productName}',
          body: '${product.store}: ${product.currentPrice.toStringAsFixed(2)} kr. er under din ønskepris.',
        );
        count++;
      }
    }
    return count;
  }
}
