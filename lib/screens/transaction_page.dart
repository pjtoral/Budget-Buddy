import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/transaction_services.dart';
import '../models/transaction_model.dart';
import '../common/app_strings.dart';
import '../common/string_helpers.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  static const double _horizontalPadding = 16.0;
  static const double _verticalPadding = 16.0;
  static const double _containerPadding = 16.0;
  static const double _chipSpacing = 8.0;
  static const double _transactionSpacing = 8.0;
  static const double _balanceFontSize = 28;
  static const double _titleFontSize = 18;
  static const double _categoryFontSize = 14;
  static const double _transactionTitleFontSize = 16;
  static const double _transactionSubtitleFontSize = 12;

  final List<String> _categories = [
    'School',
    'Motorcycle',
    'Computer',
    'Shabu',
  ];
  String _selectedCategory = 'School';

  List<TransactionModel> get _filteredTransactions {
    final allTransactions = [
      ...TransactionServices.inflow,
      ...TransactionServices.outflow,
    ];
    return allTransactions
        .where((tx) => tx.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        appBar: AppBar(
          backgroundColor: Color(0xFFF6F6F6),
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Transaction History',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: _titleFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            Padding(padding: const EdgeInsets.only(right: _horizontalPadding)),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Current Balance Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _horizontalPadding,
                  vertical: _verticalPadding,
                ),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  padding: const EdgeInsets.all(_containerPadding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Color(0xFFE0E0E0), width: 1.0),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Balance',
                        style: GoogleFonts.inter(
                          color: Colors.grey[600],
                          fontSize: _categoryFontSize,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatMoney(currentBalance),
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: _balanceFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Category Filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: _horizontalPadding,
                ),
                child: Row(
                  children:
                      _categories
                          .map(
                            (cat) => _buildCategoryChip(
                              cat,
                              _selectedCategory == cat,
                            ),
                          )
                          .toList(),
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.all(_verticalPadding),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'History',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              ),

              // Transaction List
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _horizontalPadding,
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children:
                          _filteredTransactions.isEmpty
                              ? [
                                Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Center(
                                    child: Text(
                                      'No transactions for this category.',
                                      style: GoogleFonts.inter(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ]
                              : _filteredTransactions
                                  .map(
                                    (tx) => _buildTransactionItem(
                                      tx.category,
                                      tx.description,
                                      '${TransactionServices.inflow.contains(tx) ? '+' : '-'}${formatMoney(tx.amount)}',
                                      TransactionServices.inflow.contains(tx),
                                    ),
                                  )
                                  .toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: _chipSpacing),
      child: ChoiceChip(
        label: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: _categoryFontSize,
          ),
        ),
        selected: isSelected,
        selectedColor: Colors.black,
        backgroundColor: Colors.grey[300],
        onSelected: (_) {
          setState(() {
            _selectedCategory = label;
          });
        },
      ),
    );
  }

  Widget _buildTransactionItem(
    String category,
    String description,
    String amount,
    bool isPositive,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _transactionSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: GoogleFonts.inter(
                  fontSize: _transactionTitleFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              if (description.isNotEmpty)
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: _transactionSubtitleFontSize,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: _transactionTitleFontSize,
              fontWeight: FontWeight.w500,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
