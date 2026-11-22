class OrderModel {
  final String id;
  final DateTime date;
  final String materialType;
  final double amount;
  final bool isCredit;
  final bool isCompleted;
  final String? debtorName;
  final String? debtorPhone;

  OrderModel({
    required this.id,
    required this.date,
    required this.materialType,
    required this.amount,
    required this.isCredit,
    required this.isCompleted,
    this.debtorName,
    this.debtorPhone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'materialType': materialType,
      'amount': amount,
      'isCredit': isCredit,
      'isCompleted': isCompleted,
      'debtorName': debtorName,
      'debtorPhone': debtorPhone,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedDate;
    final dateVal = map['date'];
    if (dateVal is String) {
      parsedDate = DateTime.tryParse(dateVal) ?? DateTime.now();
    } else if (dateVal != null &&
        dateVal.runtimeType.toString().contains('Timestamp')) {
      parsedDate = (dateVal as dynamic).toDate();
    } else {
      parsedDate = DateTime.now();
    }

    return OrderModel(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      date: parsedDate,
      materialType: map['materialType'] ?? '',
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : 0.0,
      isCredit: map['isCredit'] ?? false,
      isCompleted: map['isCompleted'] ?? false,
      debtorName: map['debtorName'],
      debtorPhone: map['debtorPhone'],
    );
  }
}
