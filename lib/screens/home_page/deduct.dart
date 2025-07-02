import 'package:budgetbuddy_project/common/app_strings.dart';
import 'package:budgetbuddy_project/models/transaction_model.dart';
import 'package:budgetbuddy_project/services/transaction_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeductPage extends StatefulWidget {
  const DeductPage({super.key, this.onConfirm});
  final Function? onConfirm;

  @override
  State<DeductPage> createState() => _DeductPageState();
}

class _DeductPageState extends State<DeductPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  bool _showCategories = false;
  final List<String> _categories = ['School', 'Motorcycle', 'Shabu'];

  String? _balanceAfter;

  void _updateBalance() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    setState(() {
      _balanceAfter =
          'Balance after: ₱${(currentBalance - amount).toStringAsFixed(2)}';
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar Row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 16,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Deduct',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // To balance the IconButton
                ],
              ),
            ),
            // Main Card
            Expanded(
              child: Center(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Amount Input
                        Text(
                          'Enter Amount',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _amountController,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            prefixText: '₱ ',
                            prefixStyle: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                            hintText: '0.00',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[400],
                            ),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: EdgeInsets.zero,
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (value) => _updateBalance(),
                        ),
                        const SizedBox(height: 8),
                        // Balance After
                        if (_amountController.text.isNotEmpty)
                          Text(
                            _balanceAfter ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.red[700],
                            ),
                          ),
                        const SizedBox(height: 32),
                        // Category Dropdown
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Select a category',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _showCategories = !_showCategories;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedCategory ?? 'Categories',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color:
                                      _selectedCategory != null
                                          ? Colors.black
                                          : Colors.grey,
                                ),
                              ),
                              Icon(
                                _showCategories
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                              ),
                            ],
                          ),
                        ),
                        if (_showCategories)
                          Column(
                            children: [
                              ..._categories.map((category) {
                                return ListTile(
                                  title: Text(category),
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = category;
                                      _showCategories = false;
                                    });
                                  },
                                );
                              }).toList(),
                              ListTile(
                                title: Row(
                                  children: [
                                    const Icon(Icons.add, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Add Category',
                                      style: GoogleFonts.inter(),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // Add category functionality
                                },
                              ),
                            ],
                          ),
                        const SizedBox(height: 32),
                        // Description Input (Always visible, big)
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description (optional)',
                            labelStyle: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                            alignLabelWithHint: true,
                            filled: true,
                            fillColor: const Color(0xFFF6F6F6),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 16,
                            ),
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 5,
                          minLines: 3,
                        ),
                        const SizedBox(height: 32),
                        // Confirm Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final amount = double.tryParse(
                                _amountController.text,
                              );
                              if (amount == null || amount <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Enter a valid amount'),
                                  ),
                                );
                                return;
                              }
                              if (_selectedCategory == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select a category'),
                                  ),
                                );
                                return;
                              }
                              if (amount > currentBalance) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Insufficient balance'),
                                  ),
                                );
                                return;
                              }
                              setState(() {
                                currentBalance = currentBalance - amount;
                              });
                              final newTrans = TransactionModel(
                                amount: amount,
                                description:
                                    '${_selectedCategory!}: ${_descriptionController.text}',
                              );
                              TransactionServices.outflow.add(newTrans);

                              if (widget.onConfirm != null) widget.onConfirm!();
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Confirm',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
