class ExpenseModel {
  final String id;
  final String type; // "Fuel" or "Other"
  final double amount;
  final String note;
  final DateTime date;

  ExpenseModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.note,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'note': note,
      'date': date.toIso8601String(),
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parsedDate;
    final dateVal = map['date'];
    if (dateVal is String) {
      parsedDate = DateTime.tryParse(dateVal) ?? DateTime.now();
    } else if (dateVal != null && dateVal.runtimeType.toString().contains('Timestamp')) {
      parsedDate = (dateVal as dynamic).toDate();
    } else {
      parsedDate = DateTime.now();
    }

    return ExpenseModel(
      id: id ?? map['id'] ?? '',
      type: map['type'] ?? 'Other',
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : 0.0,
      note: map['note'] ?? '',
      date: parsedDate,
    );
  }
}
