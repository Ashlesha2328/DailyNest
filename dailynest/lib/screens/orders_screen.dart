import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const Color primaryColor = Color(0xFF159A93);

  // Testing user ID
  final int userId = 2;

  List<dynamic> orders = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  // =========================
  // LOAD ORDERS FROM BACKEND
  // =========================

  Future<void> loadOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiService.getUserOrders(
        userId: userId,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          orders = result['orders'] ?? [];
        });
      } else {
        setState(() {
          orders = [];
          errorMessage =
              result['message'] ?? 'Unable to fetch orders';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        orders = [];
        errorMessage = 'Unable to connect to server';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: isLoading ? null : loadOrders,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : errorMessage != null
              ? _errorOrders()
              : orders.isEmpty
                  ? _emptyOrders()
                  : RefreshIndicator(
                      color: primaryColor,
                      onRefresh: loadOrders,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];

                          return _orderCard(order);
                        },
                      ),
                    ),
    );
  }

  // =========================
  // ORDER CARD
  // =========================

  Widget _orderCard(dynamic order) {
    final List<dynamic> items =
        order['items'] ?? [];

    final String status =
        order['order_status']?.toString() ?? 'Placed';

    final String paymentMethod =
        order['payment_method']?.toString() ??
            'Cash on Delivery';

    final String total =
        _formatMoney(order['total_amount']);

    final String orderDate =
        _formatBackendDate(order['created_at']);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(14),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OrderDetailsScreen(
                orderId: int.parse(
                  order['id'].toString(),
                ),
              ),
            ),
          );
        },

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // =========================
              // ORDER HEADER
              // =========================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Order Placed',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        orderDate,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  _statusIcon(status),
                ],
              ),

              const SizedBox(height: 12),

              // =========================
              // ORDER ID
              // =========================

              Text(
                'Order ID: #${order['id']}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),

              const Divider(
                height: 25,
              ),

              // =========================
              // ITEMS
              // =========================

              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),

                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [
                      Expanded(
                        child: Text(
                          '${item['product_name']} × ${item['quantity']}',
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),

                      Text(
                        '₹${_itemTotal(item)}',
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              const Divider(
                height: 25,
              ),

              // =========================
              // TOTAL
              // =========================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Text(
                    '₹$total',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // =========================
              // PAYMENT + STATUS
              // =========================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.teal.shade50,
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),

                    child: Text(
                      paymentMethod,
                      style: const TextStyle(
                        color: Colors.teal,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Text(
                        status,
                        style: const TextStyle(
                          color: Colors.teal,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 8),

                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // STATUS ICON
  // =========================

  Widget _statusIcon(String status) {
    IconData icon;

    switch (status.toLowerCase()) {
      case 'delivered':
        icon = Icons.check_circle;
        break;

      case 'cancelled':
        icon = Icons.cancel;
        break;

      case 'out for delivery':
        icon = Icons.delivery_dining;
        break;

      case 'processing':
        icon = Icons.inventory_2;
        break;

      case 'shipped':
        icon = Icons.local_shipping;
        break;

      default:
        icon = Icons.check_circle;
    }

    return Icon(
      icon,

      color: status.toLowerCase() == 'cancelled'
          ? Colors.red
          : Colors.teal,

      size: 28,
    );
  }

  // =========================
  // ITEM TOTAL
  // =========================

  String _itemTotal(dynamic item) {
    final double price =
        double.tryParse(
              item['price']?.toString() ?? '0',
            ) ??
            0;

    final int quantity =
        int.tryParse(
              item['quantity']?.toString() ?? '1',
            ) ??
            1;

    return (price * quantity).toStringAsFixed(0);
  }

  // =========================
  // FORMAT MONEY
  // =========================

  String _formatMoney(dynamic value) {
    final double amount =
        double.tryParse(
              value?.toString() ?? '0',
            ) ??
            0;

    return amount.toStringAsFixed(0);
  }

  // =========================
  // FORMAT BACKEND DATE
  // =========================

  String _formatBackendDate(dynamic value) {
    if (value == null) {
      return 'Date not available';
    }

    try {
      final DateTime date =
          DateTime.parse(
        value.toString(),
      );

      final String minute =
          date.minute
              .toString()
              .padLeft(2, '0');

      return '${date.day}/${date.month}/${date.year} '
          '${date.hour}:$minute';
    } catch (e) {
      return value.toString();
    }
  }

  // =========================
  // EMPTY ORDERS
  // =========================

  Widget _emptyOrders() {
    return RefreshIndicator(
      color: primaryColor,

      onRefresh: loadOrders,

      child: ListView(
        children: [
          SizedBox(
            height:
                MediaQuery.of(context)
                        .size
                        .height *
                    0.32,
          ),

          const Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.teal,
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'No orders yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Center(
            child: Text(
              'Your orders will appear here.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // ERROR
  // =========================

  Widget _errorOrders() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.error_outline,
              size: 70,
              color: Colors.redAccent,
            ),

            const SizedBox(height: 16),

            Text(
              errorMessage ??
                  'Unable to load orders',
              textAlign: TextAlign.center,

              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loadOrders,

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    primaryColor,
                foregroundColor:
                    Colors.white,
              ),

              child:
                  const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}