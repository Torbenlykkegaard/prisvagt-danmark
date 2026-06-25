import '../models/product.dart';

class PriceService {
  static const categories = [
    'Alle',
    'Dagligvarer',
    'Brændstof',
    'El',
    'Streaming',
    'Mobil',
  ];

  static const stores = [
    'Netto',
    'Rema 1000',
    'Bilka',
    'Coop',
    'OK',
    'Circle K',
    'Energi Danmark',
    'Netflix',
    'YouSee',
  ];

  static List<Product> demoProducts = const [
    Product(id: 'p1', name: 'Nescafé Gold 200g', store: 'Netto', category: 'Dagligvarer', currentPrice: 39, normalPrice: 59),
    Product(id: 'p2', name: 'Kærgården 200g', store: 'Rema 1000', category: 'Dagligvarer', currentPrice: 18, normalPrice: 26),
    Product(id: 'p3', name: 'Arla minimælk 1L', store: 'Bilka', category: 'Dagligvarer', currentPrice: 10, normalPrice: 14),
    Product(id: 'p4', name: 'Benzin 95', store: 'OK', category: 'Brændstof', currentPrice: 13.79, normalPrice: 14.59),
    Product(id: 'p5', name: 'Diesel', store: 'Circle K', category: 'Brændstof', currentPrice: 12.89, normalPrice: 13.69),
    Product(id: 'p6', name: 'Elpris Vestdanmark', store: 'Energi Danmark', category: 'El', currentPrice: 1.92, normalPrice: 2.45),
    Product(id: 'p7', name: 'Netflix Basis', store: 'Netflix', category: 'Streaming', currentPrice: 79, normalPrice: 99),
    Product(id: 'p8', name: 'Mobil 20GB', store: 'YouSee', category: 'Mobil', currentPrice: 99, normalPrice: 149),
    Product(id: 'p9', name: 'Pasta 500g', store: 'Coop', category: 'Dagligvarer', currentPrice: 8, normalPrice: 15),
    Product(id: 'p10', name: 'Hakket oksekød 400g', store: 'Bilka', category: 'Dagligvarer', currentPrice: 34, normalPrice: 49),
  ];

  static List<Product> search({
    required String query,
    required String category,
    required Set<String> favoriteStores,
  }) {
    final normalized = query.trim().toLowerCase();
    return demoProducts.where((product) {
      final matchesSearch = normalized.isEmpty ||
          product.name.toLowerCase().contains(normalized) ||
          product.store.toLowerCase().contains(normalized) ||
          product.category.toLowerCase().contains(normalized);
      final matchesCategory = category == 'Alle' || product.category == category;
      final matchesStore = favoriteStores.isEmpty || favoriteStores.contains(product.store);
      return matchesSearch && matchesCategory && matchesStore;
    }).toList()
      ..sort((a, b) => b.savingPercent.compareTo(a.savingPercent));
  }

  static Product? findBestMatch(PriceWatch watch) {
    final name = watch.productName.toLowerCase();
    final matches = demoProducts.where((product) {
      final sameStore = watch.store == null || watch.store!.isEmpty || product.store == watch.store;
      return sameStore && product.name.toLowerCase().contains(name.split(' ').first);
    }).toList();
    if (matches.isEmpty) return null;
    matches.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
    return matches.first;
  }

  static double totalPotentialSaving(List<Product> products) {
    return products.fold(0, (sum, product) => sum + product.saving);
  }


  static List<double> priceHistoryFor(String productId) {
    final histories = <String, List<double>>{
      'p1': [59, 55, 49, 45, 42, 39],
      'p2': [26, 24, 22, 21, 19, 18],
      'p3': [14, 13, 12, 11, 10, 10],
      'p4': [14.59, 14.39, 14.19, 13.99, 13.89, 13.79],
      'p5': [13.69, 13.49, 13.39, 13.19, 12.99, 12.89],
      'p6': [2.45, 2.32, 2.18, 2.05, 1.98, 1.92],
      'p7': [99, 99, 89, 89, 79, 79],
      'p8': [149, 139, 129, 119, 109, 99],
      'p9': [15, 14, 12, 10, 9, 8],
      'p10': [49, 45, 42, 39, 36, 34],
    };
    return histories[productId] ?? const [0, 0, 0, 0, 0, 0];
  }

  static String dealStrength(Product product) {
    if (product.savingPercent >= 35) return 'Stærkt tilbud';
    if (product.savingPercent >= 20) return 'Godt tilbud';
    if (product.savingPercent >= 10) return 'Middel';
    return 'Svagt';
  }

  static Map<String, double> savingByCategory(List<Product> products) {
    final result = <String, double>{};
    for (final product in products) {
      result[product.category] = (result[product.category] ?? 0) + product.saving;
    }
    final entries = result.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries);
  }
}
