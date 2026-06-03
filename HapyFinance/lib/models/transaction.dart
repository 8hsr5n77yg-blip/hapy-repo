class Transaction {
  final int? id;
  final String type; // 'expense' or 'income'
  final double amount;
  final int categoryId;
  final String categoryName;
  final String categoryIcon;
  final int accountId;
  final String accountName;
  final String date; // '2026-06-03'
  final String time; // '14:30'
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    this.categoryName = '',
    this.categoryIcon = '',
    required this.accountId,
    this.accountName = '',
    required this.date,
    required this.time,
    this.note = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['category_id'] as int,
      categoryName: map['category_name'] as String? ?? '',
      categoryIcon: map['category_icon'] as String? ?? '',
      accountId: map['account_id'] as int,
      accountName: map['account_name'] as String? ?? '',
      date: map['date'] as String,
      time: map['time'] as String,
      note: map['note'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'amount': amount,
      'category_id': categoryId,
      'account_id': accountId,
      'date': date,
      'time': time,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Transaction copyWith({
    int? id,
    String? type,
    double? amount,
    int? categoryId,
    String? categoryName,
    String? categoryIcon,
    int? accountId,
    String? accountName,
    String? date,
    String? time,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      date: date ?? this.date,
      time: time ?? this.time,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
