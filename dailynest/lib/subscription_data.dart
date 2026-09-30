import 'package:flutter/foundation.dart';

class Subscription {
  final String productName;
  final String category;
  final String productQuantity;
  final int price;

  int quantity;
  String frequency;
  DateTime nextDeliveryDate;
  bool isPaused;

  Subscription({
    required this.productName,
    required this.category,
    required this.productQuantity,
    required this.price,
    required this.quantity,
    required this.frequency,
    required this.nextDeliveryDate,
    this.isPaused = false,
  });

  int get totalPrice => price * quantity;
}

class SubscriptionData {
  static final List<Subscription> subscriptions = [];

  static final ValueNotifier<int> subscriptionVersion =
      ValueNotifier<int>(0);

  // ADD / UPDATE SUBSCRIPTION
  static void addSubscription({
    required String productName,
    required String category,
    required String productQuantity,
    required int price,
    required int quantity,
    required String frequency,
    required DateTime nextDeliveryDate,
  }) {
    final existingIndex = subscriptions.indexWhere(
      (subscription) =>
          subscription.productName == productName,
    );

    if (existingIndex != -1) {
      subscriptions[existingIndex].quantity = quantity;
      subscriptions[existingIndex].frequency = frequency;
      subscriptions[existingIndex].nextDeliveryDate =
          nextDeliveryDate;
      subscriptions[existingIndex].isPaused = false;
    } else {
      subscriptions.add(
        Subscription(
          productName: productName,
          category: category,
          productQuantity: productQuantity,
          price: price,
          quantity: quantity,
          frequency: frequency,
          nextDeliveryDate: nextDeliveryDate,
        ),
      );
    }

    subscriptionVersion.value++;
  }

  // PAUSE
  static void pauseSubscription(int index) {
    if (index >= 0 && index < subscriptions.length) {
      subscriptions[index].isPaused = true;
      subscriptionVersion.value++;
    }
  }

  // RESUME
  static void resumeSubscription(int index) {
    if (index >= 0 && index < subscriptions.length) {
      subscriptions[index].isPaused = false;
      subscriptionVersion.value++;
    }
  }

  // SKIP DELIVERY
  static void skipNextDelivery(int index) {
    if (index >= 0 && index < subscriptions.length) {
      final subscription = subscriptions[index];

      subscription.nextDeliveryDate =
          subscription.nextDeliveryDate.add(
        _getDuration(subscription.frequency),
      );

      subscriptionVersion.value++;
    }
  }

  // CANCEL
  static void cancelSubscription(int index) {
    if (index >= 0 && index < subscriptions.length) {
      subscriptions.removeAt(index);
      subscriptionVersion.value++;
    }
  }

  // UPDATE QUANTITY
  static void updateQuantity(
    int index,
    int quantity,
  ) {
    if (index >= 0 &&
        index < subscriptions.length &&
        quantity > 0) {
      subscriptions[index].quantity = quantity;
      subscriptionVersion.value++;
    }
  }

  // UPDATE FREQUENCY
  static void updateFrequency(
    int index,
    String frequency,
  ) {
    if (index >= 0 && index < subscriptions.length) {
      subscriptions[index].frequency = frequency;

      subscriptionVersion.value++;
    }
  }

  static Duration _getDuration(String frequency) {
    switch (frequency) {
      case 'Daily':
        return const Duration(days: 1);

      case 'Alternate Days':
        return const Duration(days: 2);

      case 'Weekly':
        return const Duration(days: 7);

      case 'Monthly':
        return const Duration(days: 30);

      default:
        return const Duration(days: 1);
    }
  }

  static void clearSubscriptions() {
    subscriptions.clear();
    subscriptionVersion.value++;
  }
}