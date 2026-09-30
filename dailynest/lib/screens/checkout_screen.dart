import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../cart_data.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const Color primaryColor = Color(0xFF159A93);

  // Testing user ID
  final int userId = 2;

  String selectedAddress = 'Home';
  String selectedAddressDetails = 'Pune, Maharashtra';

  String selectedDate = 'Tomorrow';
  String selectedSlot = 'Early Morning';

  final List<String> deliverySlots = [
    'Early Morning',
    'Morning',
    'Afternoon',
    'Evening',
  ];

  final TextEditingController couponController =
      TextEditingController();

  String? appliedCoupon;
  int discount = 0;

  static const int deliveryCharge = 40;
  static const double taxRate = 0.05;

  List<dynamic> items = [];

  double subtotal = 0;
  bool isLoading = true;
  bool isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  @override
  void dispose() {
    couponController.dispose();
    super.dispose();
  }

  // =========================
  // LOAD CART FROM BACKEND
  // =========================

  Future<void> loadCart() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await ApiService.getCart(
        userId: userId,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final backendItems = result['cart'] ?? [];

        double calculatedSubtotal = 0;

        for (final item in backendItems) {
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

          calculatedSubtotal += price * quantity;
        }

        setState(() {
          items = backendItems;
          subtotal = calculatedSubtotal;
        });
      } else {
        setState(() {
          items = [];
          subtotal = 0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Unable to load cart',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        items = [];
        subtotal = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to connect to server',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // =========================
  // CALCULATIONS
  // =========================

  int get deliveryFee {
    return subtotal >= 500 ? 0 : deliveryCharge;
  }

  int get tax {
    final double taxableAmount = subtotal - discount;

    return (taxableAmount * taxRate).round();
  }

  int get finalTotal {
    return subtotal.round() -
        discount +
        deliveryFee +
        tax;
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : items.isEmpty
              ? _emptyCheckout()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // =========================
                      // DELIVERY ADDRESS
                      // =========================

                      const Text(
                        'Delivery Address',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),

                          leading: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.teal,
                            ),
                          ),

                          title: Text(
                            selectedAddress,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          subtitle: Text(
                            selectedAddressDetails,
                          ),

                          trailing: TextButton(
                            onPressed:
                                _showAddressDialog,
                            child: const Text(
                              'Change',
                              style: TextStyle(
                                color: Colors.teal,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // =========================
                      // DELIVERY DATE
                      // =========================

                      const Text(
                        'Delivery Date',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _dateOption(
                              title: 'Today',
                              selected:
                                  selectedDate ==
                                      'Today',
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _dateOption(
                              title: 'Tomorrow',
                              selected:
                                  selectedDate ==
                                      'Tomorrow',
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _dateOption(
                              title: 'Day After',
                              selected:
                                  selectedDate ==
                                      'Day After',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // =========================
                      // DELIVERY SLOT
                      // =========================

                      const Text(
                        'Delivery Slot',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      ...deliverySlots.map(
                        (slot) {
                          final bool isSelected =
                              selectedSlot == slot;

                          return Card(
                            margin:
                                const EdgeInsets.only(
                              bottom: 10,
                            ),
                            elevation:
                                isSelected ? 2 : 1,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                14,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.teal
                                    : Colors.transparent,
                              ),
                            ),
                            child:
                                RadioListTile<String>(
                              value: slot,
                              groupValue:
                                  selectedSlot,
                              activeColor:
                                  Colors.teal,

                              title: Text(
                                slot,
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),

                              subtitle: Text(
                                _getSlotTime(slot),
                              ),

                              onChanged: (value) {
                                setState(() {
                                  selectedSlot =
                                      value!;
                                });
                              },
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 18),

                      // =========================
                      // COUPON
                      // =========================

                      const Text(
                        'Apply Coupon',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller:
                                  couponController,

                              enabled:
                                  appliedCoupon ==
                                      null,

                              textCapitalization:
                                  TextCapitalization
                                      .characters,

                              decoration:
                                  InputDecoration(
                                hintText:
                                    'Enter coupon code',

                                prefixIcon:
                                    const Icon(
                                  Icons
                                      .local_offer_outlined,
                                  color:
                                      Colors.teal,
                                ),

                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    12,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          SizedBox(
                            height: 52,
                            child:
                                ElevatedButton(
                              onPressed:
                                  appliedCoupon ==
                                          null
                                      ? () {
                                          _applyCoupon(
                                            subtotal
                                                .round(),
                                          );
                                        }
                                      : () {
                                          setState(() {
                                            appliedCoupon =
                                                null;
                                            discount = 0;
                                            couponController
                                                .clear();
                                          });
                                        },

                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    Colors.teal,
                                foregroundColor:
                                    Colors.white,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    12,
                                  ),
                                ),
                              ),

                              child: Text(
                                appliedCoupon ==
                                        null
                                    ? 'APPLY'
                                    : 'REMOVE',
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (appliedCoupon != null)
                        Padding(
                          padding:
                              const EdgeInsets.only(
                            top: 8,
                          ),
                          child: Text(
                            'Coupon $appliedCoupon applied successfully',
                            style:
                                const TextStyle(
                              color: Colors.teal,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),

                      const SizedBox(height: 28),

                      // =========================
                      // ORDER SUMMARY
                      // =========================

                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // PRODUCTS
                              for (final item in items)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    bottom: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item['product_name']} × ${item['quantity']}',
                                        ),
                                      ),
                                      Text(
                                        '₹${_itemTotal(item)}',
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const Divider(),

                              const SizedBox(height: 8),

                              // SUBTOTAL
                              _summaryRow(
                                'Subtotal',
                                '₹${subtotal.round()}',
                              ),

                              const SizedBox(height: 10),

                              // DISCOUNT
                              if (discount > 0)
                                _summaryRow(
                                  'Coupon Discount',
                                  '-₹$discount',
                                  valueColor:
                                      Colors.green,
                                ),

                              if (discount > 0)
                                const SizedBox(
                                  height: 10,
                                ),

                              // DELIVERY
                              _summaryRow(
                                'Delivery Charge',
                                deliveryFee == 0
                                    ? 'FREE'
                                    : '₹$deliveryFee',
                                valueColor:
                                    deliveryFee == 0
                                        ? Colors.green
                                        : null,
                              ),

                              const SizedBox(height: 10),

                              // TAX
                              _summaryRow(
                                'Tax (5%)',
                                '₹$tax',
                              ),

                              const SizedBox(height: 12),

                              const Divider(),

                              const SizedBox(height: 10),

                              // FINAL TOTAL
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  const Text(
                                    'Final Total',
                                    style:
                                        TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  Text(
                                    '₹$finalTotal',
                                    style:
                                        const TextStyle(
                                      fontSize: 22,
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

                      const SizedBox(height: 28),

                      // =========================
                      // PAYMENT METHOD
                      // =========================

                      const Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: const ListTile(
                          leading: Icon(
                            Icons.money,
                            color: Colors.teal,
                          ),
                          title: Text(
                            'Cash on Delivery',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Pay when your order arrives',
                          ),
                          trailing: Icon(
                            Icons
                                .radio_button_checked,
                            color: Colors.teal,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // =========================
                      // PLACE ORDER
                      // =========================

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed:
                              isPlacingOrder
                                  ? null
                                  : placeOrder,

                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                Colors.teal,
                            foregroundColor:
                                Colors.white,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                14,
                              ),
                            ),
                          ),

                          child: isPlacingOrder
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child:
                                      CircularProgressIndicator(
                                    color:
                                        Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Place Order • ₹$finalTotal',
                                  style:
                                      const TextStyle(
                                    fontSize: 17,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
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
  // SUMMARY ROW
  // =========================

  Widget _summaryRow(
    String title,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
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
            fontWeight: FontWeight.bold,
            color:
                valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  // =========================
  // APPLY COUPON
  // =========================

  void _applyCoupon(int subtotalAmount) {
    final code =
        couponController.text.trim().toUpperCase();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a coupon code',
          ),
        ),
      );

      return;
    }

    if (code == 'DAILY10') {
      if (subtotalAmount < 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'DAILY10 requires minimum order of ₹100',
            ),
          ),
        );

        return;
      }

      setState(() {
        appliedCoupon = code;
        discount = 10;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Coupon applied! ₹10 discount added.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid coupon code',
          ),
        ),
      );
    }
  }

  // =========================
  // PLACE ORDER - BACKEND
  // =========================

  Future<void> placeOrder() async {
    if (items.isEmpty) return;

    setState(() {
      isPlacingOrder = true;
    });

    try {
      // Prepare order items for backend
      final List<Map<String, dynamic>> orderItems = [];

      for (final item in items) {
        final int productId =
            int.tryParse(
                  item['product_id']?.toString() ?? '0',
                ) ??
                0;

        final String productName =
            item['product_name']?.toString() ??
                'Product';

        final String? productImage =
            item['product_image']?.toString();

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

        orderItems.add({
          'product_id': productId,
          'product_name': productName,
          'product_image': productImage,
          'price': price,
          'quantity': quantity,
        });
      }

      // Create order in PostgreSQL through backend
      final result = await ApiService.createOrder(
        userId: userId,
        subtotal: subtotal,
        deliveryCharge:
            deliveryFee.toDouble(),
        tax: tax.toDouble(),
        discount: discount.toDouble(),
        totalAmount:
            finalTotal.toDouble(),
        paymentMethod:
            'Cash on Delivery',
        deliveryAddress:
            '$selectedAddress, $selectedAddressDetails',
        deliveryDate: selectedDate,
        deliverySlot: selectedSlot,
        items: orderItems,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        // Clear old local cart data
        CartData.clearCart();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Order placed successfully!',
            ),
            duration:
                Duration(seconds: 2),
          ),
        );

        // Go back after successful order
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ??
                  'Unable to place order',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to place order',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isPlacingOrder = false;
        });
      }
    }
  }

  // =========================
  // DATE OPTION
  // =========================

  Widget _dateOption({
    required String title,
    required bool selected,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedDate = title;
        });
      },

      borderRadius:
          BorderRadius.circular(12),

      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 16,
        ),

        decoration:
            BoxDecoration(
          color: selected
              ? Colors.teal.shade50
              : Colors.grey.shade100,

          borderRadius:
              BorderRadius.circular(12),

          border: Border.all(
            color: selected
                ? Colors.teal
                : Colors.transparent,
          ),
        ),

        child: Column(
          children: [
            Icon(
              Icons.calendar_today,
              size: 22,
              color: selected
                  ? Colors.teal
                  : Colors.grey,
            ),

            const SizedBox(height: 8),

            Text(
              title,
              textAlign: TextAlign.center,

              style: TextStyle(
                fontWeight:
                    FontWeight.bold,

                color: selected
                    ? Colors.teal
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // SLOT TIME
  // =========================

  String _getSlotTime(String slot) {
    switch (slot) {
      case 'Early Morning':
        return '6:00 AM - 8:00 AM';

      case 'Morning':
        return '8:00 AM - 11:00 AM';

      case 'Afternoon':
        return '12:00 PM - 3:00 PM';

      case 'Evening':
        return '5:00 PM - 8:00 PM';

      default:
        return '';
    }
  }

  // =========================
  // ADDRESS DIALOG
  // =========================

  void _showAddressDialog() {
    final addressController =
        TextEditingController(
      text: selectedAddressDetails,
    );

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delivery Address',
          ),

          content: TextField(
            controller:
                addressController,

            maxLines: 3,

            decoration:
                const InputDecoration(
              hintText:
                  'Enter your delivery address',
              border:
                  OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child:
                  const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                if (addressController
                    .text
                    .trim()
                    .isNotEmpty) {
                  setState(() {
                    selectedAddressDetails =
                        addressController
                            .text
                            .trim();
                  });

                  Navigator.pop(context);
                }
              },

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.teal,
                foregroundColor:
                    Colors.white,
              ),

              child:
                  const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // EMPTY CHECKOUT
  // =========================

  Widget _emptyCheckout() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: primaryColor,
            ),

            const SizedBox(height: 20),

            const Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Please add products to your cart before checkout.',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    primaryColor,
                foregroundColor:
                    Colors.white,
              ),

              child:
                  const Text('Back to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}