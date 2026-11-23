import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/expense_model.dart';
import '../models/debtor_model.dart';
import '../models/service_model.dart';
import '../models/reminder_model.dart';
import '../models/bank_account_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection('orders');

  CollectionReference<Map<String, dynamic>> get _expensesCollection =>
      _firestore.collection('expenses');

  CollectionReference<Map<String, dynamic>> get _debtorsCollection =>
      _firestore.collection('debtors');

  CollectionReference<Map<String, dynamic>> get _serviceCollection =>
      _firestore.collection('service_info');

  CollectionReference<Map<String, dynamic>> get _remindersCollection =>
      _firestore.collection('order_reminders');

  CollectionReference<Map<String, dynamic>> get _bankAccountsCollection =>
      _firestore.collection('bank_accounts');

  // --- ORDERS ---
  Future<void> addOrder(OrderModel order) async {
    final docRef = _ordersCollection.doc();
    final newOrder = OrderModel(
      id: docRef.id,
      date: order.date,
      materialType: order.materialType,
      amount: order.amount,
      isCredit: order.isCredit,
      isCompleted: order.isCompleted,
      debtorName: order.debtorName,
      debtorPhone: order.debtorPhone,
    );
    await docRef.set(newOrder.toMap());

    // If order is credit and debtor phone is provided, update or create debtor record
    if (order.isCredit &&
        order.debtorPhone != null &&
        order.debtorPhone!.trim().isNotEmpty) {
      final phone = order.debtorPhone!.trim();
      final debtorDoc = _debtorsCollection.doc(phone);
      final snapshot = await debtorDoc.get();

      final newTransaction = {
        'date': order.date.toIso8601String(),
        'amount': order.amount,
        'description':
            'ඇණවුම: ${order.materialType} (Order: ${order.materialType})',
      };

      if (snapshot.exists && snapshot.data() != null) {
        final existing = DebtorModel.fromMap(snapshot.data()!, phone);
        final updatedDue = existing.totalDue + order.amount;
        final updatedTransactions = List<Map<String, dynamic>>.from(
          existing.transactions,
        )..add(newTransaction);

        await debtorDoc.update({
          'name':
              (order.debtorName != null && order.debtorName!.trim().isNotEmpty)
              ? order.debtorName!.trim()
              : existing.name,
          'totalDue': updatedDue,
          'transactions': updatedTransactions,
        });
      } else {
        final debtor = DebtorModel(
          phone: phone,
          name:
              (order.debtorName != null && order.debtorName!.trim().isNotEmpty)
              ? order.debtorName!.trim()
              : 'ණයගැතියා ($phone)',
          totalDue: order.amount,
          transactions: [newTransaction],
        );
        await debtorDoc.set(debtor.toMap());
      }
    }
  }

  Stream<List<OrderModel>> getOrders() {
    return _ordersCollection.orderBy('date', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> markOrderCompleted(String orderId) async {
    await _ordersCollection.doc(orderId).update({'isCompleted': true});
  }

  Future<void> updateOrder(OrderModel newOrder, {OrderModel? oldOrder}) async {
    await _ordersCollection.doc(newOrder.id).update(newOrder.toMap());

    // Reconcile debtor balance if credit status, debtor, or amount changed
    if (oldOrder != null) {
      // 1. Revert old credit from previous debtor if it was credit
      if (oldOrder.isCredit &&
          oldOrder.debtorPhone != null &&
          oldOrder.debtorPhone!.trim().isNotEmpty) {
        final oldPhone = oldOrder.debtorPhone!.trim();
        final debtorDoc = _debtorsCollection.doc(oldPhone);
        final snapshot = await debtorDoc.get();
        if (snapshot.exists && snapshot.data() != null) {
          final existing = DebtorModel.fromMap(snapshot.data()!, oldPhone);
          final updatedDue = (existing.totalDue - oldOrder.amount).clamp(
            0.0,
            double.infinity,
          );
          await debtorDoc.update({'totalDue': updatedDue});
        }
      }
    }

    // 2. Apply new credit if new order is credit
    if (newOrder.isCredit &&
        newOrder.debtorPhone != null &&
        newOrder.debtorPhone!.trim().isNotEmpty) {
      final newPhone = newOrder.debtorPhone!.trim();
      final debtorDoc = _debtorsCollection.doc(newPhone);
      final snapshot = await debtorDoc.get();
      if (snapshot.exists && snapshot.data() != null) {
        final existing = DebtorModel.fromMap(snapshot.data()!, newPhone);
        final updatedDue = existing.totalDue + newOrder.amount;
        await debtorDoc.update({
          'name':
              (newOrder.debtorName != null &&
                  newOrder.debtorName!.trim().isNotEmpty)
              ? newOrder.debtorName!.trim()
              : existing.name,
          'totalDue': updatedDue,
        });
      } else {
        final debtor = DebtorModel(
          phone: newPhone,
          name:
              (newOrder.debtorName != null &&
                  newOrder.debtorName!.trim().isNotEmpty)
              ? newOrder.debtorName!.trim()
              : 'ණයගැතියා ($newPhone)',
          totalDue: newOrder.amount,
          transactions: [
            {
              'date': newOrder.date.toIso8601String(),
              'amount': newOrder.amount,
              'description':
                  'ඇණවුම: ${newOrder.materialType} (Order: ${newOrder.materialType})',
            },
          ],
        );
        await debtorDoc.set(debtor.toMap());
      }
    }
  }

  Future<void> deleteOrder(OrderModel order) async {
    await _ordersCollection.doc(order.id).delete();

    // If order was credit, reduce the debtor's balance
    if (order.isCredit &&
        order.debtorPhone != null &&
        order.debtorPhone!.trim().isNotEmpty) {
      final phone = order.debtorPhone!.trim();
      final debtorDoc = _debtorsCollection.doc(phone);
      final snapshot = await debtorDoc.get();
      if (snapshot.exists && snapshot.data() != null) {
        final existing = DebtorModel.fromMap(snapshot.data()!, phone);
        final updatedDue = (existing.totalDue - order.amount).clamp(
          0.0,
          double.infinity,
        );
        await debtorDoc.update({'totalDue': updatedDue});
      }
    }
  }

  // --- EXPENSES ---
  Future<void> addExpense(ExpenseModel expense) async {
    final docRef = _expensesCollection.doc();
    final newExpense = ExpenseModel(
      id: docRef.id,
      date: expense.date,
      type: expense.type,
      amount: expense.amount,
      customType: expense.customType,
      note: expense.note,
    );
    await docRef.set(newExpense.toMap());
  }

  Stream<List<ExpenseModel>> getExpenses() {
    return _expensesCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ExpenseModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await _expensesCollection.doc(expense.id).update(expense.toMap());
  }

  Future<void> deleteExpense(String id) async {
    await _expensesCollection.doc(id).delete();
  }

  // --- DEBTORS ---
  Stream<List<DebtorModel>> getDebtors() {
    return _debtorsCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => DebtorModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<DebtorModel?> getDebtor(String phone) {
    return _debtorsCollection.doc(phone).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return DebtorModel.fromMap(snapshot.data()!, snapshot.id);
    });
  }

  Future<void> payDebt(String phone, double amount) async {
    final docRef = _debtorsCollection.doc(phone);
    final snapshot = await docRef.get();
    if (!snapshot.exists || snapshot.data() == null) return;

    final existing = DebtorModel.fromMap(snapshot.data()!, phone);
    final updatedDue = (existing.totalDue - amount).clamp(0.0, double.infinity);

    final paymentTransaction = {
      'date': DateTime.now().toIso8601String(),
      'amount': -amount,
      'description': 'ණය පියවීම (Payment Received)',
    };

    final updatedTransactions = List<Map<String, dynamic>>.from(
      existing.transactions,
    )..add(paymentTransaction);

    await docRef.update({
      'totalDue': updatedDue,
      'transactions': updatedTransactions,
    });
  }

  Future<void> updateDebtor(DebtorModel debtor) async {
    await _debtorsCollection.doc(debtor.phone).update(debtor.toMap());
  }

  Future<void> deleteDebtor(String phone) async {
    await _debtorsCollection.doc(phone).delete();
  }

  // --- SERVICE INFO ---
  Stream<ServiceModel?> getServiceInfo() {
    return _serviceCollection.doc('default').snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return ServiceModel.fromMap(snapshot.data()!, snapshot.id);
    });
  }

  Future<void> updateServiceInfo(
    DateTime lastServiceDate,
    DateTime nextServiceDate, {
    DateTime? lastTireChangeDate,
  }) async {
    final model = ServiceModel(
      id: 'default',
      lastServiceDate: lastServiceDate,
      nextServiceDate: nextServiceDate,
      lastTireChangeDate: lastTireChangeDate,
    );
    await _serviceCollection.doc('default').set(model.toMap());
  }

  // --- ORDER REMINDERS ---
  Future<void> addReminder(ReminderModel reminder) async {
    final docRef = _remindersCollection.doc();
    final newReminder = ReminderModel(
      id: docRef.id,
      targetDate: reminder.targetDate,
      customerName: reminder.customerName,
      materialType: reminder.materialType,
      quantity: reminder.quantity,
      isCompleted: reminder.isCompleted,
    );
    await docRef.set(newReminder.toMap());
  }

  Stream<List<ReminderModel>> getReminders() {
    return _remindersCollection
        .orderBy('targetDate', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ReminderModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await _remindersCollection.doc(reminder.id).update(reminder.toMap());
  }

  Future<void> deleteReminder(String id) async {
    await _remindersCollection.doc(id).delete();
  }

  Future<void> toggleReminderCompletion(String id, bool status) async {
    await _remindersCollection.doc(id).update({'isCompleted': status});
  }

  // --- BANK ACCOUNTS ---
  Future<void> addBankAccount(BankAccountModel account) async {
    final docRef = _bankAccountsCollection.doc();
    final newAccount = BankAccountModel(
      id: docRef.id,
      accountName: account.accountName,
      accountNumber: account.accountNumber,
      bankName: account.bankName,
      branchName: account.branchName,
    );
    await docRef.set(newAccount.toMap());
  }

  Stream<List<BankAccountModel>> getBankAccounts() {
    return _bankAccountsCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => BankAccountModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> updateBankAccount(BankAccountModel account) async {
    await _bankAccountsCollection.doc(account.id).update(account.toMap());
  }

  Future<void> deleteBankAccount(String id) async {
    await _bankAccountsCollection.doc(id).delete();
  }
}
