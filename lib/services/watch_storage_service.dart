import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import '../models/shopping_item.dart';
import '../models/budget_item.dart';

class WatchStorageService {
  static const String _storageKey = 'prisvagt_watchlist_v1_2';
  static const String _storesKey = 'prisvagt_favorite_stores_v1_2';
  static const String _darkModeKey = 'prisvagt_dark_mode_v1_2';
  static const String _monthlyGoalKey = 'prisvagt_monthly_goal_v2_3';
  static const String _shoppingListKey = 'prisvagt_shopping_list_v2_4';
  static const String _budgetKey = 'prisvagt_budget_v2_5';

  Future<List<PriceWatch>> loadWatches() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) return _defaultWatches;

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((item) => PriceWatch.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return _defaultWatches;
    }
  }

  Future<void> saveWatches(List<PriceWatch> watches) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(watches.map((watch) => watch.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<Set<String>> loadFavoriteStores() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_storesKey) ?? []).toSet();
  }

  Future<void> saveFavoriteStores(Set<String> stores) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storesKey, stores.toList()..sort());
  }

  Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }



  Future<List<ShoppingItem>> loadShoppingItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_shoppingListKey);
    if (raw == null || raw.isEmpty) return _defaultShoppingItems;

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((item) => ShoppingItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return _defaultShoppingItems;
    }
  }

  Future<void> saveShoppingItems(List<ShoppingItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_shoppingListKey, encoded);
  }

  Future<List<BudgetItem>> loadBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_budgetKey);
    if (raw == null || raw.isEmpty) return _defaultBudgets;

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((item) => BudgetItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return _defaultBudgets;
    }
  }

  Future<void> saveBudgets(List<BudgetItem> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(budgets.map((item) => item.toJson()).toList());
    await prefs.setString(_budgetKey, encoded);
  }

  Future<double> loadMonthlyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_monthlyGoalKey) ?? 300;
  }

  Future<void> saveMonthlyGoal(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_monthlyGoalKey, value);
  }

  static List<BudgetItem> get _defaultBudgets => [
        const BudgetItem(id: 'budget-1', category: 'Dagligvarer', monthlyLimit: 1600),
        const BudgetItem(id: 'budget-2', category: 'Brændstof', monthlyLimit: 900),
        const BudgetItem(id: 'budget-3', category: 'Streaming', monthlyLimit: 300),
      ];

  static List<ShoppingItem> get _defaultShoppingItems => [
        ShoppingItem(id: 'shop-1', name: 'Nescafé Gold 200g', store: 'Netto', category: 'Dagligvarer', estimatedPrice: 39),
        ShoppingItem(id: 'shop-2', name: 'Kærgården 200g', store: 'Rema 1000', category: 'Dagligvarer', estimatedPrice: 18),
      ];

  static List<PriceWatch> get _defaultWatches => [
        PriceWatch(id: 'demo-1', productName: 'Nescafe Gold', targetPrice: 35, store: 'Netto', category: 'Dagligvarer'),
        PriceWatch(id: 'demo-2', productName: 'Kaergaarden', targetPrice: 20, store: 'Rema 1000', category: 'Dagligvarer'),
        PriceWatch(id: 'demo-3', productName: 'Benzin 95', targetPrice: 13.50, store: 'OK', category: 'Brændstof'),
      ];
}
