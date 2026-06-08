class TransactionModel {
  final String? id;
  final String transactionType; // 'in' atau 'out'
  final String category;
  final double amount;
  final String? note;
  final DateTime transactionDate;

  TransactionModel({
    this.id,
    required this.transactionType,
    required this.category,
    required this.amount,
    this.note,
    required this.transactionDate,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      transactionType: json['transaction_type'],
      category: json['category'],
      amount: (json['amount'] as num).toDouble(),
      note: json['note'],
      transactionDate: DateTime.parse(json['transaction_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_type': transactionType,
      'category': category,
      'amount': amount,
      'note': note ?? '',
      'transaction_date': transactionDate.toIso8601String().split('T')[0],
    };
  }
}
