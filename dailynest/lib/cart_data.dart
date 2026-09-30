import 'package:flutter/foundation.dart';

class CartItem {
  final String productName;
  final String category;
  final String productQuantity;
  final int price;
  int quantity;

  CartItem({
    required this.productName,
    required this.category,
    required this.productQuantity,
    required this.price,
    this.quantity = 1,
  });

  int get totalPrice => price * quantity;
}

class CartData {
  static final List<CartItem> items = [];

  // Used to refresh Cart badge automatically
  static final ValueNotifier<int> cartVersion =
      ValueNotifier<int>(0);

  // =========================
  // ADD ITEM
  // =========================

  static void addItem({
    required String productName,
    required String category,
    required String productQuantity,
    required int price,
    int quantity = 1,
  }) {
    final existingIndex = items.indexWhere(
      (item) =>
          item.productName == productName &&
          item.category == category,
    );

    if (existingIndex != -1) {
      items[existingIndex].quantity += quantity;
    } else {
      items.add(
        CartItem(
          productName: productName,
          category: category,
          productQuantity: productQuantity,
          price: price,
          quantity: quantity,
        ),
      );
    }

    // Refresh badge
    cartVersion.value++;
  }

  // =========================
  // TOTAL CART ITEM COUNT
  // =========================
  //
  // Example:
  // Apple x 1  -> 1
  // Apple x 2  -> 2
  // Apple x 2 + Milk x 1 -> 3
  //

  static int get itemCount {
    int count = 0;

    for (final item in items) {
      count += item.quantity;
    }

    return count;
  }

  // =========================
  // REMOVE ITEM
  // =========================

  static void removeItem(int index) {
    if (index >= 0 && index < items.length) {
      items.removeAt(index);

      cartVersion.value++;
    }
  }

  // =========================
  // INCREASE QUANTITY
  // =========================

  static void increaseQuantity(int index) {
    if (index >= 0 && index < items.length) {
      items[index].quantity++;

      cartVersion.value++;
    }
  }

  // =========================
  // DECREASE QUANTITY
  // =========================

  static void decreaseQuantity(int index) {
    if (index >= 0 && index < items.length) {
      if (items[index].quantity > 1) {
        items[index].quantity--;
      } else {
        items.removeAt(index);
      }

      cartVersion.value++;
    }
  }

  // =========================
  // TOTAL AMOUNT
  // =========================

  static int get totalAmount {
    int total = 0;

    for (final item in items) {
      total += item.totalPrice;
    }

    return total;
  }

  // =========================
  // CLEAR CART
  // =========================

  static void clearCart() {
    items.clear();

    cartVersion.value++;
  }
}