import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

class TransactionServices {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) throw Exception('Not authenticated');
    return u.uid;
  }

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _db.collection('users').doc(_uid);
  CollectionReference<Map<String, dynamic>> get _txCol =>
      _userDoc.collection('transactions');

  // Create transaction and apply balance in a single transaction
  Future<void> addTransaction(TransactionModel tx, {String? categoryId}) async {
    final signedAmount = tx.amount; // positive for income, negative for expense
    final txRef = _txCol.doc();

    await _db.runTransaction((txn) async {
      final userSnap = await txn.get(_userDoc);
      if (!userSnap.exists) {
        throw Exception('User not found');
      }
      final currentBalance = (userSnap.data()?['balance'] ?? 0).toDouble();

      txn.set(txRef, {
        'amount': tx.amount.abs(),
        'type': tx.amount >= 0 ? 'income' : 'expense',
        'categoryId':
            categoryId ?? tx.category, // keep category name as id for now
        'categoryName': tx.category,
        'description': tx.description,
        'txDate': Timestamp.fromDate(tx.date),
        'createdAt': FieldValue.serverTimestamp(),
      });

      txn.update(_userDoc, {
        'balance': currentBalance + signedAmount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final qs = await _txCol.orderBy('txDate', descending: true).get();
    return qs.docs.map(_toModel).toList();
  }

  Future<List<TransactionModel>> getInflow() async {
    final qs = await _txCol.where('type', isEqualTo: 'income').get();
    return qs.docs.map(_toModel).toList();
  }

  Future<List<TransactionModel>> getOutflow() async {
    final qs = await _txCol.where('type', isEqualTo: 'expense').get();
    return qs.docs.map(_toModel).toList();
  }

  Future<List<TransactionModel>> getTransactionByCategory(
    String categoryName,
  ) async {
    final qs =
        await _txCol
            .where('categoryName', isEqualTo: categoryName)
            .orderBy('txDate', descending: true)
            .get();
    return qs.docs.map(_toModel).toList();
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final qs =
        await _txCol
            .where(
              'txDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
            )
            .where('txDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
            .orderBy('txDate', descending: true)
            .get();
    return qs.docs.map(_toModel).toList();
  }

  // Optional: update/delete helpers with balance delta if you add id into TransactionModel
  // For now, your model lacks an id, so we leave them out or you can add an id field.

  TransactionModel _toModel(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data();
    final amount = (data['amount'] ?? 0).toDouble();
    final isIncome = (data['type'] ?? 'expense') == 'income';
    return TransactionModel(
      amount: isIncome ? amount : -amount,
      description: (data['description'] ?? '') as String,
      category: (data['categoryName'] ?? '') as String,
      date: (data['txDate'] as Timestamp).toDate(),
    );
  }
}
