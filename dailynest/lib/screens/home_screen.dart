import 'package:flutter/material.dart';

import '../cart_data.dart';
import '../wishlist_data.dart';
import '../services/api_service.dart';
import 'products_details_screen.dart';
import 'products_screen.dart';
import 'wishlist_screen.dart';
import 'saved_addresses_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color primaryColor = Color(0xFF159A93);

  final TextEditingController searchController =
      TextEditingController();

  String searchText = '';

  // =========================
  // PRODUCTS
  // =========================

  final List<Map<String, dynamic>> products = [
    {
      'name': 'Fresh Milk',
      'category': 'Milk & Dairy',
      'quantity': '1 L',
      'price': 60,
      'icon': Icons.local_drink,
      'imageUrl':
          'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=500',
    },
    {
      'name': 'Brown Bread',
      'category': 'Bakery',
      'quantity': '400 g',
      'price': 45,
      'icon': Icons.bakery_dining,
      'imageUrl':
          'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=500',
    },
    {
      'name': 'Fresh Apples',
      'category': 'Fruits',
      'quantity': '1 kg',
      'price': 120,
      'icon': Icons.apple,
      'imageUrl':
          'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500',
    },
    {
      'name': 'Eggs',
      'category': 'Grocery',
      'quantity': '12 pcs',
      'price': 90,
      'icon': Icons.egg,
      'imageUrl':
          'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=500',
    },
  ];

  // =========================
  // CATEGORIES
  // =========================

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Milk',
      'icon': Icons.local_drink,
      'imageUrl':
          'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300',
    },
    {
      'name': 'Fruits',
      'icon': Icons.eco,
      'imageUrl':
          'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=300',
    },
    {
      'name': 'Grocery',
      'icon': Icons.shopping_basket,
      'imageUrl':
          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=300',
    },
    {
      'name': 'Bakery',
      'icon': Icons.bakery_dining,
      'imageUrl':
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=300',
    },
    {
      'name': 'Beverages',
      'icon': Icons.local_cafe,
      'imageUrl':
          'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=300',
    },
    {
      'name': 'Household',
      'icon': Icons.cleaning_services,
      'imageUrl':
          'https://images.unsplash.com/photo-1583947215259-38e31be8751f?w=300',
    },
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // =========================
  // FILTER PRODUCTS
  // =========================

  List<Map<String, dynamic>> get filteredProducts {
    if (searchText.trim().isEmpty) {
      return products;
    }

    final query = searchText.toLowerCase().trim();

    return products.where((product) {
      final name =
          product['name'].toString().toLowerCase();

      final category =
          product['category'].toString().toLowerCase();

      return name.contains(query) ||
          category.contains(query);
    }).toList();
  }

  // =========================
  // DELIVERY ADDRESS
  // =========================

  void openDeliveryAddress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const SavedAddressesScreen(),
      ),
    );
  }

  // =========================
  // WISHLIST CHECK
  // =========================

  bool isProductWishlisted(
    String productName,
  ) {
    return WishlistData.items.any(
      (item) =>
          item.productName == productName,
    );
  }

  // =========================
  // TOGGLE WISHLIST
  // =========================

  void toggleWishlist(
    BuildContext context,
    Map<String, dynamic> product,
  ) {
    final String productName =
        product['name'].toString();

    final int existingIndex =
        WishlistData.items.indexWhere(
      (item) =>
          item.productName == productName,
    );

    // =========================
    // REMOVE
    // =========================

    if (existingIndex != -1) {
      WishlistData.removeItem(
        existingIndex,
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '$productName removed from wishlist',
          ),
          duration:
              const Duration(seconds: 1),
        ),
      );

      setState(() {});
      return;
    }

    // =========================
    // ADD
    // =========================

    WishlistData.addItem(
      productName: productName,
      category: product['category'].toString(),
      productQuantity:
          product['quantity'].toString(),
      price:
          (product['price'] as num).toInt(),
      icon:
          product['icon'] as IconData,
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          '$productName added to wishlist',
        ),
        duration:
            const Duration(seconds: 1),
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DailyNest',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // =========================
          // WISHLIST
          // =========================

          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const WishlistScreen(),
                ),
              ).then((_) {
                if (mounted) {
                  setState(() {});
                }
              });
            },
            icon: const Icon(
              Icons.favorite_border,
              color: Colors.red,
            ),
          ),

          // =========================
          // NOTIFICATION
          // =========================

          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content:
                      Text('No new notifications'),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_outlined,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // =========================
            // DELIVERY LOCATION
            // =========================

            InkWell(
              onTap: openDeliveryAddress,
              borderRadius:
                  BorderRadius.circular(12),

              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 4,
                ),

                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.teal,
                    ),

                    const SizedBox(width: 8),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deliver to',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Colors.grey,
                            ),
                          ),
                          Text(
                            'Pune, Maharashtra',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed:
                          openDeliveryAddress,
                      icon: const Icon(
                        Icons
                            .keyboard_arrow_down,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // =========================
            // SEARCH
            // =========================

            TextField(
              controller:
                  searchController,

              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },

              decoration:
                  InputDecoration(
                hintText:
                    'Search for milk, fruits, groceries...',

                prefixIcon:
                    const Icon(Icons.search),

                suffixIcon:
                    searchText.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController
                                  .clear();

                              setState(() {
                                searchText =
                                    '';
                              });
                            },
                            icon: const Icon(
                              Icons.clear,
                            ),
                          )
                        : null,

                filled: true,

                fillColor:
                    Colors.grey.shade100,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // SEARCH RESULTS
            // =========================

            if (searchText.isNotEmpty) ...[
              const Text(
                'Search Results',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              if (searchResults.isEmpty)
                const Padding(
                  padding:
                      EdgeInsets.symmetric(
                    vertical: 30,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 60,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 12),

                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'Try searching for another product.',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    for (final product
                        in searchResults)
                      Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          bottom: 12,
                        ),
                        child:
                            _searchProductCard(
                          context,
                          product,
                        ),
                      ),
                  ],
                ),

              const SizedBox(height: 10),
            ],

            // =========================
            // HOME CONTENT
            // =========================

            if (searchText.isEmpty) ...[
              // =========================
              // PROMOTIONAL BANNER
              // =========================

              Container(
                width:
                    double.infinity,
                height: 190,

                decoration:
                    BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                  image:
                      const DecorationImage(
                    image:
                        NetworkImage(
                      'https://images.unsplash.com/photo-1542838132-92c53300491e?w=1000',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),

                child: Container(
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),

                  decoration:
                      BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                    gradient:
                        LinearGradient(
                      begin: Alignment
                          .centerLeft,
                      end: Alignment
                          .centerRight,
                      colors: [
                        Colors.black
                            .withOpacity(
                          0.65,
                        ),
                        Colors.black
                            .withOpacity(
                          0.15,
                        ),
                      ],
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                    children: [
                      const Text(
                        'Fresh & Fast Delivery',
                        style: TextStyle(
                          color:
                              Colors.white,
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                          height: 8),

                      const Text(
                        'Your daily essentials delivered to your doorstep.',
                        style: TextStyle(
                          color:
                              Colors.white,
                        ),
                      ),

                      const SizedBox(
                          height: 14),

                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      const ProductsScreen(
                                categoryName:
                                    'Grocery',
                              ),
                            ),
                          );
                        },
                        child:
                            const Text(
                          'Shop Now →',
                          style:
                              TextStyle(
                            color:
                                Colors.white,
                            fontWeight:
                                FontWeight
                                    .bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                  height: 28),

              // =========================
              // CATEGORIES
              // =========================

              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                  height: 16),

              SizedBox(
                height: 120,

                child:
                    ListView.builder(
                  scrollDirection:
                      Axis.horizontal,

                  itemCount:
                      categories.length,

                  itemBuilder:
                      (context, index) {
                    final category =
                        categories[index];

                    return categoryItem(
                      context,
                      category['icon'],
                      category['name'],
                      category['imageUrl'],
                    );
                  },
                ),
              ),

              const SizedBox(
                  height: 28),

              // =========================
              // TODAY'S DEALS
              // =========================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [
                  const Text(
                    "Today's Deals",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Showing all deals',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'View All',
                    ),
                  ),
                ],
              ),

              const SizedBox(
                  height: 12),

              // =========================
              // FIRST ROW
              // =========================

              Row(
                children: [
                  Expanded(
                    child: productCard(
                      context,
                      products[0],
                    ),
                  ),

                  const SizedBox(
                      width: 12),

                  Expanded(
                    child: productCard(
                      context,
                      products[1],
                    ),
                  ),
                ],
              ),

              const SizedBox(
                  height: 16),

              // =========================
              // SECOND ROW
              // =========================

              Row(
                children: [
                  Expanded(
                    child: productCard(
                      context,
                      products[2],
                    ),
                  ),

                  const SizedBox(
                      width: 12),

                  Expanded(
                    child: productCard(
                      context,
                      products[3],
                    ),
                  ),
                ],
              ),

              const SizedBox(
                  height: 30),

              // =========================
              // SUBSCRIPTION
              // =========================

              InkWell(
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),

                onTap: () {
                  ScaffoldMessenger.of(
                          context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Subscription feature selected',
                      ),
                    ),
                  );
                },

                child: Container(
                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets.all(
                    18,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.teal.shade50,
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),

                  child: const Row(
                    children: [
                      Icon(
                        Icons.repeat,
                        size: 35,
                        color:
                            Colors.teal,
                      ),

                      SizedBox(
                          width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            Text(
                              'Daily Essentials Subscription',
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                                fontSize: 16,
                              ),
                            ),

                            SizedBox(
                                height: 5),

                            Text(
                              'Get your regular products delivered automatically.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                  height: 20),
            ],
          ],
        ),
      ),
    );
  }

  // =========================================================
  // SEARCH PRODUCT CARD
  // =========================================================

  Widget _searchProductCard(
    BuildContext context,
    Map<String, dynamic> product,
  ) {
    return Card(
      elevation: 2,

      child: ListTile(
        contentPadding:
            const EdgeInsets.all(12),

        leading: Container(
          width: 55,
          height: 55,

          decoration:
              BoxDecoration(
            color:
                Colors.teal.shade50,
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),

          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(
              12,
            ),

            child: Image.network(
              product['imageUrl'],
              fit: BoxFit.cover,

              errorBuilder:
                  (
                context,
                error,
                stackTrace,
              ) {
                return Icon(
                  product['icon'],
                  color:
                      Colors.teal,
                  size: 30,
                );
              },
            ),
          ),
        ),

        title: Text(
          product['name'],
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        subtitle: Text(
          '${product['category']} • ${product['quantity']}',
        ),

        trailing: Text(
          '₹${product['price']}',
          style:
              const TextStyle(
            color: Colors.teal,
            fontWeight:
                FontWeight.bold,
            fontSize: 16,
          ),
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProductDetailsScreen(
                productName:
                    product['name'],
                category:
                    product['category'],
                quantity:
                    product['quantity'],
                price:
                    product['price'],
                icon:
                    product['icon'],
                imageUrl:
                    product['imageUrl'],
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // CATEGORY ITEM
  // =========================================================

  static Widget categoryItem(
    BuildContext context,
    IconData icon,
    String name,
    String imageUrl,
  ) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(16),

      onTap: () {
        String categoryName;

        switch (name) {
          case 'Milk':
            categoryName =
                'Milk & Dairy';
            break;

          case 'Fruits':
            categoryName = 'Fruits';
            break;

          case 'Grocery':
            categoryName = 'Grocery';
            break;

          case 'Bakery':
            categoryName = 'Bakery';
            break;

          case 'Beverages':
            categoryName =
                'Beverages';
            break;

          case 'Household':
            categoryName =
                'Household';
            break;

          default:
            categoryName = name;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductsScreen(
              categoryName:
                  categoryName,
            ),
          ),
        );
      },

      child: Container(
        width: 82,

        margin:
            const EdgeInsets.only(
          right: 12,
        ),

        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,

              decoration:
                  BoxDecoration(
                color:
                    Colors.teal.shade50,
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),

              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),

                child:
                    Image.network(
                  imageUrl,
                  fit: BoxFit.cover,

                  errorBuilder:
                      (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Icon(
                      icon,
                      color:
                          Colors.teal,
                      size: 30,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(
                height: 7),

            Text(
              name,
              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // PRODUCT CARD
  // =========================================================

  Widget productCard(
    BuildContext context,
    Map<String, dynamic> product,
  ) {
    return Card(
      elevation: 2,

      clipBehavior:
          Clip.antiAlias,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),

      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          12,
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProductDetailsScreen(
                productName:
                    product['name'],
                category:
                    product['category'],
                quantity:
                    product['quantity'],
                price:
                    product['price'],
                icon:
                    product['icon'],
                imageUrl:
                    product['imageUrl'],
              ),
            ),
          );
        },

        child: Padding(
          padding:
              const EdgeInsets.all(
            12,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [
              // =================================================
              // PRODUCT IMAGE + WISHLIST
              // =================================================

              Stack(
                children: [
                  Container(
                    height: 150,
                    width:
                        double.infinity,

                    decoration:
                        BoxDecoration(
                      color: Colors
                          .grey
                          .shade100,

                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),

                    child:
                        ClipRRect(
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),

                      child:
                          Image.network(
                        product[
                            'imageUrl'],
                        fit: BoxFit
                            .contain,

                        errorBuilder:
                            (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return Icon(
                            product[
                                'icon'],
                            size: 55,
                            color:
                                Colors.teal,
                          );
                        },
                      ),
                    ),
                  ),

                  // =================================================
                  // WISHLIST BUTTON
                  // =================================================

                  Positioned(
                    top: 8,
                    right: 8,

                    child:
                        ValueListenableBuilder<
                            int>(
                      valueListenable:
                          WishlistData
                              .wishlistVersion,

                      builder:
                          (
                        context,
                        value,
                        child,
                      ) {
                        final bool
                            isWishlisted =
                            isProductWishlisted(
                          product[
                              'name']
                              .toString(),
                        );

                        return Material(
                          color: Colors
                              .white
                              .withOpacity(
                            0.95,
                          ),

                          shape:
                              const CircleBorder(),

                          elevation: 2,

                          child:
                              InkWell(
                            customBorder:
                                const CircleBorder(),

                            onTap: () {
                              toggleWishlist(
                                context,
                                product,
                              );
                            },

                            child:
                                Padding(
                              padding:
                                  const EdgeInsets
                                      .all(
                                8,
                              ),

                              child:
                                  Icon(
                                isWishlisted
                                    ? Icons
                                        .favorite
                                    : Icons
                                        .favorite_border,

                                color:
                                    isWishlisted
                                        ? Colors
                                            .red
                                        : Colors
                                            .grey
                                            .shade700,

                                size: 23,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(
                  height: 10),

              // =================================================
              // PRODUCT NAME
              // =================================================

              Text(
                product['name'],
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,

                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                  height: 4),

              // =================================================
              // QUANTITY
              // =================================================

              Text(
                product['quantity'],
                style:
                    const TextStyle(
                  color:
                      Colors.grey,
                ),
              ),

              const SizedBox(
                  height: 8),

              // =================================================
              // PRICE + ADD BUTTON
              // =================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [
                  // PRICE

                  Text(
                    '₹${product['price']}',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  // ADD BUTTON

                  InkWell(
                    borderRadius:
                        BorderRadius
                            .circular(
                      8,
                    ),

                    onTap: () async {
                      try {
                        // -------------------------
                        // PRODUCT ID
                        // -------------------------

                        final int
                            productId =
                            product['name']
                                .toString()
                                .codeUnits
                                .fold(
                                  0,
                                  (
                                    previous,
                                    current,
                                  ) =>
                                      (previous *
                                                  31 +
                                              current) &
                                          0x7fffffff,
                                );

                        // -------------------------
                        // ADD TO BACKEND
                        // -------------------------

                        final result =
                            await ApiService
                                .addToCart(
                          userId: 2,
                          productId:
                              productId,
                          productName:
                              product[
                                  'name'],
                          productImage:
                              product[
                                  'imageUrl'],
                          price:
                              (product[
                                      'price'] as num)
                                  .toDouble(),
                          quantity: 1,
                        );

                        if (!context
                            .mounted) {
                          return;
                        }

                        // -------------------------
                        // LOCAL CART
                        // -------------------------

                        if (result[
                                'success'] ==
                            true) {
                          CartData.addItem(
                            productName:
                                product[
                                    'name'],
                            category:
                                product[
                                    'category'],
                            productQuantity:
                                product[
                                    'quantity'],
                            price:
                                (product[
                                        'price'] as num)
                                    .toInt(),
                            quantity: 1,
                          );
                        }

                        // -------------------------
                        // MESSAGE
                        // -------------------------

                        ScaffoldMessenger.of(
                                context)
                            .showSnackBar(
                          SnackBar(
                            content:
                                Text(
                              result['success'] ==
                                      true
                                  ? '${product['name']} added to cart'
                                  : result[
                                          'message'] ??
                                      'Unable to add to cart',
                            ),
                            duration:
                                const Duration(
                              seconds: 2,
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!context
                            .mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(
                                context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Unable to connect to server',
                            ),
                            duration:
                                Duration(
                              seconds: 2,
                            ),
                          ),
                        );
                      }
                    },

                    child:
                        Container(
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.teal,

                        borderRadius:
                            BorderRadius
                                .circular(
                          8,
                        ),
                      ),

                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),

                      child:
                          const Text(
                        'ADD',
                        style:
                            TextStyle(
                          color:
                              Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}