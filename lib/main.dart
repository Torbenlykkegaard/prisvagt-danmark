import 'package:flutter/material.dart';

import 'models/product.dart';
import 'models/shopping_item.dart';
import 'models/budget_item.dart';
import 'screens/budget_screen.dart';
import 'screens/home_screen.dart';
import 'screens/fuel_screen.dart';
import 'screens/offers_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/receipt_scanner_screen.dart';
import 'screens/price_history_screen.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/watchlist_screen.dart';
import 'services/watch_storage_service.dart';

void main() {
  runApp(const PrisVagtApp());
}

class PrisVagtApp extends StatefulWidget {
  const PrisVagtApp({super.key});

  @override
  State<PrisVagtApp> createState() => _PrisVagtAppState();
}

class _PrisVagtAppState extends State<PrisVagtApp> {
  final storage = WatchStorageService();
  List<PriceWatch> watches = [];
  Set<String> favoriteStores = {};
  bool darkMode = false;
  double monthlyGoal = 300;
  List<ShoppingItem> shoppingItems = [];
  List<BudgetItem> budgets = [];
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loadedWatches = await storage.loadWatches();
    final stores = await storage.loadFavoriteStores();
    final theme = await storage.loadDarkMode();
    final goal = await storage.loadMonthlyGoal();
    final loadedShoppingItems = await storage.loadShoppingItems();
    final loadedBudgets = await storage.loadBudgets();
    setState(() {
      watches = loadedWatches;
      favoriteStores = stores;
      darkMode = theme;
      monthlyGoal = goal;
      shoppingItems = loadedShoppingItems;
      budgets = loadedBudgets;
      loaded = true;
    });
  }

  Future<void> upsertWatch(PriceWatch watch) async {
    final index = watches.indexWhere((item) => item.id == watch.id);
    setState(() {
      if (index == -1) {
        watches.add(watch);
      } else {
        watches[index] = watch;
      }
    });
    await storage.saveWatches(watches);
  }

  Future<void> deleteWatch(String id) async {
    setState(() => watches.removeWhere((item) => item.id == id));
    await storage.saveWatches(watches);
  }

  Future<void> upsertShoppingItem(ShoppingItem item) async {
    final index = shoppingItems.indexWhere((entry) => entry.id == item.id);
    setState(() {
      if (index == -1) {
        shoppingItems.add(item);
      } else {
        shoppingItems[index] = item;
      }
    });
    await storage.saveShoppingItems(shoppingItems);
  }

  Future<void> upsertBudget(BudgetItem item) async {
    final index = budgets.indexWhere((entry) => entry.id == item.id);
    setState(() {
      if (index == -1) {
        budgets.add(item);
      } else {
        budgets[index] = item;
      }
    });
    await storage.saveBudgets(budgets);
  }

  Future<void> deleteBudget(String id) async {
    setState(() => budgets.removeWhere((item) => item.id == id));
    await storage.saveBudgets(budgets);
  }

  Future<void> deleteShoppingItem(String id) async {
    setState(() => shoppingItems.removeWhere((item) => item.id == id));
    await storage.saveShoppingItems(shoppingItems);
  }

  Future<void> clearCheckedShoppingItems() async {
    setState(() => shoppingItems.removeWhere((item) => item.checked));
    await storage.saveShoppingItems(shoppingItems);
  }

  Future<void> toggleStore(String store) async {
    setState(() {
      if (favoriteStores.contains(store)) {
        favoriteStores.remove(store);
      } else {
        favoriteStores.add(store);
      }
    });
    await storage.saveFavoriteStores(favoriteStores);
  }

  Future<void> toggleDarkMode(bool value) async {
    setState(() => darkMode = value);
    await storage.saveDarkMode(value);
  }

  Future<void> updateMonthlyGoal(double value) async {
    setState(() => monthlyGoal = value);
    await storage.saveMonthlyGoal(value);
  }

  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF0B2D4D), secondary: const Color(0xFF1E9E62));
    final darkScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF0B2D4D), brightness: Brightness.dark, secondary: const Color(0xFF1E9E62));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PrisVagt Danmark',
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(colorScheme: lightScheme, useMaterial3: true, scaffoldBackgroundColor: const Color(0xFFF6F8FA)),
      darkTheme: ThemeData(colorScheme: darkScheme, useMaterial3: true),
      home: loaded
          ? MainNavigation(
              watches: watches,
              favoriteStores: favoriteStores,
              darkMode: darkMode,
              monthlyGoal: monthlyGoal,
              shoppingItems: shoppingItems,
              budgets: budgets,
              onSaveWatch: upsertWatch,
              onDeleteWatch: deleteWatch,
              onToggleStore: toggleStore,
              onToggleDarkMode: toggleDarkMode,
              onUpdateMonthlyGoal: updateMonthlyGoal,
              onSaveShoppingItem: upsertShoppingItem,
              onSaveBudget: upsertBudget,
              onDeleteBudget: deleteBudget,
              onDeleteShoppingItem: deleteShoppingItem,
              onClearCheckedShoppingItems: clearCheckedShoppingItems,
            )
          : const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final List<PriceWatch> watches;
  final Set<String> favoriteStores;
  final bool darkMode;
  final double monthlyGoal;
  final List<ShoppingItem> shoppingItems;
  final List<BudgetItem> budgets;
  final Future<void> Function(PriceWatch watch) onSaveWatch;
  final Future<void> Function(String id) onDeleteWatch;
  final Future<void> Function(String store) onToggleStore;
  final Future<void> Function(bool value) onToggleDarkMode;
  final Future<void> Function(double value) onUpdateMonthlyGoal;
  final Future<void> Function(ShoppingItem item) onSaveShoppingItem;
  final Future<void> Function(BudgetItem item) onSaveBudget;
  final Future<void> Function(String id) onDeleteBudget;
  final Future<void> Function(String id) onDeleteShoppingItem;
  final Future<void> Function() onClearCheckedShoppingItems;

  const MainNavigation({
    super.key,
    required this.watches,
    required this.favoriteStores,
    required this.darkMode,
    required this.monthlyGoal,
    required this.shoppingItems,
    required this.budgets,
    required this.onSaveWatch,
    required this.onDeleteWatch,
    required this.onToggleStore,
    required this.onToggleDarkMode,
    required this.onUpdateMonthlyGoal,
    required this.onSaveShoppingItem,
    required this.onSaveBudget,
    required this.onDeleteBudget,
    required this.onDeleteShoppingItem,
    required this.onClearCheckedShoppingItems,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(watches: widget.watches, favoriteStores: widget.favoriteStores),
      WatchlistScreen(watches: widget.watches, onSaveWatch: widget.onSaveWatch, onDeleteWatch: widget.onDeleteWatch),
      OffersScreen(
        favoriteStores: widget.favoriteStores,
        onAddShoppingItem: widget.onSaveShoppingItem,
      ),
      const FuelScreen(),
      ShoppingListScreen(items: widget.shoppingItems, onSaveItem: widget.onSaveShoppingItem, onDeleteItem: widget.onDeleteShoppingItem, onClearChecked: widget.onClearCheckedShoppingItems),
      BudgetScreen(budgets: widget.budgets, shoppingItems: widget.shoppingItems, watches: widget.watches, onSaveBudget: widget.onSaveBudget, onDeleteBudget: widget.onDeleteBudget),
      PriceHistoryScreen(watches: widget.watches),
      StatisticsScreen(watches: widget.watches, monthlyGoal: widget.monthlyGoal),
      ReceiptScannerScreen(onAddShoppingItem: widget.onSaveShoppingItem),
      ProfileScreen(
        watches: widget.watches,
        favoriteStores: widget.favoriteStores,
        darkMode: widget.darkMode,
        monthlyGoal: widget.monthlyGoal,
        onToggleStore: widget.onToggleStore,
        onToggleDarkMode: widget.onToggleDarkMode,
        onUpdateMonthlyGoal: widget.onUpdateMonthlyGoal,
      ),
    ];

    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => setState(() => selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Forside'),
          NavigationDestination(icon: Icon(Icons.notifications_none), selectedIcon: Icon(Icons.notifications_active), label: 'Prisvagter'),
          NavigationDestination(icon: Icon(Icons.local_offer_outlined), selectedIcon: Icon(Icons.local_offer), label: 'Tilbud'),
          NavigationDestination(icon: Icon(Icons.local_gas_station_outlined), selectedIcon: Icon(Icons.local_gas_station), label: 'Brændstof'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Indkøb'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Budget'),
          NavigationDestination(icon: Icon(Icons.show_chart_outlined), selectedIcon: Icon(Icons.show_chart), label: 'Historik'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Statistik'),
          NavigationDestination(icon: Icon(Icons.document_scanner_outlined), selectedIcon: Icon(Icons.document_scanner), label: 'Scanner'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
