import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final DateTime date;
  final String type;
  final String imageUrl;
  final String description;
  File? localImageFile; // Added localImageFile property

  Transaction({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.date,
    required this.type,
    required this.imageUrl,
    required this.description,
    this.localImageFile, // Initialize localImageFile
  });

  // Convert Firebase DocumentSnapshot to Transaction
  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Transaction(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      type: data['type'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
    );
  }

  // Convert Transaction to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'amount': amount,
      'date': date,
      'type': type,
      'imageUrl': imageUrl,
      'description': description,
    };
  }
}
