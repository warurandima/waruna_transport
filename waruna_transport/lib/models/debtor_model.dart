class DebtorModel {
  final String phone;
  final String name;
  final double totalDue;
  final List<Map<String, dynamic>> transactions;

  DebtorModel({
    required this.phone,
    required this.name,
    required this.totalDue,
    required this.transactions,
  });

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'name': name,
      'totalDue': totalDue,
      'transactions': transactions,
    };
  }

  factory DebtorModel.fromMap(Map<String, dynamic> map, String docId) {
    final rawTransactions = map['transactions'];
    List<Map<String, dynamic>> parsedTransactions = [];
    if (rawTransactions is List) {
      parsedTransactions = rawTransactions.map((item) {
        if (item is Map) {
          return Map<String, dynamic>.from(item);
        }
        return <String, dynamic>{};
      }).toList();
    }

    return DebtorModel(
      phone: docId.isNotEmpty ? docId : (map['phone'] ?? ''),
      name: map['name'] ?? '',
      totalDue: (map['totalDue'] is num)
          ? (map['totalDue'] as num).toDouble()
          : 0.0,
      transactions: parsedTransactions,
    );
  }
}
