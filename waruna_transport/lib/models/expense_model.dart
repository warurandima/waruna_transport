class ExpenseModel {
  final String id;
  final DateTime date;
  final String type;
  final double amount;
  final String? customType;
  final String? note;

  ExpenseModel({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    this.customType,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type,
      'amount': amount,
      'customType': customType,
      'note': note,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String docId) {
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

    return ExpenseModel(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      date: parsedDate,
      type: map['type'] ?? '',
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : 0.0,
      customType: map['customType'],
      note: map['note'],
    );
  }
}
