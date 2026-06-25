import '../models/product.dart';
import 'price_service.dart';

class NotificationService {
  static bool get isSupported => false;

  static Future<bool> requestPermission() async => false;

  static Future<int> notifyMatchingWatches(List<PriceWatch> watches) async {
    // Android-versionen bruger ikke browser-notifikationer.
    // Funktionen tæller stadig matchende prisvagter, så appen kan testes uden build-fejl.
    var count = 0;
    for (final watch in watches) {
      final product = PriceService.findBestMatch(watch);
      if (product != null && product.currentPrice <= watch.targetPrice) {
        count++;
      }
    }
    return count;
  }
}
