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

    // Search
    final TextEditingController _searchController = TextEditingController();
    String _searchQuery = '';

    // Date Range Filter
    String _selectedTimeFrame = 'All'; // 'All', 'Day', 'Week', 'Month', '3 Months'
    final List<String> _timeFrames = ['All', 'Day', 'Week', 'Month', '3 Months'];

    // Day-of-Week Filter
    final List<String> _daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    List<bool> _selectedDays = [false, false, false, false, false, false, false]; // All unselected by default

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Get date range based on selected timeframe
  DateTimeRange _getDateRange() {
    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    DateTime startDate;

    switch (_selectedTimeFrame) {
      case 'Day':
        startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
        break;
      case 'Week':
        final daysToSubtract = now.weekday - 1; // Monday = 1
        startDate = now.subtract(Duration(days: daysToSubtract));
        startDate = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month, 1, 0, 0, 0);
        break;
      case '3 Months':
        startDate = DateTime(now.year, now.month - 3, 1, 0, 0, 0);
        break;
      default: // 'All'
        startDate = DateTime(1900, 1, 1); // Far past for 'All' data
        break;
    }

    return DateTimeRange(start: startDate, end: endDate);
  }

  // Check if a transaction date matches selected days of week
  bool _matchesDayOfWeek(DateTime txDate) {
    // If no days are selected, show all days
    if (!_selectedDays.any((selected) => selected)) {
      return true;
    }
    // weekday: 1 = Monday, 7 = Sunday
    final dayIndex = txDate.weekday - 1;
    return dayIndex >= 0 && dayIndex < _selectedDays.length && _selectedDays[dayIndex];
  }

  // Helper: toggle day selection
  void _toggleDay(int dayIndex) {
    setState(() {
      _selectedDays[dayIndex] = !_selectedDays[dayIndex];
    });
  }

  // Helper: clear all day selections
  void _clearDaySelections() {
    setState(() {
      _selectedDays = [false, false, false, false, false, false, false];
    });
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

      // Apply date range filtering
      final dateRange = _getDateRange();
      var results = allTransactions
          .where((tx) => tx.date.isAfter(dateRange.start) && tx.date.isBefore(dateRange.end))
          .toList();

      // Apply day-of-week filtering
      results = results.where((tx) => _matchesDayOfWeek(tx.date)).toList();

      // Apply search filtering if present
      final q = _searchQuery.trim().toLowerCase();
      if (q.isNotEmpty) {
        results = results.where((tx) {
          final desc = tx.description.toLowerCase();
          final cat = tx.category.toLowerCase();
          if (desc.contains(q) || cat.contains(q)) return true;
          if ((q.contains('top') || q.contains('income') || q.contains('inflow')) && tx.amount > 0) return true;
          if ((q.contains('expense') || q.contains('spend') || q.contains('outflow')) && tx.amount < 0) return true;
          final numeric = double.tryParse(q.replaceAll(RegExp('[^0-9.]'), ''));
          if (numeric != null) {
            if (tx.amount.abs() == numeric) return true;
          }
          return false;
        }).toList();
      }

      return results..sort((a, b) => b.date.compareTo(a.date));
    } else {
      final transactions = await _transactionServices.getTransactionByCategory(
        _selectedCategory,
      );

      // Apply date range filtering
      final dateRange = _getDateRange();
      var results = transactions
          .where((tx) => tx.date.isAfter(dateRange.start) && tx.date.isBefore(dateRange.end))
          .toList();

      // Apply day-of-week filtering
      results = results.where((tx) => _matchesDayOfWeek(tx.date)).toList();

      // Apply search filtering
      final q = _searchQuery.trim().toLowerCase();
      if (q.isNotEmpty) {
        results = results.where((tx) {
          final desc = tx.description.toLowerCase();
          final cat = tx.category.toLowerCase();
          if (desc.contains(q) || cat.contains(q)) return true;
          if ((q.contains('top') || q.contains('income') || q.contains('inflow')) && tx.amount > 0) return true;
          if ((q.contains('expense') || q.contains('spend') || q.contains('outflow')) && tx.amount < 0) return true;
          final numeric = double.tryParse(q.replaceAll(RegExp('[^0-9.]'), ''));
          if (numeric != null) {
            if (tx.amount.abs() == numeric) return true;
          }
          return false;
        }).toList();
      }

      return results..sort((a, b) => b.date.compareTo(a.date));
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

              // Time Frame Filter
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _horizontalPadding,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time Period: ',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _timeFrames.map((timeFrame) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(timeFrame),
                              selected: _selectedTimeFrame == timeFrame,
                              selectedColor: Colors.black,
                              backgroundColor: Colors.grey[200],
                              labelStyle: GoogleFonts.inter(
                                color: _selectedTimeFrame == timeFrame
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              onSelected: (_) {
                                setState(() {
                                  _selectedTimeFrame = timeFrame;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Day-of-Week Filter
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _horizontalPadding,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Days: ',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_selectedDays.any((selected) => selected))
                          TextButton(
                            onPressed: _clearDaySelections,
                            child: Text(
                              'Clear',
                              style: GoogleFonts.inter(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          _daysOfWeek.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(_daysOfWeek[index]),
                              selected: _selectedDays[index],
                              backgroundColor: Colors.grey[200],
                              selectedColor: Colors.black,
                              labelStyle: GoogleFonts.inter(
                                color: _selectedDays[index]
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              onSelected: (_) {
                                _toggleDay(index);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.all(_verticalPadding),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) {
                    setState(() {
                      _searchQuery = v;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search transactions (description, category, "top up", "expense")',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
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
