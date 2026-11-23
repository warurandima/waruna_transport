class ServiceModel {
  final String id;
  final DateTime lastServiceDate;
  final DateTime nextServiceDate;
  final DateTime? lastTireChangeDate;

  ServiceModel({
    required this.id,
    required this.lastServiceDate,
    required this.nextServiceDate,
    this.lastTireChangeDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lastServiceDate': lastServiceDate.toIso8601String(),
      'nextServiceDate': nextServiceDate.toIso8601String(),
      'lastTireChangeDate': lastTireChangeDate?.toIso8601String(),
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic dateVal) {
      if (dateVal is String) {
        return DateTime.tryParse(dateVal) ?? DateTime.now();
      } else if (dateVal != null &&
          dateVal.runtimeType.toString().contains('Timestamp')) {
        return (dateVal as dynamic).toDate();
      }
      return DateTime.now();
    }

    DateTime? parseNullableDate(dynamic dateVal) {
      if (dateVal == null) return null;
      if (dateVal is String) {
        return DateTime.tryParse(dateVal);
      } else if (dateVal.runtimeType.toString().contains('Timestamp')) {
        return (dateVal as dynamic).toDate();
      }
      return null;
    }

    return ServiceModel(
      id: docId.isNotEmpty ? docId : (map['id'] ?? 'default'),
      lastServiceDate: parseDate(map['lastServiceDate']),
      nextServiceDate: parseDate(map['nextServiceDate']),
      lastTireChangeDate: parseNullableDate(map['lastTireChangeDate']),
    );
  }
}
