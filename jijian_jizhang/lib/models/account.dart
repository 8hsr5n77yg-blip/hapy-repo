class Account {
  final int? id;
  final String name;
  final String type; // cash, bank, virtual
  final double balance;
  final double initialBalance;
  final String icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Account({
    this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.initialBalance,
    this.icon = 'wallet',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int,
      name: map['name'] as String,
      type: map['type'] as String,
      balance: (map['balance'] as num).toDouble(),
      initialBalance: (map['initial_balance'] as num).toDouble(),
      icon: map['icon'] as String? ?? 'wallet',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': type,
      'balance': balance,
      'initial_balance': initialBalance,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Account copyWith({
    int? id,
    String? name,
    String? type,
    double? balance,
    double? initialBalance,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      initialBalance: initialBalance ?? this.initialBalance,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
