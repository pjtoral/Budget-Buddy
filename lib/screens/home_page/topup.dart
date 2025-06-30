import 'package:budgetbuddy_project/common/app_strings.dart';
import 'package:budgetbuddy_project/models/transaction_model.dart';
import 'package:budgetbuddy_project/services/transaction_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key, required this.onConfirm});
  final Function onConfirm;
  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;

  String? _balanceAfter;

  void _updateBalance() {
    if (_amountController.text.isNotEmpty) {
      final amount = double.tryParse(_amountController.text);
      if (amount != null) {
        setState(() {
          _balanceAfter = 'Balance after: P${currentBalance + amount}';
        });
      } else {
        setState(() {
          _balanceAfter = null;
        });
      }
    } else {
      setState(() {
        _balanceAfter = null;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFF6F6F6), // Set background color
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Add',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 48), // To balance the IconButton's width
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Enter amount to top up:',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Enter Amount',
                labelStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
                filled: true,
                fillColor: Colors.white,
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
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _updateBalance(),
            ),
            const SizedBox(height: 8),
            if (_balanceAfter != null)
              Text(
                _balanceAfter!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            const SizedBox(height: 24),
            Text(
              'Description:',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Enter Description',
                labelStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
                filled: true,
                fillColor: Colors.white,
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
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Select Date:',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(thickness: 1),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(_amountController.text);
                    if (amount != null) {
                      currentBalance = currentBalance + amount;
                      final newTrans = TransactionModel(
                        amount: amount,
                        description: '',
                        transactionTime: DateTime.now(),
                      );
                      TransactionServices.inflow.add(newTrans);
                    }

                    widget.onConfirm();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 25,
                      ),
                    ],
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
