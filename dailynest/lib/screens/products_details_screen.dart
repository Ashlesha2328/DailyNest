import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../subscription_data.dart';
import '../wishlist_data.dart';
import '../cart_data.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int? productId;
  final String productName;
  final String category;
  final String quantity;
  final int price;
  final IconData icon;
  final String imageUrl;

  const ProductDetailsScreen({
    super.key,
    this.productId,
    required this.productName,
    required this.category,
    required this.quantity,
    required this.price,
    required this.icon,
    required this.imageUrl,
  });

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends State<ProductDetailsScreen> {
  int selectedQuantity = 1;
  bool isAddingToCart = false;

  static const Color primaryColor = Color(0xFF159A93);

  // =========================
  // PRODUCT ID
  // =========================

  int generateProductId() {
    return widget.productName.codeUnits.fold(
      0,
      (previous, current) =>
          (previous * 31 + current) & 0x7fffffff,
    );
  }

  // =========================
  // PRODUCT IMAGE
  // =========================

  String get productImage {
    if (widget.imageUrl.trim().isEmpty) {
      return '';
    }

    final image = widget.imageUrl.trim();

    // Full network URL
    if (image.startsWith('http://') ||
        image.startsWith('https://')) {
      return image;
    }

    // Flutter asset path
    if (image.startsWith('assets/')) {
      return image;
    }

    // Only filename is provided
    return 'assets/products/$image';
  }

  // =========================
  // WISHLIST STATUS
  // =========================

  bool get isWishlisted {
    return WishlistData.isWishlisted(
      productName: widget.productName,
      category: widget.category,
    );
  }

  // =========================
  // FINAL PRICE
  // =========================

  int get finalPrice {
    return widget.price * selectedQuantity;
  }

  // =========================
  // ADD TO CART
  // =========================

  Future<void> addProductToCart() async {
    if (isAddingToCart) return;

    setState(() {
      isAddingToCart = true;
    });

    final int productId =
        widget.productId ?? generateProductId();

    try {
      final result = await ApiService.addToCart(
        userId: 2,
        productId: productId,
        productName: widget.productName,
        productImage: productImage,
        price: widget.price.toDouble(),
        quantity: selectedQuantity,
      );

      if (!mounted) return;
      if (result['success'] == true) {
  CartData.addItem(
    productName: widget.productName,
    category: widget.category,
    productQuantity: widget.quantity,
    price: widget.price,
    quantity: selectedQuantity,
  );
}

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] == true
                ? '${widget.productName} added to cart'
                : result['message'] ??
                    'Unable to add to cart',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to connect to server',
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isAddingToCart = false;
        });
      }
    }
  }

  // =========================
  // TOGGLE WISHLIST
  // =========================

  void toggleWishlist() {
    WishlistData.toggleItem(
      productName: widget.productName,
      category: widget.category,
      productQuantity: widget.quantity,
      price: widget.price,
      icon: widget.icon,
    );

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isWishlisted
              ? '${widget.productName} added to wishlist'
              : '${widget.productName} removed from wishlist',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // =========================
  // SUBSCRIBE PRODUCT
  // =========================

  Future<void> subscribeProduct() async {
    String selectedFrequency = 'Daily';

    DateTime selectedDate =
        DateTime.now().add(
      const Duration(days: 1),
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Subscription Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // =========================
                    // FREQUENCY
                    // =========================

                    const Text(
                      'Delivery Frequency',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      initialValue:
                          selectedFrequency,

                      decoration: InputDecoration(
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),

                      items: const [
                        DropdownMenuItem(
                          value: 'Daily',
                          child: Text('Daily'),
                        ),
                        DropdownMenuItem(
                          value: 'Alternate Days',
                          child: Text(
                            'Alternate Days',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Weekly',
                          child: Text('Weekly'),
                        ),
                        DropdownMenuItem(
                          value: 'Monthly',
                          child: Text('Monthly'),
                        ),
                      ],

                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedFrequency =
                                value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // NEXT DELIVERY DATE
                    // =========================

                    const Text(
                      'Next Delivery Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 8),

                    InkWell(
                      borderRadius:
                          BorderRadius.circular(10),

                      onTap: () async {
                        final pickedDate =
                            await showDatePicker(
                          context: context,

                          initialDate:
                              selectedDate,

                          firstDate:
                              DateTime.now(),

                          lastDate:
                              DateTime.now().add(
                            const Duration(
                              days: 365,
                            ),
                          ),
                        );

                        if (pickedDate != null) {
                          setDialogState(() {
                            selectedDate =
                                pickedDate;
                          });
                        }
                      },

                      child: Container(
                        width: double.infinity,

                        padding:
                            const EdgeInsets.all(
                          14,
                        ),

                        decoration:
                            BoxDecoration(
                          border: Border.all(
                            color: Colors
                                .grey
                                .shade300,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),

                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: primaryColor,
                              size: 20,
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child: Text(
                                '${selectedDate.day}/'
                                '${selectedDate.month}/'
                                '${selectedDate.year}',

                                style:
                                    const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            const Icon(
                              Icons
                                  .keyboard_arrow_down,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Frequency: $selectedFrequency',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                // =========================
                // CANCEL
                // =========================

                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      false,
                    );
                  },

                  child: const Text(
                    'Cancel',
                  ),
                ),

                // =========================
                // CONFIRM
                // =========================

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  },

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        primaryColor,
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        8,
                      ),
                    ),
                  ),

                  child: const Text(
                    'Confirm Subscription',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    // User cancelled
    if (result != true) return;

    // =========================
    // SAVE SUBSCRIPTION
    // =========================

    SubscriptionData.addSubscription(
      productName: widget.productName,
      category: widget.category,
      productQuantity: widget.quantity,
      price: widget.price,
      quantity: selectedQuantity,
      frequency: selectedFrequency,
      nextDeliveryDate: selectedDate,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.productName} subscribed successfully',
        ),
        duration:
            const Duration(seconds: 2),
      ),
    );
  }

  // =========================
  // PRODUCT IMAGE WIDGET
  // =========================

  Widget buildProductImage() {
    // Network image
    if (productImage.startsWith('http://') ||
        productImage.startsWith('https://')) {
      return Image.network(
        productImage,
        fit: BoxFit.contain,

        loadingBuilder:
            (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return const Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          );
        },

        errorBuilder:
            (context, error, stackTrace) {
          return Icon(
            widget.icon,
            size: 120,
            color: primaryColor,
          );
        },
      );
    }

    // Local asset image
    if (productImage.isNotEmpty) {
      return Image.asset(
        productImage,
        fit: BoxFit.contain,

        errorBuilder:
            (context, error, stackTrace) {
          return Icon(
            widget.icon,
            size: 120,
            color: primaryColor,
          );
        },
      );
    }

    // Fallback icon
    return Icon(
      widget.icon,
      size: 120,
      color: primaryColor,
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // =========================
      // APP BAR
      // =========================

      appBar: AppBar(
        title: const Text(
          'Product Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,

        actions: [
          IconButton(
            onPressed: toggleWishlist,

            icon: Icon(
              isWishlisted
                  ? Icons.favorite
                  : Icons.favorite_border,

              color: isWishlisted
                  ? Colors.red
                  : Colors.black87,
            ),
          ),
        ],
      ),

      // =========================
      // BODY
      // =========================

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // =========================
            // PRODUCT IMAGE
            // =========================

            Container(
              width: double.infinity,
              height: 300,

              margin:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color:
                    const Color(0xFFE8F7F5),

                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(20),

                child: buildProductImage(),
              ),
            ),

            // =========================
            // PRODUCT INFORMATION
            // =========================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // CATEGORY

                  Text(
                    widget.category,

                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // PRODUCT NAME

                  Text(
                    widget.productName,

                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // PRODUCT QUANTITY

                  Text(
                    widget.quantity,

                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // =========================
                  // PRICE
                  // =========================

                  Row(
                    children: [
                      Text(
                        '₹${widget.price}',

                        style:
                            const TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              primaryColor,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Text(
                        'MRP ₹${widget.price + 10}',

                        style:
                            const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          decoration:
                              TextDecoration
                                  .lineThrough,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // =========================
                  // QUANTITY
                  // =========================

                  const Text(
                    'Quantity',

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Container(
                        decoration:
                            BoxDecoration(
                          border: Border.all(
                            color: Colors
                                .grey
                                .shade300,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),

                        child: Row(
                          children: [
                            // MINUS

                            IconButton(
                              onPressed:
                                  selectedQuantity >
                                          1
                                      ? () {
                                          setState(
                                            () {
                                              selectedQuantity--;
                                            },
                                          );
                                        }
                                      : null,

                              icon: const Icon(
                                Icons.remove,
                              ),
                            ),

                            // QUANTITY

                            Text(
                              '$selectedQuantity',

                              style:
                                  const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            // PLUS

                            IconButton(
                              onPressed: () {
                                setState(() {
                                  selectedQuantity++;
                                });
                              },

                              icon: const Icon(
                                Icons.add,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 20),

                      Text(
                        '₹$finalPrice',

                        style:
                            const TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // =========================
                  // DESCRIPTION
                  // =========================

                  const Text(
                    'Product Description',

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Fresh and high-quality '
                    '${widget.productName}. '
                    'Perfect for your daily needs. '
                    'Order now and get it delivered '
                    'to your doorstep.',

                    style:
                        const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // =========================
                  // ADD TO CART
                  // =========================

                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: ElevatedButton(
                      onPressed:
                          isAddingToCart
                              ? null
                              : addProductToCart,

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            primaryColor,

                        foregroundColor:
                            Colors.white,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),

                      child: isAddingToCart
                          ? const SizedBox(
                              height: 24,
                              width: 24,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    Colors.white,
                              ),
                            )
                          : const Text(
                              'Add to Cart',

                              style:
                                  TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // =========================
                  // SUBSCRIBE
                  // =========================

                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: OutlinedButton(
                      onPressed:
                          subscribeProduct,

                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            primaryColor,

                        side:
                            const BorderSide(
                          color: primaryColor,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),

                      child: const Text(
                        'Subscribe',

                        style:
                            TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}