class OrderModel {
  final String id;
  final String materialType; // e.g., Sand, Metal, Cement, Soil
  final double amount;
  final String paymentStatus; // "Cash" or "Credit"
  final String customerName;
  final bool isCompleted;
  final DateTime date;

  OrderModel({
    required this.id,
    required this.materialType,
    required this.amount,
    required this.paymentStatus,
    required this.customerName,
    required this.isCompleted,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'materialType': materialType,
      'amount': amount,
      'paymentStatus': paymentStatus,
      'customerName': customerName,
      'isCompleted': isCompleted,
      'date': date.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parsedDate;
    final dateVal = map['date'];
    if (dateVal is String) {
      parsedDate = DateTime.tryParse(dateVal) ?? DateTime.now();
    } else if (dateVal != null && dateVal.runtimeType.toString().contains('Timestamp')) {
      parsedDate = (dateVal as dynamic).toDate();
    } else {
      parsedDate = DateTime.now();
    }

    return OrderModel(
      id: id ?? map['id'] ?? '',
      materialType: map['materialType'] ?? '',
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : 0.0,
      paymentStatus: map['paymentStatus'] ?? 'Cash',
      customerName: map['customerName'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      date: parsedDate,
    );
  }
}
