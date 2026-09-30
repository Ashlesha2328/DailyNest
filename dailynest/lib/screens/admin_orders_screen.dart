import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  static const Color primaryColor = Color(0xFF159A93);

  final TextEditingController searchController =
      TextEditingController();

  List<dynamic> orders = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // =====================================================
  // LOAD ALL ORDERS
  // =====================================================

  Future<void> loadOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await ApiService.getAllOrders();

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        orders = result['orders'] ?? [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        errorMessage =
            result['message'] ?? 'Unable to fetch orders';
      });
    }
  }

  // =====================================================
  // FILTER ORDERS
  // =====================================================

  List<dynamic> get filteredOrders {
    final query = searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      return orders;
    }

    return orders.where((order) {
      final orderId =
          order['id']?.toString().toLowerCase() ?? '';

      final customer =
          order['customer_name']?.toString().toLowerCase() ?? '';

      final email =
          order['customer_email']?.toString().toLowerCase() ?? '';

      final mobile =
          order['customer_mobile']?.toString().toLowerCase() ?? '';

      final status =
          order['order_status']?.toString().toLowerCase() ?? '';

      return orderId.contains(query) ||
          customer.contains(query) ||
          email.contains(query) ||
          mobile.contains(query) ||
          status.contains(query);
    }).toList();
  }

  // =====================================================
  // STATUS COLOR
  // =====================================================

  Color getStatusColor(String status) {
    switch (status) {
      case 'Placed':
        return Colors.orange;

      case 'Processing':
        return Colors.blue;

      case 'Out for Delivery':
        return Colors.purple;

      case 'Delivered':
        return Colors.green;

      case 'Cancelled':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  // =====================================================
  // UPDATE ORDER STATUS
  // =====================================================

  Future<void> updateStatus(
    dynamic order,
    String newStatus,
  ) async {
    final orderId = int.tryParse(
      order['id'].toString(),
    );

    if (orderId == null) {
      return;
    }

    final result = await ApiService.updateOrderStatus(
      orderId: orderId,
      orderStatus: newStatus,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        order['order_status'] = newStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order #$orderId status updated to $newStatus',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ??
                'Unable to update order status',
          ),
        ),
      );
    }
  }

  // =====================================================
  // ORDER DETAILS
  // =====================================================

  void showOrderDetails(dynamic order) {
    final orderId = order['id']?.toString() ?? '-';

    final customerName =
        order['customer_name']?.toString() ?? 'Unknown Customer';

    final customerEmail =
        order['customer_email']?.toString() ?? '-';

    final customerMobile =
        order['customer_mobile']?.toString() ?? '-';

    final amount =
        order['total_amount']?.toString() ?? '0';

    final subtotal =
        order['subtotal']?.toString() ?? '0';

    final deliveryCharge =
        order['delivery_charge']?.toString() ?? '0';

    final tax =
        order['tax']?.toString() ?? '0';

    final discount =
        order['discount']?.toString() ?? '0';

    final paymentMethod =
        order['payment_method']?.toString() ?? '-';

    final status =
        order['order_status']?.toString() ?? 'Placed';

    final deliveryAddress =
        order['delivery_address']?.toString() ?? '-';

    final deliveryDate =
        order['delivery_date']?.toString() ?? '-';

    final deliverySlot =
        order['delivery_slot']?.toString() ?? '-';

    final items = order['items'] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =================================================
                // HEADER
                // =================================================

                Row(
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      color: primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Order #$orderId',
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

                const Divider(),

                const SizedBox(height: 15),

                // =================================================
                // CUSTOMER
                // =================================================

                const Text(
                  'Customer Details',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                _detailRow(
                  'Name',
                  customerName,
                ),

                _detailRow(
                  'Email',
                  customerEmail,
                ),

                _detailRow(
                  'Mobile',
                  customerMobile,
                ),

                const SizedBox(height: 10),

                const Divider(),

                const SizedBox(height: 10),

                // =================================================
                // ITEMS
                // =================================================

                const Text(
                  'Order Items',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                if (items.isEmpty)
                  const Text(
                    'No items found',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  )
                else
                  ...items.map<Widget>((item) {
                    final productName =
                        item['product_name']?.toString() ?? '-';

                    final quantity =
                        item['quantity']?.toString() ?? '1';

                    final price =
                        item['price']?.toString() ?? '0';

                    return Container(
                      margin:
                          const EdgeInsets.only(bottom: 10),
                      padding:
                          const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9F9),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '$productName × $quantity',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '₹$price',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                const SizedBox(height: 10),

                const Divider(),

                const SizedBox(height: 10),

                // =================================================
                // DELIVERY
                // =================================================

                const Text(
                  'Delivery Details',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                _detailRow(
                  'Address',
                  deliveryAddress,
                ),

                _detailRow(
                  'Date',
                  deliveryDate,
                ),

                _detailRow(
                  'Slot',
                  deliverySlot,
                ),

                _detailRow(
                  'Payment',
                  paymentMethod,
                ),

                const SizedBox(height: 10),

                const Divider(),

                const SizedBox(height: 10),

                // =================================================
                // BILL
                // =================================================

                const Text(
                  'Bill Summary',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                _billRow(
                  'Subtotal',
                  '₹$subtotal',
                ),

                _billRow(
                  'Delivery Charge',
                  '₹$deliveryCharge',
                ),

                _billRow(
                  'Tax',
                  '₹$tax',
                ),

                _billRow(
                  'Discount',
                  '₹$discount',
                ),

                const Divider(),

                _billRow(
                  'Total',
                  '₹$amount',
                  isTotal: true,
                ),

                const SizedBox(height: 18),

                // =================================================
                // STATUS
                // =================================================

                const Text(
                  'Order Status',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: [
                    'Placed',
                    'Processing',
                    'Out for Delivery',
                    'Delivered',
                    'Cancelled',
                  ].contains(status)
                      ? status
                      : 'Placed',
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(
                      Icons.sync,
                      color: getStatusColor(status),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Placed',
                      child: Text('Placed'),
                    ),
                    DropdownMenuItem(
                      value: 'Processing',
                      child: Text('Processing'),
                    ),
                    DropdownMenuItem(
                      value: 'Out for Delivery',
                      child: Text('Out for Delivery'),
                    ),
                    DropdownMenuItem(
                      value: 'Delivered',
                      child: Text('Delivered'),
                    ),
                    DropdownMenuItem(
                      value: 'Cancelled',
                      child: Text('Cancelled'),
                    ),
                  ],
                  onChanged: (value) async {
                    if (value == null ||
                        value == status) {
                      return;
                    }

                    Navigator.pop(sheetContext);

                    await updateStatus(
                      order,
                      value,
                    );
                  },
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // =====================================================
  // DETAIL ROW
  // =====================================================

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // BILL ROW
  // =====================================================

  Widget _billRow(
    String title,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isTotal
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 17 : 14,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final displayedOrders = filteredOrders;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          'Manage Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadOrders,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ===================================================
          // SEARCH
          // ===================================================

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText:
                    'Search order, customer, mobile or status...',
                prefixIcon:
                    const Icon(Icons.search),
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

          // ===================================================
          // ORDER COUNT
          // ===================================================

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                Text(
                  '${displayedOrders.length} Orders',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'Total: ${orders.length}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ===================================================
          // CONTENT
          // ===================================================

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : errorMessage != null
                    ? Center(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 50,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                errorMessage!,
                                textAlign:
                                    TextAlign.center,
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton(
                                onPressed: loadOrders,
                                child:
                                    const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : displayedOrders.isEmpty
                        ? const Center(
                            child: Text(
                              'No orders found',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: loadOrders,
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(
                                16,
                                5,
                                16,
                                20,
                              ),
                              itemCount:
                                  displayedOrders.length,
                              itemBuilder:
                                  (context, index) {
                                final order =
                                    displayedOrders[index];

                                final orderId =
                                    order['id']
                                            ?.toString() ??
                                        '-';

                                final customer =
                                    order['customer_name']
                                            ?.toString() ??
                                        'Unknown Customer';

                                final amount =
                                    order['total_amount']
                                            ?.toString() ??
                                        '0';

                                final status =
                                    order['order_status']
                                            ?.toString() ??
                                        'Placed';

                                final items =
                                    order['items'] ?? [];

                                final itemNames =
                                    items.map<String>((item) {
                                  final name =
                                      item['product_name']
                                              ?.toString() ??
                                          '-';

                                  final quantity =
                                      item['quantity']
                                              ?.toString() ??
                                          '1';

                                  return '$name × $quantity';
                                }).join(', ');

                                final createdAt =
                                    order['created_at']
                                            ?.toString() ??
                                        '';

                                final statusColor =
                                    getStatusColor(status);

                                return Card(
                                  color: Colors.white,
                                  elevation: 1,
                                  margin:
                                      const EdgeInsets.only(
                                    bottom: 12,
                                  ),
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      16,
                                    ),
                                  ),
                                  child: InkWell(
                                    borderRadius:
                                        BorderRadius.circular(
                                      16,
                                    ),
                                    onTap: () {
                                      showOrderDetails(
                                        order,
                                      );
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.all(
                                        15,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
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
                                                child:
                                                    const Icon(
                                                  Icons
                                                      .shopping_bag_outlined,
                                                  color:
                                                      primaryColor,
                                                ),
                                              ),

                                              const SizedBox(
                                                width: 12,
                                              ),

                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    Text(
                                                      '#$orderId',
                                                      style:
                                                          const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            16,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 4,
                                                    ),
                                                    Text(
                                                      customer,
                                                      style:
                                                          const TextStyle(
                                                        color:
                                                            Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              Text(
                                                '₹$amount',
                                                style:
                                                    const TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  fontSize:
                                                      16,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(
                                            height: 14,
                                          ),

                                          Text(
                                            itemNames.isEmpty
                                                ? 'No items'
                                                : itemNames,
                                            style:
                                                const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),

                                          const SizedBox(
                                            height: 12,
                                          ),

                                          Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .calendar_today_outlined,
                                                size: 15,
                                                color: Colors
                                                    .grey
                                                    .shade600,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  createdAt,
                                                  style:
                                                      const TextStyle(
                                                    color:
                                                        Colors.grey,
                                                    fontSize:
                                                        13,
                                                  ),
                                                  overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                ),
                                              ),

                                              const SizedBox(
                                                width: 8,
                                              ),

                                              Container(
                                                padding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                  horizontal:
                                                      10,
                                                  vertical: 6,
                                                ),
                                                decoration:
                                                    BoxDecoration(
                                                  color:
                                                      statusColor
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
                                                  status,
                                                  style:
                                                      TextStyle(
                                                    color:
                                                        statusColor,
                                                    fontWeight:
                                                        FontWeight
                                                            .w600,
                                                    fontSize:
                                                        12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(
                                            height: 8,
                                          ),

                                          const Align(
                                            alignment:
                                                Alignment
                                                    .centerRight,
                                            child: Text(
                                              'Tap to view / update',
                                              style:
                                                  TextStyle(
                                                color:
                                                    primaryColor,
                                                fontSize: 12,
                                                fontWeight:
                                                    FontWeight
                                                        .w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}