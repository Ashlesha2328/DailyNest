import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailsScreen> createState() =>
      _OrderDetailsScreenState();
}

class _OrderDetailsScreenState
    extends State<OrderDetailsScreen> {
  static const Color primaryColor =
      Color(0xFF159A93);

  Map<String, dynamic>? order;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadOrder();
  }

  // =========================
  // LOAD ORDER FROM BACKEND
  // =========================

  Future<void> loadOrder() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result =
          await ApiService.getOrderById(
        orderId: widget.orderId,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        print('ORDER DETAILS RESPONSE: ${result['order']}');
        setState(() {
          order = result['order'];
        });
      } else {
        setState(() {
          errorMessage =
              result['message'] ??
                  'Unable to fetch order';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            'Unable to connect to server';
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Order Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed:
                isLoading ? null : loadOrder,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : errorMessage != null
              ? _errorView()
              : order == null
                  ? _errorView()
                  : _orderDetails(),
    );
  }

  // =========================
  // ORDER DETAILS
  // =========================

  Widget _orderDetails() {
    final List<dynamic> items =
        order!['items'] ?? [];

    final String status =
        order!['order_status']
                ?.toString() ??
            'Placed';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // =========================
          // ORDER STATUS
          // =========================

          _sectionTitle(
            'Order Status',
          ),

          const SizedBox(height: 10),

          Card(
            elevation: 2,

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),

            child: Padding(
              padding:
                  const EdgeInsets.all(16),

              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.teal.shade50,
                      shape:
                          BoxShape.circle,
                    ),

                    child: Icon(
                      _statusIcon(status),
                      color:
                          _statusColor(
                        status,
                      ),
                      size: 30,
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
                          status,
                          style:
                              const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Text(
                          _formatBackendDate(
                            order![
                                'created_at'],
                          ),
                          style:
                              const TextStyle(
                            color:
                                Colors.grey,
                            fontSize: 14,
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
                      color:
                          Colors.teal.shade50,
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),

                    child: Text(
                      status,
                      style:
                          const TextStyle(
                        color:
                            Colors.teal,
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Order ID: #${order!['id']}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 24),

          // =========================
          // DELIVERY ADDRESS
          // =========================

          _sectionTitle(
            'Delivery Address',
          ),

          const SizedBox(height: 10),

          Card(
            elevation: 2,

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),

            child: ListTile(
              contentPadding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 16,
                vertical: 8,
              ),

              leading: const Icon(
                Icons.location_on,
                color: Colors.teal,
                size: 30,
              ),

              title: const Text(
                'Delivery Address',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              subtitle: Padding(
                padding:
                    const EdgeInsets.only(
                  top: 4,
                ),

                child: Text(
                  order![
                              'delivery_address']
                          ?.toString() ??
                      'Address not available',
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // =========================
          // DELIVERY INFORMATION
          // =========================

          _sectionTitle(
            'Delivery Information',
          ),

          const SizedBox(height: 10),

          Card(
            elevation: 2,

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),

            child: Padding(
              padding:
                  const EdgeInsets.all(16),

              child: Column(
                children: [
                  _infoRow(
                    Icons.calendar_today,
                    'Delivery Date',
                    order![
                                'delivery_date']
                            ?.toString() ??
                        'Not selected',
                  ),

                  const Divider(
                    height: 24,
                  ),

                  _infoRow(
                    Icons.access_time,
                    'Delivery Slot',
                    order![
                                'delivery_slot']
                            ?.toString() ??
                        'Not selected',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // =========================
          // ITEMS
          // =========================

          _sectionTitle('Items'),

          const SizedBox(height: 10),

          Card(
            elevation: 2,

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),

            child: Padding(
              padding:
                  const EdgeInsets.all(16),

              child: Column(
                children: [
                  for (int i = 0;
                      i < items.length;
                      i++)
                    Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,

                              decoration:
                                  BoxDecoration(
                                color: Colors
                                    .grey
                                    .shade100,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  10,
                                ),
                              ),

                              child:
                                  const Icon(
                                Icons
                                    .shopping_bag_outlined,
                                color:
                                    Colors.teal,
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
                                    items[i][
                                                'product_name']
                                            ?.toString() ??
                                        'Product',

                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                      fontSize:
                                          15,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    'Quantity: ${items[i]['quantity']}',

                                    style:
                                        const TextStyle(
                                      color:
                                          Colors
                                              .grey,
                                      fontSize:
                                          13,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Text(
                              '₹${_itemTotal(items[i])}',

                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                                fontSize:
                                    15,
                              ),
                            ),
                          ],
                        ),

                        if (i !=
                            items.length - 1)
                          const Padding(
                            padding:
                                EdgeInsets
                                    .symmetric(
                              vertical: 12,
                            ),
                            child:
                                Divider(),
                          ),
                      ],
                    ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Divider(),

                  const SizedBox(
                    height: 12,
                  ),

                  // =========================
                  // BILL SUMMARY
                  // =========================

                  _billRow(
                    'Subtotal',
                    '₹${_formatMoney(order!['subtotal'])}',
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _billRow(
                    'Delivery Charge',
                    _deliveryChargeText(),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _billRow(
                    'Tax',
                    '₹${_formatMoney(order!['tax'])}',
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _billRow(
                    'Discount',
                    '₹${_formatMoney(order!['discount'])}',
                    valueColor:
                        Colors.green,
                  ),

                  const Divider(
                    height: 25,
                  ),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      Text(
                        '₹${_formatMoney(order!['total_amount'])}',

                        style:
                            const TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // =========================
          // PAYMENT METHOD
          // =========================

          _sectionTitle(
            'Payment Method',
          ),

          const SizedBox(height: 10),

          Card(
            elevation: 2,

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),

            child: ListTile(
              contentPadding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 16,
                vertical: 8,
              ),

              leading: const Icon(
                Icons.payments_outlined,
                color: Colors.teal,
                size: 30,
              ),

              title: Text(
                order![
                            'payment_method']
                        ?.toString() ??
                    'Cash on Delivery',

                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              subtitle: const Padding(
                padding:
                    EdgeInsets.only(
                  top: 4,
                ),

                child: Text(
                  'Payment will be collected on delivery',
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // =========================
  // SECTION TITLE
  // =========================

  Widget _sectionTitle(
    String title,
  ) {
    return Text(
      title,

      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // =========================
  // INFO ROW
  // =========================

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.teal,
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                title,
                style:
                    const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              Text(
                value,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================
  // BILL ROW
  // =========================

  Widget _billRow(
    String title,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment
              .spaceBetween,

      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
          ),
        ),

        Text(
          value,
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
            color:
                valueColor ??
                    Colors.black87,
          ),
        ),
      ],
    );
  }

  // =========================
  // DELIVERY CHARGE
  // =========================

  String _deliveryChargeText() {
    final double charge =
        double.tryParse(
              order![
                          'delivery_charge']
                      ?.toString() ??
                  '0',
            ) ??
            0;

    if (charge == 0) {
      return 'FREE';
    }

    return '₹${charge.toStringAsFixed(0)}';
  }

  // =========================
  // ITEM TOTAL
  // =========================

  String _itemTotal(
    dynamic item,
  ) {
    final double price =
        double.tryParse(
              item['price']?.toString() ??
                  '0',
            ) ??
            0;

    final int quantity =
        int.tryParse(
              item['quantity']?.toString() ??
                  '1',
            ) ??
            1;

    return (price * quantity)
        .toStringAsFixed(0);
  }

  // =========================
  // FORMAT MONEY
  // =========================

  String _formatMoney(
    dynamic value,
  ) {
    final double amount =
        double.tryParse(
              value?.toString() ?? '0',
            ) ??
            0;

    return amount.toStringAsFixed(0);
  }

  // =========================
  // FORMAT DATE
  // =========================

  String _formatBackendDate(
    dynamic value,
  ) {
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
  // STATUS ICON
  // =========================

  IconData _statusIcon(
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Icons.check_circle;

      case 'cancelled':
        return Icons.cancel;

      case 'out for delivery':
        return Icons.delivery_dining;

      case 'processing':
        return Icons.inventory_2;

      case 'shipped':
        return Icons.local_shipping;

      default:
        return Icons.check_circle;
    }
  }

  // =========================
  // STATUS COLOR
  // =========================

  Color _statusColor(
    String status,
  ) {
    if (status.toLowerCase() ==
        'cancelled') {
      return Colors.red;
    }

    return Colors.teal;
  }

  // =========================
  // ERROR VIEW
  // =========================

  Widget _errorView() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.error_outline,
              size: 70,
              color: Colors.redAccent,
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              errorMessage ??
                  'Unable to load order',
              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton(
              onPressed: loadOrder,

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