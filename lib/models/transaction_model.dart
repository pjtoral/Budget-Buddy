class TransactionModel {
  final double amount;
  final String description;
  final String category;
  final DateTime date;

  TransactionModel({
    required this.amount,
    required this.description,
    required this.category, 
    required this.date,
  });

  // Convert a TransactionModel to JSON
  Map<String, dynamic> toJson() => {
      'amount': amount,
      'description': description,
      'category': category, 
      'date': date.toIso8601String(),
  };


  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      amount: (json['amount'] as num).toDouble(), // Handles both int and double
      description: json['description'],
      category: json['category'] ?? '', 
      date: DateTime.parse(json['date']),
    );
  }
}
