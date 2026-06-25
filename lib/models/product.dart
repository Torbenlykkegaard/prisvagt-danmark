class Product {
  final String id;
  final String name;
  final String store;
  final String category;
  final double currentPrice;
  final double normalPrice;
  final bool isFavorite;

  const Product({
    required this.id,
    required this.name,
    required this.store,
    required this.category,
    required this.currentPrice,
    required this.normalPrice,
    this.isFavorite = false,
  });

  double get saving => normalPrice - currentPrice;

  int get savingPercent {
    if (normalPrice <= 0) return 0;
    return ((saving / normalPrice) * 100).round();
  }

  Product copyWith({bool? isFavorite}) {
    return Product(
      id: id,
      name: name,
      store: store,
      category: category,
      currentPrice: currentPrice,
      normalPrice: normalPrice,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

enum WatchStatus { belowTarget, closeToTarget, tooExpensive }

class PriceWatch {
  final String id;
  final String productName;
  final double targetPrice;
  final String? store;
  final String category;
  final DateTime createdAt;

  PriceWatch({
    required this.id,
    required this.productName,
    required this.targetPrice,
    this.store,
    this.category = 'Dagligvarer',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  WatchStatus statusFor(double? currentPrice) {
    if (currentPrice == null) return WatchStatus.tooExpensive;
    if (currentPrice <= targetPrice) return WatchStatus.belowTarget;
    if (currentPrice <= targetPrice * 1.15) return WatchStatus.closeToTarget;
    return WatchStatus.tooExpensive;
  }

  String statusLabel(double? currentPrice) {
    return switch (statusFor(currentPrice)) {
      WatchStatus.belowTarget => 'Under din ønskede pris',
      WatchStatus.closeToTarget => 'Tæt på',
      WatchStatus.tooExpensive => 'For dyr',
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'targetPrice': targetPrice,
      'store': store,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PriceWatch.fromJson(Map<String, dynamic> json) {
    return PriceWatch(
      id: json['id'] as String,
      productName: json['productName'] as String,
      targetPrice: (json['targetPrice'] as num).toDouble(),
      store: json['store'] as String?,
      category: json['category'] as String? ?? 'Dagligvarer',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  PriceWatch copyWith({
    String? productName,
    double? targetPrice,
    String? store,
    String? category,
  }) {
    return PriceWatch(
      id: id,
      productName: productName ?? this.productName,
      targetPrice: targetPrice ?? this.targetPrice,
      store: store ?? this.store,
      category: category ?? this.category,
      createdAt: createdAt,
    );
  }
}
