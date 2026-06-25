class ShoppingItem {
  final String id;
  final String name;
  final String store;
  final String category;
  final double estimatedPrice;
  final bool checked;
  final DateTime createdAt;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.store,
    required this.category,
    required this.estimatedPrice,
    this.checked = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ShoppingItem copyWith({
    String? name,
    String? store,
    String? category,
    double? estimatedPrice,
    bool? checked,
  }) {
    return ShoppingItem(
      id: id,
      name: name ?? this.name,
      store: store ?? this.store,
      category: category ?? this.category,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      checked: checked ?? this.checked,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'store': store,
      'category': category,
      'estimatedPrice': estimatedPrice,
      'checked': checked,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      store: json['store'] as String? ?? 'Alle butikker',
      category: json['category'] as String? ?? 'Dagligvarer',
      estimatedPrice: (json['estimatedPrice'] as num? ?? 0).toDouble(),
      checked: json['checked'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
