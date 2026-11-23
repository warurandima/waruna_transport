class BankAccountModel {
  final String id;
  final String accountName;
  final String accountNumber;
  final String bankName;
  final String branchName;

  const BankAccountModel({
    required this.id,
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
    required this.branchName,
  });

  Map<String, dynamic> toMap() {
    return {
      'accountName': accountName,
      'accountNumber': accountNumber,
      'bankName': bankName,
      'branchName': branchName,
    };
  }

  factory BankAccountModel.fromMap(Map<String, dynamic> map, String docId) {
    return BankAccountModel(
      id: docId,
      accountName: map['accountName'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      bankName: map['bankName'] ?? '',
      branchName: map['branchName'] ?? '',
    );
  }
}
