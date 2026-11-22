import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AppProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  AppProvider({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  FirestoreService get firestoreService => _firestoreService;
}
