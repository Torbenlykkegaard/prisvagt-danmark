class BudgetItem {
  final String id;
  final String category;
  final double monthlyLimit;

  const BudgetItem({required this.id, required this.category, required this.monthlyLimit});

  Map<String, dynamic> toJson() => {'id': id, 'category': category, 'monthlyLimit': monthlyLimit};

  factory BudgetItem.fromJson(Map<String, dynamic> json) {
    return BudgetItem(
      id: json['id'] as String,
      category: json['category'] as String,
      monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
    );
  }

  BudgetItem copyWith({String? category, double? monthlyLimit}) {
    return BudgetItem(id: id, category: category ?? this.category, monthlyLimit: monthlyLimit ?? this.monthlyLimit);
  }
}
