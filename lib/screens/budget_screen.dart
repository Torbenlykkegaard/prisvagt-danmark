import 'package:flutter/material.dart';

import '../models/budget_item.dart';
import '../models/product.dart';
import '../models/shopping_item.dart';
import '../services/price_service.dart';

class BudgetScreen extends StatefulWidget {
  final List<BudgetItem> budgets;
  final List<ShoppingItem> shoppingItems;
  final List<PriceWatch> watches;
  final Future<void> Function(BudgetItem item) onSaveBudget;
  final Future<void> Function(String id) onDeleteBudget;

  const BudgetScreen({
    super.key,
    required this.budgets,
    required this.shoppingItems,
    required this.watches,
    required this.onSaveBudget,
    required this.onDeleteBudget,
  });

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  Widget build(BuildContext context) {
    final categories = widget.budgets.map((item) => item.category).toSet().toList()..sort();
    final totalBudget = widget.budgets.fold<double>(0, (sum, item) => sum + item.monthlyLimit);
    final estimatedSpend = categories.fold<double>(0, (sum, category) => sum + _estimatedSpend(category));
    final remaining = totalBudget - estimatedSpend;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: Text('Budget', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold))),
              FilledButton.icon(onPressed: () => _showBudgetSheet(context), icon: const Icon(Icons.add), label: const Text('Tilføj')),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _Metric(label: 'Månedsbudget', value: '${totalBudget.toStringAsFixed(0)} kr.'),
                  _Metric(label: 'Forventet forbrug', value: '${estimatedSpend.toStringAsFixed(0)} kr.'),
                  _Metric(label: 'Tilbage', value: '${remaining.toStringAsFixed(0)} kr.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (widget.budgets.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Opret et budget for dine vigtigste kategorier, fx dagligvarer, brændstof, el og streaming.')))
          else
            ...widget.budgets.map((budget) {
              final spend = _estimatedSpend(budget.category);
              final percent = budget.monthlyLimit <= 0 ? 0.0 : (spend / budget.monthlyLimit).clamp(0.0, 1.0);
              final diff = budget.monthlyLimit - spend;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(budget.category, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
                          IconButton(onPressed: () => _showBudgetSheet(context, item: budget), icon: const Icon(Icons.edit_outlined)),
                          IconButton(onPressed: () => widget.onDeleteBudget(budget.id), icon: const Icon(Icons.delete_outline)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: percent),
                      const SizedBox(height: 8),
                      Text('${spend.toStringAsFixed(0)} kr. brugt af ${budget.monthlyLimit.toStringAsFixed(0)} kr. · ${diff >= 0 ? 'Tilbage' : 'Over budget'} ${diff.abs().toStringAsFixed(0)} kr.'),
                      const SizedBox(height: 8),
                      Text(_tipFor(budget.category, diff), style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 16),
          Text('Budgetforslag', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Tip: Start med små grænser for de kategorier, hvor du handler mest. Appen bruger dine prisvagter, indkøbsliste og demo-tilbud til at give et estimat.'))),
        ],
      ),
    );
  }

  double _estimatedSpend(String category) {
    final shopping = widget.shoppingItems.where((item) => item.category == category).fold<double>(0, (sum, item) => sum + item.estimatedPrice);
    final watches = widget.watches.where((watch) => watch.category == category).fold<double>(0, (sum, watch) => sum + watch.targetPrice);
    final offers = PriceService.demoProducts.where((product) => product.category == category).take(3).fold<double>(0, (sum, product) => sum + product.currentPrice);
    return shopping + watches + offers;
  }

  String _tipFor(String category, double diff) {
    if (diff < 0) return 'Du er over budget i $category. Kig efter tilbud eller sænk nogle prisvagter.';
    if (diff < 100) return 'Du er tæt på budgettet i $category. Hold øje med de næste køb.';
    return 'Du ligger fint i $category. Brug prisvagter til at holde niveauet.';
  }

  void _showBudgetSheet(BuildContext context, {BudgetItem? item}) {
    final categoryController = TextEditingController(text: item?.category ?? 'Dagligvarer');
    final limitController = TextEditingController(text: (item?.monthlyLimit ?? 1200).toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item == null ? 'Tilføj budget' : 'Rediger budget', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: limitController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Månedsgrænse i kr.', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final limit = double.tryParse(limitController.text.replaceAll(',', '.')) ?? 0;
                  final budget = BudgetItem(
                    id: item?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                    category: categoryController.text.trim().isEmpty ? 'Dagligvarer' : categoryController.text.trim(),
                    monthlyLimit: limit,
                  );
                  widget.onSaveBudget(budget);
                  Navigator.pop(context);
                },
                child: const Text('Gem budget'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Theme.of(context).colorScheme.surfaceContainerHighest),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
