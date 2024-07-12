import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart' as MyTransaction;

class TransactionService {
  final CollectionReference _transactionCollection = FirebaseFirestore.instance.collection('transactions');

  Future<String> uploadImage(File image) async {
    final String fileName = Uuid().v1();
    final Reference storageRef = FirebaseStorage.instance.ref().child('transaction_images/$fileName');
    final UploadTask uploadTask = storageRef.putFile(image);
    final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Stream<List<MyTransaction.Transaction>> getTransactions(String userId) {
    return _transactionCollection
      .where('userId', isEqualTo: userId) // Filter transaksi berdasarkan userId
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => MyTransaction.Transaction.fromFirestore(doc)).toList());
  }

  Future<void> addTransaction(MyTransaction.Transaction transaction) async {
    try {
      await _transactionCollection.add(transaction.toFirestore());
    } catch (e) {
      print('Error adding transaction: $e');
    }
  }

  Future<void> updateTransaction(MyTransaction.Transaction transaction) async {
    try {
      await _transactionCollection.doc(transaction.id).update(transaction.toFirestore());
    } catch (e) {
      print('Error updating transaction: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _transactionCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting transaction: $e');
    }
  }
}
