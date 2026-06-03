class Category {
  final int id;
  final String name;
  final String type; // 'expense' or 'income'
  final String icon;
  final int sortOrder;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.sortOrder,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      type: map['type'] as String,
      icon: map['icon'] as String,
      sortOrder: map['sort_order'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'sort_order': sortOrder,
    };
  }
}
