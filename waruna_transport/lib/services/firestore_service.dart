import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/expense_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Root collection: waruna_data -> doc: operational -> subcollections: orders, expenses
  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection('waruna_data').doc('business').collection('orders');

  CollectionReference<Map<String, dynamic>> get _expensesCollection =>
      _firestore.collection('waruna_data').doc('business').collection('expenses');

  Future<void> addOrder(OrderModel order) async {
    final docRef = _ordersCollection.doc();
    final newOrder = OrderModel(
      id: docRef.id,
      materialType: order.materialType,
      amount: order.amount,
      paymentStatus: order.paymentStatus,
      customerName: order.customerName,
      isCompleted: order.isCompleted,
      date: order.date,
    );
    await docRef.set(newOrder.toMap());
  }

  Stream<List<OrderModel>> getOrders() {
    return _ordersCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), id: doc.id))
          .toList();
    });
  }

  Future<void> addExpense(ExpenseModel expense) async {
    final docRef = _expensesCollection.doc();
    final newExpense = ExpenseModel(
      id: docRef.id,
      type: expense.type,
      amount: expense.amount,
      note: expense.note,
      date: expense.date,
    );
    await docRef.set(newExpense.toMap());
  }

  Stream<List<ExpenseModel>> getExpenses() {
    return _expensesCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ExpenseModel.fromMap(doc.data(), id: doc.id))
          .toList();
    });
  }
}
