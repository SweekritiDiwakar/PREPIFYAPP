class GroceryItem {
  final String itemId;
  final String name;
  final int quantity;
  final String status; // 'pending' or 'completed'
  final String addedBy;

  GroceryItem({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.status,
    required this.addedBy,
  });

  factory GroceryItem.fromFirestore(String id, Map<String, dynamic> data) {
    return GroceryItem(
      itemId: id,
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 1,
      status: data['status'] ?? 'pending',
      addedBy: data['addedBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'quantity': quantity,
      'status': status,
      'addedBy': addedBy,
    };
  }
}

class GroceryList {
  final String listId;
  final String name;
  final String createdBy;
  final List<String> members;

  GroceryList({
    required this.listId,
    required this.name,
    required this.createdBy,
    required this.members,
  });

  factory GroceryList.fromFirestore(String id, Map<String, dynamic> data) {
    return GroceryList(
      listId: id,
      name: data['name'] ?? '',
      createdBy: data['createdBy'] ?? '',
      members: List<String>.from(data['members'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'createdBy': createdBy, 'members': members};
  }
}
