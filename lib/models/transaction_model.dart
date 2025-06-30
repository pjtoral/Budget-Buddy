class TransactionModel {
  final double amount;
  final String description;
  final DateTime transactionTime;

  TransactionModel({
    required this.amount,
    required this.description,
    required this.transactionTime,
  });
}
