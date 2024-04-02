class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final DateTime createdAt;
  final String orderStatus;


  Order({required this.id, required this.userId, required this.items, required this.createdAt,required this.orderStatus});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      userId: json['userId'],
      items: List<OrderItem>.from(json['items'].map((item) => OrderItem.fromJson(item))),
      createdAt: DateTime.parse(json['createdAt']),
      orderStatus: json['orderStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'orderStatus': orderStatus,
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
