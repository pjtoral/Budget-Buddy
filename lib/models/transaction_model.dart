class TransactionModel {
  final double amount;
  final String description;
  final String category;

  TransactionModel({
    required this.amount,
    required this.description,
    required this.category,
  });

  // Convert a TransactionModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'description': description,
      'category': category,
    };
  }

  // Optional: Create a TransactionModel from JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      amount: json['amount'].toDouble(), // Handles both int and double
      description: json['description'],
      category: json['category'],
    );
  }
}
