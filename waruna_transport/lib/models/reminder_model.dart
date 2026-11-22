class ReminderModel {
  final String id;
  final DateTime targetDate;
  final String customerName;
  final String materialType;
  final String quantity;
  final bool isCompleted;

  ReminderModel({
    required this.id,
    required this.targetDate,
    required this.customerName,
    required this.materialType,
    required this.quantity,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'targetDate': targetDate.toIso8601String(),
      'customerName': customerName,
      'materialType': materialType,
      'quantity': quantity,
      'isCompleted': isCompleted,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedDate;
    final dateVal = map['targetDate'];
    if (dateVal is String) {
      parsedDate = DateTime.tryParse(dateVal) ?? DateTime.now();
    } else if (dateVal != null &&
        dateVal.runtimeType.toString().contains('Timestamp')) {
      parsedDate = (dateVal as dynamic).toDate();
    } else {
      parsedDate = DateTime.now();
    }

    return ReminderModel(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      targetDate: parsedDate,
      customerName: map['customerName'] ?? '',
      materialType: map['materialType'] ?? '',
      quantity: map['quantity'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
