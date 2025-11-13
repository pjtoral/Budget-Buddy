import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BalanceService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) throw Exception('Not authenticated');
    return u.uid;
  }

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _db.collection('users').doc(_uid);

  Future<double> getBalance() async {
    final snap = await _userDoc.get();
    if (!snap.exists) return 0.0;
    return (snap.data()?['balance'] ?? 0).toDouble();
  }

  // If you still call these from UI, keep them but have them apply deltas.
  Future<void> updateBalance(double amount) => _applyDelta(amount);
  Future<void> deductBalance(double amount) => _applyDelta(-amount);

  Future<void> _applyDelta(double delta) async {
    await _db.runTransaction((txn) async {
      final userSnap = await txn.get(_userDoc);
      final current = (userSnap.data()?['balance'] ?? 0).toDouble();
      txn.update(_userDoc, {
        'balance': current + delta,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
