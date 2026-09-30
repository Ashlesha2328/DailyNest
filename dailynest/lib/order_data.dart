import 'package:flutter/foundation.dart';

class OrderItem {
  final String productName;
  final int quantity;
  final int price;

  OrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
  });

  int get total => price * quantity;
}

class Order {
  final List<OrderItem> items;
  final int totalAmount;
  final DateTime date;

  Order({
    required this.items,
    required this.totalAmount,
    required this.date,
  });
}

class OrderData {
  static final List<Order> orders = [];

  static final ValueNotifier<int> orderVersion =
      ValueNotifier<int>(0);

  static void addOrder({
    required List<dynamic> cartItems,
    required int totalAmount,
  }) {
    final orderItems = cartItems.map<OrderItem>((item) {
      return OrderItem(
        productName: item.productName,
        quantity: item.quantity,
        price: item.price,
      );
    }).toList();

    orders.insert(
      0,
      Order(
        items: orderItems,
        totalAmount: totalAmount,
        date: DateTime.now(),
      ),
    );

    orderVersion.value++;
  }
}