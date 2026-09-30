import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const Color primaryColor = Color(0xFF159A93);

  // Testing user ID
  final int userId = 2;

  List<dynamic> items = [];
  double totalAmount = 0;

  bool isLoading = true;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    loadCart();
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
        setState(() {
          items = result['cart'] ?? [];

          totalAmount =
              double.tryParse(
                    result['total']?.toString() ?? '0',
                  ) ??
                  0;
        });
      } else {
        setState(() {
          items = [];
          totalAmount = 0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ??
                  'Unable to load cart',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        items = [];
        totalAmount = 0;
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
  // UPDATE QUANTITY
  // =========================

  Future<void> updateQuantity(
    int cartItemId,
    int quantity,
  ) async {
    if (quantity < 1) {
      await deleteItem(cartItemId);
      return;
    }

    if (isUpdating) return;

    setState(() {
      isUpdating = true;
    });

    try {
      final result =
          await ApiService.updateCartQuantity(
        cartItemId: cartItemId,
        quantity: quantity,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        await loadCart();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ??
                  'Unable to update quantity',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

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
          isUpdating = false;
        });
      }
    }
  }

  // =========================
  // DELETE CART ITEM
  // =========================

  Future<void> deleteItem(int cartItemId) async {
    try {
      final result =
          await ApiService.deleteCartItem(
        cartItemId: cartItemId,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        await loadCart();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Product removed from cart',
            ),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ??
                  'Unable to remove product',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to connect to server',
          ),
        ),
      );
    }
  }

  // =========================
  // PRODUCT IMAGE
  // =========================

  Widget buildProductImage(String? image) {
    if (image == null || image.isEmpty) {
      return const Icon(
        Icons.shopping_basket_outlined,
        size: 35,
        color: primaryColor,
      );
    }

    String imagePath = image;

    if (!imagePath.startsWith('assets/')) {
      imagePath = 'assets/products/$imagePath';
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.asset(
        imagePath,
        width: 70,
        height: 70,
        fit: BoxFit.contain,
        errorBuilder:
            (context, error, stackTrace) {
          return const Icon(
            Icons.shopping_basket_outlined,
            size: 35,
            color: primaryColor,
          );
        },
      ),
    );
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
          'My Cart',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,

        actions: [
          IconButton(
            onPressed: loadCart,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      // =========================
      // BODY
      // =========================

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : items.isEmpty
              ? _emptyCart()
              : Column(
                  children: [

                    // =========================
                    // CART ITEMS
                    // =========================

                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: loadCart,

                        child: ListView.builder(
                          padding:
                              const EdgeInsets.all(16),
                          itemCount: items.length,

                          itemBuilder:
                              (context, index) {
                            final item =
                                items[index];

                            final int cartItemId =
                                int.tryParse(
                                      item['id']
                                              ?.toString() ??
                                          '0',
                                    ) ??
                                    0;

                            final String productName =
                                item['product_name']
                                        ?.toString() ??
                                    'Product';

                            final String productImage =
                                item['product_image']
                                        ?.toString() ??
                                    '';

                            final double price =
                                double.tryParse(
                                      item['price']
                                              ?.toString() ??
                                          '0',
                                    ) ??
                                    0;

                            final int quantity =
                                int.tryParse(
                                      item['quantity']
                                              ?.toString() ??
                                          '1',
                                    ) ??
                                    1;

                            final double itemTotal =
                                price * quantity;

                            return Card(
                              margin:
                                  const EdgeInsets.only(
                                bottom: 12,
                              ),

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
                                    const EdgeInsets.all(
                                  16,
                                ),

                                child: Row(
                                  children: [

                                    // =========================
                                    // IMAGE
                                    // =========================

                                    Container(
                                      height: 70,
                                      width: 70,

                                      decoration:
                                          BoxDecoration(
                                        color:
                                            const Color(
                                          0xFFE8F7F5,
                                        ),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          14,
                                        ),
                                      ),

                                      child: buildProductImage(
                                        productImage,
                                      ),
                                    ),

                                    const SizedBox(
                                      width: 14,
                                    ),

                                    // =========================
                                    // DETAILS
                                    // =========================

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,

                                        children: [

                                          Text(
                                            productName,
                                            maxLines: 2,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,

                                            style:
                                                const TextStyle(
                                              fontSize: 17,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                          ),

                                          const SizedBox(
                                            height: 6,
                                          ),

                                          Text(
                                            '₹${price.toStringAsFixed(0)}',
                                            style:
                                                const TextStyle(
                                              fontSize: 16,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              color:
                                                  primaryColor,
                                            ),
                                          ),

                                          const SizedBox(
                                            height: 10,
                                          ),

                                          // =========================
                                          // QUANTITY
                                          // =========================

                                          Container(
                                            decoration:
                                                BoxDecoration(
                                              color: Colors
                                                  .teal
                                                  .shade50,
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                10,
                                              ),
                                            ),

                                            child: Row(
                                              mainAxisSize:
                                                  MainAxisSize
                                                      .min,

                                              children: [

                                                IconButton(
                                                  onPressed:
                                                      isUpdating
                                                          ? null
                                                          : () {
                                                              updateQuantity(
                                                                cartItemId,
                                                                quantity -
                                                                    1,
                                                              );
                                                            },

                                                  icon:
                                                      const Icon(
                                                    Icons
                                                        .remove,
                                                    color:
                                                        Colors
                                                            .teal,
                                                  ),
                                                ),

                                                Text(
                                                  '$quantity',
                                                  style:
                                                      const TextStyle(
                                                    fontSize:
                                                        16,
                                                    fontWeight:
                                                        FontWeight
                                                            .bold,
                                                  ),
                                                ),

                                                IconButton(
                                                  onPressed:
                                                      isUpdating
                                                          ? null
                                                          : () {
                                                              updateQuantity(
                                                                cartItemId,
                                                                quantity +
                                                                    1,
                                                              );
                                                            },

                                                  icon:
                                                      const Icon(
                                                    Icons
                                                        .add,
                                                    color:
                                                        Colors
                                                            .teal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(
                                      width: 8,
                                    ),

                                    // =========================
                                    // RIGHT SIDE
                                    // =========================

                                    Column(
                                      children: [

                                        IconButton(
                                          onPressed:
                                              isUpdating
                                                  ? null
                                                  : () {
                                                      deleteItem(
                                                        cartItemId,
                                                      );
                                                    },

                                          icon:
                                              const Icon(
                                            Icons
                                                .delete_outline,
                                            color:
                                                Colors.red,
                                          ),
                                        ),

                                        const SizedBox(
                                          height: 8,
                                        ),

                                        Text(
                                          '₹${itemTotal.toStringAsFixed(0)}',

                                          style:
                                              const TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                            color:
                                                primaryColor,
                                          ),
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
                    ),

                    // =========================
                    // BOTTOM SUMMARY
                    // =========================

                    Container(
                      padding:
                          const EdgeInsets.fromLTRB(
                        20,
                        16,
                        20,
                        20,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.08),
                            blurRadius: 10,
                            offset:
                                const Offset(0, -3),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [

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
                                '₹${totalAmount.toStringAsFixed(0)}',

                                style:
                                    const TextStyle(
                                  fontSize: 22,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      primaryColor,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          SizedBox(
                            width: double.infinity,
                            height: 52,

                            child:
                                ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const CheckoutScreen(),
                                  ),
                                );
                              },

                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    primaryColor,
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

                              child: const Text(
                                'Proceed to Checkout',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  // =========================
  // EMPTY CART
  // =========================

  Widget _emptyCart() {
    return RefreshIndicator(
      onRefresh: loadCart,

      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),

        children: const [
          SizedBox(
            height: 180,
          ),

          Center(
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 90,
              color: primaryColor,
            ),
          ),

          SizedBox(
            height: 20,
          ),

          Center(
            child: Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SizedBox(
            height: 8,
          ),

          Center(
            child: Text(
              'Add products to see them here.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}