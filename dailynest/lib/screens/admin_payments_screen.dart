import 'package:flutter/material.dart';

class AdminPayment {
  String paymentId;
  String orderId;
  String customer;
  int amount;
  String method;
  String status;
  String date;

  AdminPayment({
    required this.paymentId,
    required this.orderId,
    required this.customer,
    required this.amount,
    required this.method,
    required this.status,
    required this.date,
  });
}

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() =>
      _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState
    extends State<AdminPaymentsScreen> {
  static const Color primaryColor = Color(0xFF159A93);

  final TextEditingController searchController =
      TextEditingController();

  String selectedFilter = 'All';

  final List<AdminPayment> payments = [
    AdminPayment(
      paymentId: 'PAY1001',
      orderId: '#DN1001',
      customer: 'Customer 1',
      amount: 450,
      method: 'UPI',
      status: 'Paid',
      date: '03 Sep 2026',
    ),
    AdminPayment(
      paymentId: 'PAY1002',
      orderId: '#DN1002',
      customer: 'Customer 2',
      amount: 320,
      method: 'Card',
      status: 'Paid',
      date: '03 Sep 2026',
    ),
    AdminPayment(
      paymentId: 'PAY1003',
      orderId: '#DN1003',
      customer: 'Customer 3',
      amount: 680,
      method: 'COD',
      status: 'Pending',
      date: '02 Sep 2026',
    ),
    AdminPayment(
      paymentId: 'PAY1004',
      orderId: '#DN1004',
      customer: 'Customer 4',
      amount: 550,
      method: 'UPI',
      status: 'Failed',
      date: '02 Sep 2026',
    ),
    AdminPayment(
      paymentId: 'PAY1005',
      orderId: '#DN1005',
      customer: 'Customer 5',
      amount: 790,
      method: 'Card',
      status: 'Paid',
      date: '01 Sep 2026',
    ),
    AdminPayment(
      paymentId: 'PAY1006',
      orderId: '#DN1006',
      customer: 'Customer 6',
      amount: 420,
      method: 'UPI',
      status: 'Refunded',
      date: '31 Aug 2026',
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<AdminPayment> get filteredPayments {
    final query =
        searchController.text.toLowerCase().trim();

    return payments.where((payment) {
      final matchesSearch =
          payment.paymentId.toLowerCase().contains(query) ||
              payment.orderId.toLowerCase().contains(query) ||
              payment.customer.toLowerCase().contains(query) ||
              payment.method.toLowerCase().contains(query);

      final matchesFilter =
          selectedFilter == 'All' ||
              payment.status == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  Color statusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Failed':
        return Colors.red;
      case 'Refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData methodIcon(String method) {
    switch (method) {
      case 'UPI':
        return Icons.account_balance_outlined;
      case 'Card':
        return Icons.credit_card_outlined;
      case 'COD':
        return Icons.money_outlined;
      default:
        return Icons.payment_outlined;
    }
  }

  void showPaymentDetails(AdminPayment payment) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Payment Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _detailRow(
                'Payment ID',
                payment.paymentId,
              ),
              _detailRow(
                'Order ID',
                payment.orderId,
              ),
              _detailRow(
                'Customer',
                payment.customer,
              ),
              _detailRow(
                'Amount',
                '₹${payment.amount}',
              ),
              _detailRow(
                'Payment Method',
                payment.method,
              ),
              _detailRow(
                'Status',
                payment.status,
              ),
              _detailRow(
                'Date',
                payment.date,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void processRefund(AdminPayment payment) {
    if (payment.status == 'Refunded') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This payment is already refunded',
          ),
        ),
      );
      return;
    }

    if (payment.status != 'Paid') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Only paid payments can be refunded',
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Process Refund',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Refund ₹${payment.amount} for '
            '${payment.orderId}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  payment.status = 'Refunded';
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Refund processed successfully',
                    ),
                  ),
                );
              },
              child: const Text('Refund'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedPayments = filteredPayments;

    final totalAmount = payments.fold<int>(
      0,
      (sum, payment) => sum + payment.amount,
    );

    final paidAmount = payments
        .where((payment) => payment.status == 'Paid')
        .fold<int>(
          0,
          (sum, payment) => sum + payment.amount,
        );

    final refundedAmount = payments
        .where((payment) => payment.status == 'Refunded')
        .fold<int>(
          0,
          (sum, payment) => sum + payment.amount,
        );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          'Payments & Refunds',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          // ==========================
          // SUMMARY
          // ==========================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              5,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    'Total',
                    '₹$totalAmount',
                    Icons.account_balance_wallet_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryCard(
                    'Paid',
                    '₹$paidAmount',
                    Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryCard(
                    'Refunded',
                    '₹$refundedAmount',
                    Icons.replay_outlined,
                  ),
                ),
              ],
            ),
          ),

          // ==========================
          // SEARCH
          // ==========================

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText:
                    'Search payment, order or customer...',
                prefixIcon: const Icon(
                  Icons.search,
                ),
                suffixIcon:
                    searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(
                              Icons.clear,
                            ),
                          )
                        : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ==========================
          // FILTER
          // ==========================

          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              children: [
                'All',
                'Paid',
                'Pending',
                'Failed',
                'Refunded',
              ].map((filter) {
                final isSelected =
                    selectedFilter == filter;

                return Padding(
                  padding: const EdgeInsets.only(
                    right: 8,
                  ),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor:
                        primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.black87,
                      fontWeight:
                          FontWeight.w600,
                    ),
                    onSelected: (_) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                Text(
                  '${displayedPayments.length} Payments',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'Total: ${payments.length}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ==========================
          // PAYMENT LIST
          // ==========================

          Expanded(
            child: displayedPayments.isEmpty
                ? const Center(
                    child: Text(
                      'No payments found',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(
                      16,
                      5,
                      16,
                      20,
                    ),
                    itemCount:
                        displayedPayments.length,
                    itemBuilder:
                        (context, index) {
                      final payment =
                          displayedPayments[index];

                      return Card(
                        color: Colors.white,
                        margin:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),
                        elevation: 1,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                height: 52,
                                width: 52,
                                decoration:
                                    BoxDecoration(
                                  color: const Color(
                                    0xFFE8F7F5,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    14,
                                  ),
                                ),
                                child: Icon(
                                  methodIcon(
                                    payment.method,
                                  ),
                                  color:
                                      primaryColor,
                                  size: 26,
                                ),
                              ),

                              const SizedBox(
                                width: 14,
                              ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      payment.paymentId,
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 4,
                                    ),

                                    Text(
                                      '${payment.orderId} • '
                                      '${payment.customer}',
                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 7,
                                    ),

                                    Row(
                                      children: [
                                        Text(
                                          '₹${payment.amount}',
                                          style:
                                              const TextStyle(
                                            fontWeight:
                                                FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),

                                        const SizedBox(
                                          width: 12,
                                        ),

                                        Text(
                                          payment.method,
                                          style:
                                              const TextStyle(
                                            color:
                                                primaryColor,
                                            fontSize: 12,
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                      height: 5,
                                    ),

                                    Text(
                                      payment.date,
                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.grey,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .end,
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal: 8,
                                      vertical: 5,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      color:
                                          statusColor(
                                        payment.status,
                                      ).withOpacity(
                                        0.1,
                                      ),
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        8,
                                      ),
                                    ),
                                    child: Text(
                                      payment.status,
                                      style: TextStyle(
                                        color:
                                            statusColor(
                                          payment.status,
                                        ),
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 5,
                                  ),

                                  PopupMenuButton<String>(
                                    onSelected:
                                        (value) {
                                      if (value ==
                                          'details') {
                                        showPaymentDetails(
                                          payment,
                                        );
                                      }

                                      if (value ==
                                          'refund') {
                                        processRefund(
                                          payment,
                                        );
                                      }
                                    },
                                    itemBuilder:
                                        (context) =>
                                            const [
                                      PopupMenuItem(
                                        value:
                                            'details',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons
                                                  .visibility_outlined,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              'View Details',
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value:
                                            'refund',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons
                                                  .replay_outlined,
                                              color:
                                                  Colors.red,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              'Refund',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
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

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: primaryColor,
              size: 22,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}