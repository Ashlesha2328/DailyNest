import 'package:flutter/material.dart';

class AdminSubscription {
  final String subscriptionId;
  final String customer;
  final String product;
  final String frequency;
  final int quantity;
  final String startDate;
  String status;

  AdminSubscription({
    required this.subscriptionId,
    required this.customer,
    required this.product,
    required this.frequency,
    required this.quantity,
    required this.startDate,
    required this.status,
  });
}

class AdminSubscriptionsScreen extends StatefulWidget {
  const AdminSubscriptionsScreen({super.key});

  @override
  State<AdminSubscriptionsScreen> createState() =>
      _AdminSubscriptionsScreenState();
}

class _AdminSubscriptionsScreenState
    extends State<AdminSubscriptionsScreen> {
  static const Color primaryColor = Color(0xFF159A93);

  final TextEditingController searchController =
      TextEditingController();

  final List<AdminSubscription> subscriptions = [
    AdminSubscription(
      subscriptionId: '#SUB1001',
      customer: 'Customer 1',
      product: 'Amul Taaza Milk',
      frequency: 'Daily',
      quantity: 1,
      startDate: '01 Sep 2026',
      status: 'Active',
    ),
    AdminSubscription(
      subscriptionId: '#SUB1002',
      customer: 'Customer 2',
      product: 'Fresh Bananas',
      frequency: 'Alternate Days',
      quantity: 2,
      startDate: '30 Aug 2026',
      status: 'Active',
    ),
    AdminSubscription(
      subscriptionId: '#SUB1003',
      customer: 'Customer 3',
      product: 'Brown Bread',
      frequency: 'Weekly',
      quantity: 1,
      startDate: '28 Aug 2026',
      status: 'Paused',
    ),
    AdminSubscription(
      subscriptionId: '#SUB1004',
      customer: 'Customer 4',
      product: 'Tata Tea',
      frequency: 'Monthly',
      quantity: 1,
      startDate: '25 Aug 2026',
      status: 'Cancelled',
    ),
    AdminSubscription(
      subscriptionId: '#SUB1005',
      customer: 'Customer 5',
      product: 'Fresh Tomatoes',
      frequency: 'Selected Weekdays',
      quantity: 2,
      startDate: '02 Sep 2026',
      status: 'Active',
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<AdminSubscription> get filteredSubscriptions {
    final query = searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      return subscriptions;
    }

    return subscriptions.where((subscription) {
      return subscription.subscriptionId
              .toLowerCase()
              .contains(query) ||
          subscription.customer
              .toLowerCase()
              .contains(query) ||
          subscription.product
              .toLowerCase()
              .contains(query) ||
          subscription.frequency
              .toLowerCase()
              .contains(query) ||
          subscription.status
              .toLowerCase()
              .contains(query);
    }).toList();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Paused':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void updateStatus(
    AdminSubscription subscription,
    String status,
  ) {
    setState(() {
      subscription.status = status;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${subscription.subscriptionId} updated to $status',
        ),
      ),
    );
  }

  void showSubscriptionDetails(
    AdminSubscription subscription,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.autorenew,
                    color: primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    subscription.subscriptionId,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const Divider(height: 30),

              _detailRow(
                'Customer',
                subscription.customer,
              ),

              _detailRow(
                'Product',
                subscription.product,
              ),

              _detailRow(
                'Frequency',
                subscription.frequency,
              ),

              _detailRow(
                'Quantity',
                '${subscription.quantity}',
              ),

              _detailRow(
                'Start Date',
                subscription.startDate,
              ),

              const SizedBox(height: 8),

              const Text(
                'Subscription Status',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: subscription.status,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Active',
                    child: Text('Active'),
                  ),
                  DropdownMenuItem(
                    value: 'Paused',
                    child: Text('Paused'),
                  ),
                  DropdownMenuItem(
                    value: 'Cancelled',
                    child: Text('Cancelled'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  updateStatus(subscription, value);
                  Navigator.pop(sheetContext);
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedSubscriptions =
        filteredSubscriptions;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          'Manage Subscriptions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText:
                    'Search subscription, customer or product...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                Text(
                  '${displayedSubscriptions.length} Subscriptions',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'Total: ${subscriptions.length}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: displayedSubscriptions.isEmpty
                ? const Center(
                    child: Text(
                      'No subscriptions found',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      5,
                      16,
                      20,
                    ),
                    itemCount:
                        displayedSubscriptions.length,
                    itemBuilder: (context, index) {
                      final subscription =
                          displayedSubscriptions[index];

                      final statusColor =
                          getStatusColor(
                        subscription.status,
                      );

                      return Card(
                        color: Colors.white,
                        elevation: 1,
                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(16),
                          onTap: () {
                            showSubscriptionDetails(
                              subscription,
                            );
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 48,
                                      width: 48,
                                      decoration:
                                          BoxDecoration(
                                        color:
                                            const Color(
                                          0xFFE8F7F5,
                                        ),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          12,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.autorenew,
                                        color:
                                            primaryColor,
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            subscription
                                                .subscriptionId,
                                            style:
                                                const TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(
                                              height: 4),
                                          Text(
                                            subscription
                                                .customer,
                                            style:
                                                const TextStyle(
                                              color:
                                                  Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Container(
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration:
                                          BoxDecoration(
                                        color: statusColor
                                            .withOpacity(
                                          0.10,
                                        ),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          20,
                                        ),
                                      ),
                                      child: Text(
                                        subscription.status,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight:
                                              FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                Text(
                                  subscription.product,
                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),

                                const SizedBox(height: 7),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.repeat,
                                      size: 15,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      subscription.frequency,
                                      style:
                                          const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Text(
                                      'Qty: ${subscription.quantity}',
                                      style:
                                          const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 7),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons
                                          .calendar_today_outlined,
                                      size: 15,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      subscription.startDate,
                                      style:
                                          const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Text(
                                      'Tap to view / update',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 12,
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}