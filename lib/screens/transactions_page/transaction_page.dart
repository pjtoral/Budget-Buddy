import 'package:budgetbuddy_project/services/balance_service.dart';
import 'package:budgetbuddy_project/services/local_storage_service.dart';
import 'package:budgetbuddy_project/services/service_locator.dart';
import 'package:budgetbuddy_project/widgets/balance_card.dart';
import 'package:budgetbuddy_project/widgets/category_filter_chips.dart'; // ✅ Added
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
  static const double _transactionSpacing = 8.0;
  static const double _titleFontSize = 18;
  static const double _transactionTitleFontSize = 16;
  static const double _transactionSubtitleFontSize = 12;

  final TransactionServices _transactionServices =
      locator<TransactionServices>();
  final LocalStorageService _localStorageService =
      locator<LocalStorageService>();

  String _selectedCategory = 'All';
  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final userCategories = _localStorageService.getCategories();
    if (userCategories != null && userCategories.isNotEmpty) {
      setState(() {
        _categories = ['All', ...userCategories];
        if (!_categories.contains(_selectedCategory)) {
          _selectedCategory = 'All';
        }
      });
    } else {
      setState(() {
        _categories = ['All'];
        _selectedCategory = 'All';
      });
    }
  }

  Future<List<TransactionModel>> _getFilteredTransactions() async {
    if (_selectedCategory == 'All') {
      final allTransactions = <TransactionModel>[];
      final userCategories = _localStorageService.getCategories();

      if (userCategories != null && userCategories.isNotEmpty) {
        for (final category in userCategories) {
          final categoryTransactions = await _transactionServices
              .getTransactionByCategory(category);
          allTransactions.addAll(categoryTransactions);
        }
      }

      return allTransactions..sort((a, b) => b.date.compareTo(a.date));
    } else {
      final transactions = await _transactionServices.getTransactionByCategory(
        _selectedCategory,
      );
      return transactions..sort((a, b) => b.date.compareTo(a.date));
    }
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
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _horizontalPadding,
                  vertical: _verticalPadding,
                ),
                child: BalanceCard(),
              ),

              // ✅ Category Filter now uses reusable widget
              if (_categories.length > 1)
                CategoryFilterChips(
                  categories: _categories,
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (cat) {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                ),

              if (_categories.length == 1)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _horizontalPadding,
                    vertical: 8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Add categories when creating transactions to organize your expenses',
                            style: GoogleFonts.inter(
                              color: Colors.blue[700],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.receipt_long_outlined,
                                              size: 48,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              _categories.length == 1
                                                  ? 'No transactions yet.\nStart by adding or deducting money!'
                                                  : 'No transactions for this category.',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                color: Colors.grey[600],
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
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
