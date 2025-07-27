import 'package:budgetbuddy_project/services/balance_service.dart';
import 'package:budgetbuddy_project/services/local_storage_service.dart';
import 'package:budgetbuddy_project/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/transaction_services.dart';
import '../../models/transaction_model.dart';
import '../../common/string_helpers.dart';

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

  final TransactionServices _transactionServices =
      locator<TransactionServices>();
  final BalanceService _balanceService = locator<BalanceService>();
  final LocalStorageService _localStorageService =
      locator<LocalStorageService>();

  double _currentBalance = 0;
  String _selectedCategory = 'School';
  List<String> _categories = [
    'School',
    'Motorcycle',
    'Computer',
  ]; // Changed to non-final

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _currentBalance = await _balanceService.getBalance();
    await _loadCategories();
    setState(() {});
  }

  Future<void> _loadCategories() async {
    final categories = _localStorageService.getCategories();
    if (categories != null && categories.isNotEmpty) {
      _categories = categories;
      // If current selected category doesn't exist in new list, select first one
      if (!_categories.contains(_selectedCategory)) {
        _selectedCategory = _categories.first;
      }
    }
  }

  Future<List<TransactionModel>> _getFilteredTransactions() async {
    final allTransactions = await _transactionServices.getTransactionByCategory(
      _selectedCategory,
    );
    return allTransactions..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF6F6F6),
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
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1.0,
                    ),
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
                        formatMoney(_currentBalance),
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
                    child: FutureBuilder<List<TransactionModel>>(
                      future: _getFilteredTransactions(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final transactions = snapshot.data ?? [];

                        return ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children:
                              transactions.isEmpty
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
                                  : transactions
                                      .map((tx) => _buildTransactionItem(tx))
                                      .toList(),
                        );
                      },
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

  Widget _buildTransactionItem(TransactionModel transaction) {
    final isInflow = transaction.amount > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _transactionSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.category,
                style: GoogleFonts.inter(
                  fontSize: _transactionTitleFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              if (transaction.description.isNotEmpty)
                Text(
                  transaction.description,
                  style: GoogleFonts.inter(
                    fontSize: _transactionSubtitleFontSize,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          Text(
            '${isInflow ? '+' : ''}${formatMoney(transaction.amount)}',
            style: GoogleFonts.inter(
              fontSize: _transactionTitleFontSize,
              fontWeight: FontWeight.w500,
              color: isInflow ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
