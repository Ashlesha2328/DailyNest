import 'package:flutter/material.dart';
import '../wishlist_data.dart';
import '../cart_data.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  static const Color primaryColor = Color(0xFF159A93);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: WishlistData.wishlistVersion,
      builder: (context, value, child) {
        final wishlistItems = WishlistData.items;

        return Scaffold(
          backgroundColor: Colors.white,

          appBar: AppBar(
            title: const Text(
              'My Wishlist',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
          ),

          body: wishlistItems.isEmpty
              ? _emptyWishlist()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: wishlistItems.length,
                  itemBuilder: (context, index) {
                    final item = wishlistItems[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(12),

                        child: Row(
                          children: [
                            // PRODUCT ICON
                            Container(
                              width: 75,
                              height: 75,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F7F5),
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),

                              child: Icon(
                                item.icon as IconData,
                                color: primaryColor,
                                size: 38,
                              ),
                            ),

                            const SizedBox(width: 14),

                            // PRODUCT DETAILS
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    item.category,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),

                                  const SizedBox(height: 3),

                                  Text(
                                    item.productQuantity,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),

                                  const SizedBox(height: 7),

                                  Text(
                                    '₹${item.price}',
                                    style: const TextStyle(
                                      color: primaryColor,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // ACTIONS
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    WishlistData.removeItem(index);

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${item.productName} removed from wishlist',
                                        ),
                                        duration:
                                            const Duration(
                                          seconds: 1,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  ),
                                ),

                                SizedBox(
                                  height: 36,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      CartData.addItem(
                                        productName:
                                            item.productName,
                                        category:
                                            item.category,
                                        productQuantity:
                                            item.productQuantity,
                                        price: item.price,
                                      );

                                      ScaffoldMessenger.of(
                                              context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${item.productName} added to cart',
                                          ),
                                          duration:
                                              const Duration(
                                            seconds: 1,
                                          ),
                                        ),
                                      );
                                    },
                                    style:
                                        ElevatedButton.styleFrom(
                                      backgroundColor:
                                          primaryColor,
                                      foregroundColor:
                                          Colors.white,
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal: 10,
                                      ),
                                      shape:
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(
                                          8,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'ADD',
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
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
        );
      },
    );
  }

  Widget _emptyWishlist() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.teal,
          ),

          SizedBox(height: 20),

          Text(
            'Your wishlist is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Save your favorite products here.',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}