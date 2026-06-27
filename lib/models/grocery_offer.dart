class GroceryOffer {
  final String id;
  final String title;
  final String description;
  final String store;
  final double price;
  final double? beforePrice;
  final String imageUrl;
  final String category;

  const GroceryOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.store,
    required this.price,
    required this.beforePrice,
    required this.imageUrl,
    required this.category,
  });

  double get saving {
    if (beforePrice == null || beforePrice! <= price) return 0;
    return beforePrice! - price;
  }

  factory GroceryOffer.fromJson(Map<String, dynamic> json) {
    final pricing = json['pricing'] as Map<String, dynamic>? ?? {};
    final dealer = json['dealer'] as Map<String, dynamic>? ?? {};
    final images = json['images'] as Map<String, dynamic>? ?? {};

    final title = (json['heading'] ?? json['title'] ?? 'Ukendt vare').toString();
    final description = (json['description'] ?? '').toString();

    final priceRaw = pricing['price'];
    final beforeRaw = pricing['pre_price'];

    return GroceryOffer(
      id: (json['id'] ?? '').toString(),
      title: title,
      description: description,
      store: (dealer['name'] ?? 'Ukendt butik').toString(),
      price: priceRaw is num ? priceRaw.toDouble() : 0,
      beforePrice: beforeRaw is num ? beforeRaw.toDouble() : null,
      imageUrl: (images['thumb'] ?? images['view'] ?? '').toString(),
      category: _guessCategory('$title $description'),
    );
  }

  static String _guessCategory(String text) {
    final lower = text.toLowerCase();

    if (_containsAny(lower, ['mælk', 'ost', 'smør', 'yoghurt', 'arla'])) return 'Mejeri';
    if (_containsAny(lower, ['kaffe', 'cola', 'sodavand', 'vand', 'juice'])) return 'Drikkevarer';
    if (_containsAny(lower, ['kylling', 'oksekød', 'pølser', 'bacon', 'kød'])) return 'Kød';
    if (_containsAny(lower, ['brød', 'boller', 'rugbrød', 'toast'])) return 'Brød';
    if (_containsAny(lower, ['æble', 'banan', 'tomat', 'agurk', 'kartofler'])) return 'Frugt & grønt';

    return 'Andet';
  }

  static bool _containsAny(String text, List<String> words) {
    return words.any((word) => text.contains(word));
  }
}