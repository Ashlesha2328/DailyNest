import 'package:flutter/material.dart';
import '../subscription_data.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  static const Color primaryColor = Color(0xFF159A93);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: SubscriptionData.subscriptionVersion,
      builder: (context, value, child) {
        final subscriptions =
            SubscriptionData.subscriptions;

        return Scaffold(
          backgroundColor: Colors.white,

          appBar: AppBar(
            title: const Text(
              'My Subscriptions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
          ),

          body: subscriptions.isEmpty
              ? _emptySubscriptions()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: subscriptions.length,
                  itemBuilder: (context, index) {
                    final subscription =
                        subscriptions[index];

                    return _subscriptionCard(
                      context,
                      subscription,
                      index,
                    );
                  },
                ),
        );
      },
    );
  }

  // =========================
  // SUBSCRIPTION CARD
  // =========================

  Widget _subscriptionCard(
    BuildContext context,
    Subscription subscription,
    int index,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // PRODUCT
            Row(
              children: [
                Container(
                  width: 65,
                  height: 65,

                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7F5),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),

                  child: const Icon(
                    Icons.local_drink,
                    color: primaryColor,
                    size: 34,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        subscription.productName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        '${subscription.productQuantity} • Qty: ${subscription.quantity}',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        '₹${subscription.totalPrice}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                _statusBadge(subscription),
              ],
            ),

            const SizedBox(height: 18),

            const Divider(),

            const SizedBox(height: 12),

            // FREQUENCY
            Row(
              children: [
                const Icon(
                  Icons.repeat,
                  size: 21,
                  color: primaryColor,
                ),

                const SizedBox(width: 10),

                const Text(
                  'Frequency',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                Text(
                  subscription.frequency,
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // NEXT DELIVERY
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: primaryColor,
                ),

                const SizedBox(width: 10),

                const Text(
                  'Next Delivery',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                Text(
                  _formatDate(
                    subscription.nextDeliveryDate,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (subscription.isPaused) {
                        SubscriptionData
                            .resumeSubscription(index);
                      } else {
                        SubscriptionData
                            .pauseSubscription(index);
                      }
                    },

                    icon: Icon(
                      subscription.isPaused
                          ? Icons.play_arrow
                          : Icons.pause,
                      size: 18,
                    ),

                    label: Text(
                      subscription.isPaused
                          ? 'Resume'
                          : 'Pause',
                    ),

                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: const BorderSide(
                        color: primaryColor,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        subscription.isPaused
                            ? null
                            : () {
                                SubscriptionData
                                    .skipNextDelivery(
                                  index,
                                );

                                ScaffoldMessenger
                                        .of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Next delivery skipped',
                                    ),
                                  ),
                                );
                              },

                    icon: const Icon(
                      Icons.skip_next,
                      size: 18,
                    ),

                    label: const Text(
                      'Skip',
                    ),

                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: const BorderSide(
                        color: primaryColor,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // CANCEL
            SizedBox(
              width: double.infinity,

              child: TextButton.icon(
                onPressed: () {
                  _showCancelDialog(
                    context,
                    index,
                    subscription.productName,
                  );
                },

                icon: const Icon(
                  Icons.cancel_outlined,
                  color: Colors.red,
                ),

                label: const Text(
                  'Cancel Subscription',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // STATUS BADGE
  // =========================

  Widget _statusBadge(
    Subscription subscription,
  ) {
    final bool paused =
        subscription.isPaused;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: paused
            ? Colors.orange.shade50
            : Colors.teal.shade50,

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Text(
        paused ? 'Paused' : 'Active',

        style: TextStyle(
          color: paused
              ? Colors.orange.shade800
              : primaryColor,

          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // =========================
  // CANCEL DIALOG
  // =========================

  void _showCancelDialog(
    BuildContext context,
    int index,
    String productName,
  ) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Cancel Subscription?',
          ),

          content: Text(
            'Are you sure you want to cancel '
            'the subscription for $productName?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                'No',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                SubscriptionData
                    .cancelSubscription(index);

                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Subscription cancelled',
                    ),
                  ),
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),

              child: const Text(
                'Yes, Cancel',
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // EMPTY STATE
  // =========================

  Widget _emptySubscriptions() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              Icons.repeat,
              size: 85,
              color: primaryColor,
            ),

            SizedBox(height: 20),

            Text(
              'No subscriptions yet',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8),

            Text(
              'Subscribe to your daily essentials '
              'and never miss a delivery.',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // DATE FORMAT
  // =========================

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}