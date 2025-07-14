import 'package:budgetbuddy_project/models/transaction_model.dart';

class TransactionServices {
  static List<TransactionModel> inflow = [
    TransactionModel(
      amount: 102.00,
      description: 'Money Laundering',
      category: 'Shabu',
    ),
    TransactionModel(
      amount: 5000.00,
      description: 'Allowance',
      category: 'School',
    ),
    TransactionModel(
      amount: 1200.00,
      description: 'Freelance',
      category: 'Computer',
    ),
  ];
  static List<TransactionModel> outflow = [
    TransactionModel(
      amount: 359.00,
      description: 'School Supplies',
      category: 'School',
    ),
    TransactionModel(
      amount: 200.00,
      description: 'Gasoline',
      category: 'Motorcycle',
    ),
    TransactionModel(
      amount: 150.00,
      description: 'PC Upgrade',
      category: 'Computer',
    ),
  ];
}
