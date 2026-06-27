import 'package:dio/dio.dart';

import '../models/grocery_offer.dart';

class GroceryPriceService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 25),
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'PrisVagtDanmark/1.0',
      },
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  static Future<List<GroceryOffer>> fetchLiveOffers({
    String query = '',
    int limit = 100,
  }) async {
    final endpoints = [
      Uri.https('api.etilbudsavis.dk', '/v2/offers').toString(),
      Uri.https('api.etilbudsavis.dk', '/v2/offers', {
        'r_lat': '57.4567',
        'r_lng': '9.9827',
        'r_radius': '25000',
      }).toString(),
    ];

    for (final endpoint in endpoints) {
      final response = await _dio.get(endpoint);

      if (response.statusCode == 200) {
        final offers = _parseOffers(response.data, query);

        if (offers.isNotEmpty) {
          offers.sort((a, b) => a.price.compareTo(b.price));
          return offers.take(limit).toList();
        }
      }
    }

    return [];
  }

  static List<GroceryOffer> _parseOffers(dynamic data, String query) {
    final List rawList;

    if (data is List) {
      rawList = data;
    } else if (data is Map && data['data'] is List) {
      rawList = data['data'];
    } else if (data is Map && data['offers'] is List) {
      rawList = data['offers'];
    } else {
      rawList = [];
    }

    var offers = rawList
        .whereType<Map>()
        .map((item) => GroceryOffer.fromJson(Map<String, dynamic>.from(item)))
        .where((offer) => offer.price > 0)
        .toList();

    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();

      offers = offers.where((offer) {
        return offer.title.toLowerCase().contains(q) ||
            offer.description.toLowerCase().contains(q) ||
            offer.store.toLowerCase().contains(q) ||
            offer.category.toLowerCase().contains(q);
      }).toList();
    }

    return offers;
  }
}