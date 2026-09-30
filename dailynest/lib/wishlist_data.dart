import 'package:flutter/foundation.dart';

class WishlistItem {
  final String productName;
  final String category;
  final String productQuantity;
  final int price;
  final dynamic icon;

  WishlistItem({
    required this.productName,
    required this.category,
    required this.productQuantity,
    required this.price,
    required this.icon,
  });
}

class WishlistData {
  static final List<WishlistItem> items = [];

  static final ValueNotifier<int> wishlistVersion =
      ValueNotifier<int>(0);

  static void addItem({
    required String productName,
    required String category,
    required String productQuantity,
    required int price,
    required dynamic icon,
  }) {
    final alreadyExists = items.any(
      (item) =>
          item.productName == productName &&
          item.category == category,
    );

    if (!alreadyExists) {
      items.add(
        WishlistItem(
          productName: productName,
          category: category,
          productQuantity: productQuantity,
          price: price,
          icon: icon,
        ),
      );

      wishlistVersion.value++;
    }
  }

  static void removeItem(int index) {
    if (index >= 0 && index < items.length) {
      items.removeAt(index);
      wishlistVersion.value++;
    }
  }

  static bool isWishlisted({
    required String productName,
    required String category,
  }) {
    return items.any(
      (item) =>
          item.productName == productName &&
          item.category == category,
    );
  }

  static void toggleItem({
    required String productName,
    required String category,
    required String productQuantity,
    required int price,
    required dynamic icon,
  }) {
    final index = items.indexWhere(
      (item) =>
          item.productName == productName &&
          item.category == category,
    );

    if (index != -1) {
      items.removeAt(index);
    } else {
      items.add(
        WishlistItem(
          productName: productName,
          category: category,
          productQuantity: productQuantity,
          price: price,
          icon: icon,
        ),
      );
    }

    wishlistVersion.value++;
  }
}