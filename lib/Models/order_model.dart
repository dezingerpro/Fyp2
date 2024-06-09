class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final DateTime createdAt;
  final String orderStatus;
  final String orderTotal;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.createdAt,
    required this.orderStatus,
    this.orderTotal = '0.00', // Default value for orderTotal
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      userId: json['userId'],
      items: List<OrderItem>.from(json['items'].map((item) => OrderItem.fromJson(item))),
      createdAt: DateTime.parse(json['createdAt']),
      orderStatus: json['orderStatus'],
      orderTotal: json['orderTotal'] ?? '0.00', // Handle null value
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'orderStatus': orderStatus,
      'orderTotal': orderTotal,
    };
  }
}

class OrderItem {
  final String itemName;
  final int quantity;

  OrderItem({required this.itemName, required this.quantity});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemName: json['itemName'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'quantity': quantity,
    };
  }
}
