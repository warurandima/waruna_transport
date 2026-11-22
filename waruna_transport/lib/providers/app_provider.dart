import 'dart:async';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';

class AppProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  List<OrderModel> _orders = [];
  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;

  StreamSubscription<List<OrderModel>>? _ordersSubscription;
  StreamSubscription<List<ExpenseModel>>? _expensesSubscription;

  AppProvider({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService() {
    _initStreams();
  }

  List<OrderModel> get orders => _orders;
  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;

  void _initStreams() {
    _ordersSubscription = _firestoreService.getOrders().listen((data) {
      _orders = data;
      notifyListeners();
    }, onError: (error) {
      debugPrint('Error listening to orders: $error');
    });

    _expensesSubscription = _firestoreService.getExpenses().listen((data) {
      _expenses = data;
      notifyListeners();
    }, onError: (error) {
      debugPrint('Error listening to expenses: $error');
    });
  }

  Future<void> addOrder(OrderModel order) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.addOrder(order);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(ExpenseModel expense) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.addExpense(expense);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    _expensesSubscription?.cancel();
    super.dispose();
  }
}
