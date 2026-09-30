import 'package:flutter/material.dart';

import 'products_details_screen.dart';
import '../services/api_service.dart';
import '../cart_data.dart';
import '../wishlist_data.dart';

class ProductsScreen extends StatefulWidget {
  final String categoryName;

  const ProductsScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  static const Color primaryColor = Color(0xFF159A93);

  final TextEditingController searchController =
      TextEditingController();

  String searchText = '';
  String sortOption = 'Default';

  double minPrice = 0;
  double maxPrice = 500;

  List<Map<String, dynamic>> allProducts = [];

  bool isLoading = true;
  String errorMessage = '';

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  // =========================================================
  // LOAD PRODUCTS
  // =========================================================

  Future<void> loadProducts() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
    }

    final result = await ApiService.getAllProducts();

    if (!mounted) return;

    if (result['success'] == true) {
      final List<dynamic> data =
          result['products'] ?? [];

      final List<Map<String, dynamic>> loadedProducts = [];

      for (final item in data) {
        final product =
            Map<String, dynamic>.from(item);

        final int productId =
            int.tryParse(
                  product['id'].toString(),
                ) ??
                0;

        final String name =
            product['name']?.toString() ?? '';

        final String category =
            product['category']?.toString() ?? '';

        final String brand =
            product['brand']?.toString() ?? '';

        final String description =
            product['description']?.toString() ?? '';

        final String sku =
            product['sku']?.toString() ?? '';

        final double price =
            double.tryParse(
                  product['price'].toString(),
                ) ??
                0;

        final double mrp =
            double.tryParse(
                  product['mrp'].toString(),
                ) ??
                0;

        final double discount =
            double.tryParse(
                  product['discount'].toString(),
                ) ??
                0;

        final int stock =
            int.tryParse(
                  product['stock'].toString(),
                ) ??
                0;

        // =====================================================
        // IMAGE URL
        // =====================================================

        final String imageUrl =
            product['image_url']
                    ?.toString()
                    .trim() ??
                '';

        // =====================================================
        // LOCAL PRODUCT IMAGE
        // =====================================================

        final String localImage =
            getLocalProductImage(name);

        // =====================================================
        // FIX IMAGE PATH
        // =====================================================

        String displayImage = '';

        if (imageUrl.isNotEmpty) {
          String cleanedImageUrl =
              imageUrl;

          // Case 1:
          // assets/products/http://...
          if (cleanedImageUrl.startsWith(
            'assets/products/http://',
          )) {
            cleanedImageUrl =
                cleanedImageUrl.substring(
              'assets/products/'.length,
            );
          }

          // Case 2:
          // assets/products/https://...
          if (cleanedImageUrl.startsWith(
            'assets/products/https://',
          )) {
            cleanedImageUrl =
                cleanedImageUrl.substring(
              'assets/products/'.length,
            );
          }

          // Case 3:
          // Direct network URL
          if (cleanedImageUrl.startsWith(
                'http://',
              ) ||
              cleanedImageUrl.startsWith(
                'https://',
              )) {
            displayImage =
                cleanedImageUrl;
          }

          // Case 4:
          // Normal local asset
          else if (cleanedImageUrl.startsWith(
            'assets/',
          )) {
            displayImage =
                cleanedImageUrl;
          }

          // Case 5:
          // Only filename is stored
          else if (cleanedImageUrl.isNotEmpty) {
            displayImage =
                'assets/products/$cleanedImageUrl';
          }
        }

        // =====================================================
        // FALLBACK TO LOCAL IMAGE
        // =====================================================

        if (displayImage.isEmpty) {
          displayImage = localImage;
        }

        // =====================================================
        // OTHER PRODUCT DATA
        // =====================================================

        final bool isAvailable =
            product['is_available'] == true;

        final bool isSubscriptionEligible =
            product[
                    'is_subscription_eligible'] ==
                true;

        // =====================================================
        // ADD PRODUCT
        // =====================================================

        loadedProducts.add({
          'id': productId,
          'name': name,
          'description': description,
          'category': category,
          'brand': brand,
          'sku': sku,
          'quantity':
              getProductQuantity(name),
          'price': price,
          'mrp': mrp,
          'discount': discount,
          'stock': stock,
          'image': displayImage,
          'icon': Icons.shopping_basket,
          'isAvailable': isAvailable,
          'isSubscriptionEligible':
              isSubscriptionEligible,
        });
      }

      setState(() {
        allProducts = loadedProducts;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        errorMessage =
            result['message']?.toString() ??
                'Unable to load products';
      });
    }
  }

  // =========================================================
  // LOCAL PRODUCT IMAGES
  // =========================================================

  String getLocalProductImage(String productName) {
    switch (productName) {
      // MILK & DAIRY
      case 'Fresh Milk':
        return 'assets/products/fresh_milk.png';

      case 'Curd':
        return 'assets/products/curd.png';

      case 'Paneer':
        return 'assets/products/paneer.png';

      case 'Butter':
        return 'assets/products/butter.png';

      // FRUITS
      case 'Fresh Apples':
        return 'assets/products/apple.png';

      case 'Bananas':
        return 'assets/products/banana.png';

      case 'Oranges':
        return 'assets/products/orange.png';

      case 'Mangoes':
        return 'assets/products/mango.png';

      // VEGETABLES
      case 'Potatoes':
        return 'assets/products/potato.png';

      case 'Tomatoes':
        return 'assets/products/tomato.png';

      case 'Onions':
        return 'assets/products/onion.png';

      case 'Carrots':
        return 'assets/products/carrot.png';

      // GROCERY
      case 'Rice':
        return 'assets/products/rice.png';

      case 'Wheat Flour':
        return 'assets/products/wheat_flour.png';

      case 'Toor Dal':
        return 'assets/products/toor_dal.png';

      case 'Cooking Oil':
        return 'assets/products/cooking_oil.png';

      // BAKERY
      case 'Brown Bread':
        return 'assets/products/brown_bread.png';

      case 'White Bread':
        return 'assets/products/white_bread.png';

      case 'Burger Buns':
        return 'assets/products/burger_buns.png';

      case 'Cookies':
        return 'assets/products/cookies.png';

      // BEVERAGES
      case 'Tea':
        return 'assets/products/tea.png';

      case 'Coffee':
        return 'assets/products/coffee.png';

      case 'Orange Juice':
        return 'assets/products/orange_juice.png';

      case 'Green Tea':
        return 'assets/products/green_tea.png';

      // HOUSEHOLD
      case 'Dishwash Liquid':
        return 'assets/products/dishwash.png';

      case 'Laundry Detergent':
        return 'assets/products/laundry_detergent.png';

      case 'Floor Cleaner':
        return 'assets/products/floor_cleaner.png';

      case 'Garbage Bags':
        return 'assets/products/garbage_bags.png';

      // SNACKS
      case 'Potato Chips':
        return 'assets/products/chips.png';

      case 'Chocolate Cookies':
        return 'assets/products/chocolate_coookies.png';

      case 'Namkeen':
        return 'assets/products/namkeen.png';

      case 'Popcorn':
        return 'assets/products/popcorn.png';

      // BABY CARE
      case 'Baby Shampoo':
        return 'assets/products/baby_shampoo.png';

      case 'Baby Soap':
        return 'assets/products/baby_soap.png';

      case 'Baby Lotion':
        return 'assets/products/baby_lotion.png';

      case 'Baby Powder':
        return 'assets/products/baby_powder.png';

      // PERSONAL CARE
      case 'Face Wash':
        return 'assets/products/face_wash.png';

      case 'Body Lotion':
        return 'assets/products/body_lotion.png';

      case 'Shampoo':
        return 'assets/products/shampoo.png';

      case 'Toothpaste':
        return 'assets/products/toothpaste.png';

      // PET CARE
      case 'Dog Food':
        return 'assets/products/dog_food.png';

      case 'Cat Food':
        return 'assets/products/cat_food.png';

      case 'Pet Shampoo':
        return 'assets/products/pet_shampoo.png';

      case 'Pet Treats':
        return 'assets/products/pet_treat.png';

      // DAILY ESSENTIALS
      case 'Tissue Paper':
        return 'assets/products/tissue_paper.png';

      case 'Hand Wash':
        return 'assets/products/hand_wash.png';

      case 'Toilet Cleaner':
        return 'assets/products/toilet_cleaner.png';

      case 'Hand Sanitizer':
        return 'assets/products/hand_sanitizer.png';

      default:
        return '';
    }
  }

  // =========================================================
  // PRODUCT QUANTITY
  // =========================================================

  String getProductQuantity(String productName) {
    switch (productName) {
      case 'Fresh Milk':
        return '1 L';

      case 'Curd':
        return '500 g';

      case 'Paneer':
        return '200 g';

      case 'Butter':
        return '100 g';

      case 'Fresh Apples':
        return '1 kg';

      case 'Bananas':
        return '1 dozen';

      case 'Oranges':
        return '1 kg';

      case 'Mangoes':
        return '1 kg';

      case 'Potatoes':
        return '1 kg';

      case 'Tomatoes':
        return '1 kg';

      case 'Onions':
        return '1 kg';

      case 'Carrots':
        return '500 g';

      case 'Rice':
        return '5 kg';

      case 'Wheat Flour':
        return '5 kg';

      case 'Toor Dal':
        return '1 kg';

      case 'Cooking Oil':
        return '1 L';

      case 'Brown Bread':
        return '400 g';

      case 'White Bread':
        return '400 g';

      case 'Burger Buns':
        return '4 pcs';

      case 'Cookies':
        return '200 g';

      case 'Tea':
        return '250 g';

      case 'Coffee':
        return '200 g';

      case 'Orange Juice':
        return '1 L';

      case 'Green Tea':
        return '100 g';

      case 'Dishwash Liquid':
        return '500 ml';

      case 'Laundry Detergent':
        return '1 kg';

      case 'Floor Cleaner':
        return '1 L';

      case 'Garbage Bags':
        return '30 pcs';

      case 'Potato Chips':
        return '100 g';

      case 'Chocolate Cookies':
        return '200 g';

      case 'Namkeen':
        return '200 g';

      case 'Popcorn':
        return '100 g';

      case 'Baby Shampoo':
        return '200 ml';

      case 'Baby Soap':
        return '100 g';

      case 'Baby Lotion':
        return '200 ml';

      case 'Baby Powder':
        return '200 g';

      case 'Face Wash':
        return '100 ml';

      case 'Body Lotion':
        return '200 ml';

      case 'Shampoo':
        return '180 ml';

      case 'Toothpaste':
        return '150 g';

      case 'Dog Food':
        return '1 kg';

      case 'Cat Food':
        return '1 kg';

      case 'Pet Shampoo':
        return '200 ml';

      case 'Pet Treats':
        return '200 g';

      case 'Tissue Paper':
        return '1 pack';

      case 'Hand Wash':
        return '250 ml';

      case 'Toilet Cleaner':
        return '500 ml';

      case 'Hand Sanitizer':
        return '100 ml';

      default:
        return '1 pc';
    }
  }

  // =========================================================
  // NORMALIZE CATEGORY
  // =========================================================

  String normalizeCategory(String value) {
    return value
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // =========================================================
  // CATEGORY PRODUCTS
  // =========================================================

  List<Map<String, dynamic>> get products {
    final selectedCategory =
        normalizeCategory(widget.categoryName);

    return allProducts.where((product) {
      final productCategory =
          normalizeCategory(
        product['category'].toString(),
      );

      final bool isAvailable =
          product['isAvailable'] == true;

      return productCategory == selectedCategory &&
          isAvailable;
    }).toList();
  }

  // =========================================================
  // DISPLAYED PRODUCTS
  // =========================================================

  List<Map<String, dynamic>> get displayedProducts {
    List<Map<String, dynamic>> result =
        List<Map<String, dynamic>>.from(products);

    // SEARCH
    if (searchText.trim().isNotEmpty) {
      final query =
          searchText.trim().toLowerCase();

      result = result.where((item) {
        final name =
            item['name'].toString().toLowerCase();

        final brand =
            item['brand'].toString().toLowerCase();

        return name.contains(query) ||
            brand.contains(query);
      }).toList();
    }

    // PRICE FILTER
    result = result.where((item) {
      final price =
          (item['price'] as num).toDouble();

      return price >= minPrice &&
          price <= maxPrice;
    }).toList();

    // LOW TO HIGH
    if (sortOption == 'Price: Low to High') {
      result.sort(
        (a, b) =>
            (a['price'] as num).compareTo(
          b['price'] as num,
        ),
      );
    }

    // HIGH TO LOW
    if (sortOption == 'Price: High to Low') {
      result.sort(
        (a, b) =>
            (b['price'] as num).compareTo(
          a['price'] as num,
        ),
      );
    }

    // NAME
    if (sortOption == 'Name: A to Z') {
      result.sort(
        (a, b) =>
            a['name'].toString().compareTo(
                  b['name'].toString(),
                ),
      );
    }

    return result;
  }

  // =========================================================
  // OPEN PRODUCT DETAILS
  // =========================================================

  void openProductDetails(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductDetailsScreen(
          productId: item['id'] as int,
          productName: item['name'],
          category: widget.categoryName,
          quantity: item['quantity'],
          price: item['price'],
          icon: item['icon'],
          imageUrl: item['image'],
        ),
      ),
    );
  }

  // =========================================================
  // ADD TO CART
  // =========================================================

  Future<void> addToCart(
    BuildContext context,
    Map<String, dynamic> item,
  ) async {
    final int productId =
        item['id'] as int;

    final double price =
        (item['price'] as num).toDouble();

    final String productName =
        item['name'].toString();

    final String category =
        item['category'].toString();

    final String productQuantity =
        item['quantity'].toString();

    final String productImage =
        item['image']?.toString() ?? '';

    // ---------------------------------------------------------
    // BACKEND CART
    // ---------------------------------------------------------

    final result =
        await ApiService.addToCart(
      userId: 2,
      productId: productId,
      productName: productName,
      productImage: productImage,
      price: price,
      quantity: 1,
    );

    if (!mounted) return;

    // ---------------------------------------------------------
    // SUCCESS
    // ---------------------------------------------------------

    if (result['success'] == true) {
      CartData.addItem(
        productName: productName,
        category: category,
        productQuantity: productQuantity,
        price: price.toInt(),
        quantity: 1,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$productName added to cart',
          ),
          duration: const Duration(
            seconds: 2,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ??
                'Unable to add to cart',
          ),
          duration: const Duration(
            seconds: 2,
          ),
        ),
      );
    }
  }

  // =========================================================
  // FILTER SHEET
  // =========================================================

  void showFilterSheet() {
    double tempMinPrice = minPrice;
    double tempMaxPrice = maxPrice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (
            context,
            setSheetState,
          ) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                30,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Products',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Price Range',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    '₹${tempMinPrice.toInt()} - ₹${tempMaxPrice.toInt()}',
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  RangeSlider(
                    min: 0,
                    max: 500,
                    divisions: 50,
                    values: RangeValues(
                      tempMinPrice,
                      tempMaxPrice,
                    ),
                    activeColor: primaryColor,
                    onChanged: (values) {
                      setSheetState(() {
                        tempMinPrice =
                            values.start;

                        tempMaxPrice =
                            values.end;
                      });
                    },
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          minPrice =
                              tempMinPrice;

                          maxPrice =
                              tempMaxPrice;
                        });

                        Navigator.pop(context);
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
                            12,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Apply Filter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // =========================================================
  // SORT
  // =========================================================

  void showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort Products',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              _sortTile('Default'),

              _sortTile(
                'Price: Low to High',
              ),

              _sortTile(
                'Price: High to Low',
              ),

              _sortTile(
                'Name: A to Z',
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // SORT TILE
  // =========================================================

  Widget _sortTile(String value) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 0,
      ),
      leading: Icon(
        sortOption == value
            ? Icons.radio_button_checked
            : Icons.radio_button_off,
        color: primaryColor,
      ),
      title: Text(value),
      onTap: () {
        setState(() {
          sortOption = value;
        });

        Navigator.pop(context);
      },
    );
  }

  // =========================================================
  // PRODUCT IMAGE
  // =========================================================

  Widget productImage(
    Map<String, dynamic> item,
  ) {
    final String image =
        item['image']?.toString() ?? '';

    final IconData icon =
        item['icon'] as IconData;

    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(14),
        child: image.startsWith('assets/')
            ? Image.asset(
                image,
                fit: BoxFit.contain,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return Center(
                    child: Icon(
                      icon,
                      size: 70,
                      color: primaryColor,
                    ),
                  );
                },
              )
            : image.isNotEmpty
                ? Image.network(
                    image,
                    fit: BoxFit.contain,
                    loadingBuilder: (
                      context,
                      child,
                      loadingProgress,
                    ) {
                      if (loadingProgress ==
                          null) {
                        return child;
                      }

                      return const Center(
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              primaryColor,
                        ),
                      );
                    },
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return Center(
                        child: Icon(
                          icon,
                          size: 70,
                          color: primaryColor,
                        ),
                      );
                    },
                  )
                : Center(
                    child: Icon(
                      icon,
                      size: 70,
                      color: primaryColor,
                    ),
                  ),
      ),
    );
  }

  // =========================================================
  // PRODUCT CARD
  // =========================================================

  Widget productCard(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    final double price =
        (item['price'] as num).toDouble();

    final int stock =
        int.tryParse(
              item['stock'].toString(),
            ) ??
            0;

    final double mrp =
        (item['mrp'] as num).toDouble();

    // =======================================================
    // CHECK WHETHER PRODUCT IS IN WISHLIST
    // =======================================================

    final int wishlistIndex =
        WishlistData.items.indexWhere(
      (wishlistItem) =>
          wishlistItem.productName ==
          item['name'].toString(),
    );

    final bool isWishlisted =
        wishlistIndex != -1;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(14),
        onTap: () {
          openProductDetails(
            context,
            item,
          );
        },
        child: Padding(
          padding:
              const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // =================================================
              // IMAGE + WISHLIST ICON
              // =================================================

              SizedBox(
                height: 135,
                width: double.infinity,
                child: Stack(
                  children: [

                    // PRODUCT IMAGE
                    Positioned.fill(
                      child: productImage(item),
                    ),

                    // =================================================
                    // WISHLIST HEART
                    // =================================================

                    Positioned(
                      top: 7,
                      right: 7,
                      child: Material(
                        color: Colors.white,
                        elevation: 2,
                        shape:
                            const CircleBorder(),
                        child: InkWell(
                          customBorder:
                              const CircleBorder(),
                          onTap: () {

                            // =================================================
                            // REMOVE FROM WISHLIST
                            // =================================================

                            if (isWishlisted) {
                              WishlistData.removeItem(
                                wishlistIndex,
                              );

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${item['name']} removed from wishlist',
                                  ),
                                  duration:
                                      const Duration(
                                    seconds: 1,
                                  ),
                                ),
                              );
                            }

                            // =================================================
                            // ADD TO WISHLIST
                            // =================================================

                            else {
                             WishlistData.addItem(
  productName:
      item['name'].toString(),
  category:
      item['category'].toString(),
  productQuantity:
      item['quantity'].toString(),
  price:
      price.toInt(),
  icon:
      item['icon'] as IconData,
);

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${item['name']} added to wishlist ❤️',
                                  ),
                                  duration:
                                      const Duration(
                                    seconds: 1,
                                  ),
                                ),
                              );
                            }

                            // Refresh heart icon
                            setState(() {});
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.all(
                              8,
                            ),
                            child: Icon(
                              isWishlisted
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isWishlisted
                                  ? Colors.red
                                  : Colors.grey.shade700,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // =================================================
              // NAME
              // =================================================

              Text(
                item['name'].toString(),
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 3),

              // =================================================
              // BRAND
              // =================================================

              if (item['brand']
                  .toString()
                  .isNotEmpty)
                Text(
                  item['brand'].toString(),
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),

              const SizedBox(height: 3),

              // =================================================
              // QUANTITY
              // =================================================

              Text(
                item['quantity'].toString(),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 4),

              // =================================================
              // PRICE
              // =================================================

              Row(
                children: [
                  Text(
                    money(price),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),

                  if (mrp > price)
                    const SizedBox(width: 7),

                  if (mrp > price)
                    Expanded(
                      child: Text(
                        money(mrp),
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          decoration:
                              TextDecoration
                                  .lineThrough,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 6),

              // =================================================
              // ADD BUTTON
              // =================================================

              SizedBox(
                width: double.infinity,
                height: 38,
                child: ElevatedButton(
                  onPressed: stock > 0
                      ? () {
                          addToCart(
                            context,
                            item,
                          );
                        }
                      : null,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        primaryColor,
                    foregroundColor:
                        Colors.white,
                    disabledBackgroundColor:
                        Colors.grey.shade300,
                    disabledForegroundColor:
                        Colors.grey.shade600,
                    padding:
                        EdgeInsets.zero,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        8,
                      ),
                    ),
                  ),
                  child: Text(
                    stock > 0
                        ? 'ADD'
                        : 'OUT OF STOCK',
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // MONEY
  // =========================================================

  String money(double value) {
    if (value == value.roundToDouble()) {
      return '₹${value.toInt()}';
    }

    return '₹${value.toStringAsFixed(2)}';
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final items = displayedProducts;

    return Scaffold(
      backgroundColor: Colors.white,

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),

        title: Text(
          widget.categoryName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed:
                isLoading ? null : loadProducts,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      24,
                    ),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 55,
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        Text(
                          errorMessage,
                          textAlign:
                              TextAlign.center,
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        ElevatedButton(
                          onPressed:
                              loadProducts,
                          child:
                              const Text(
                            'Retry',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [

                    // =================================================
                    // SEARCH
                    // =================================================

                    Padding(
                      padding:
                          const EdgeInsets
                              .fromLTRB(
                        16,
                        10,
                        16,
                        12,
                      ),
                      child: TextField(
                        controller:
                            searchController,
                        onChanged: (value) {
                          setState(() {
                            searchText =
                                value;
                          });
                        },
                        decoration:
                            InputDecoration(
                          hintText:
                              'Search products...',

                          prefixIcon:
                              const Icon(
                            Icons.search,
                            color:
                                primaryColor,
                          ),

                          suffixIcon:
                              searchText
                                      .isNotEmpty
                                  ? IconButton(
                                      onPressed:
                                          () {
                                        searchController
                                            .clear();

                                        setState(
                                          () {
                                            searchText =
                                                '';
                                          },
                                        );
                                      },
                                      icon:
                                          const Icon(
                                        Icons.clear,
                                      ),
                                    )
                                  : null,

                          filled: true,

                          fillColor:
                              Colors.grey
                                  .shade100,

                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                            borderSide:
                                BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    // =================================================
                    // FILTER + SORT
                    // =================================================

                    Padding(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [

                          Expanded(
                            child:
                                OutlinedButton
                                    .icon(
                              onPressed:
                                  showFilterSheet,
                              icon:
                                  const Icon(
                                Icons.tune,
                                size: 18,
                              ),
                              label:
                                  const Text(
                                'Filter',
                              ),
                              style:
                                  OutlinedButton
                                      .styleFrom(
                                foregroundColor:
                                    primaryColor,
                                side:
                                    const BorderSide(
                                  color:
                                      primaryColor,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    10,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child:
                                OutlinedButton
                                    .icon(
                              onPressed:
                                  showSortOptions,
                              icon:
                                  const Icon(
                                Icons.sort,
                                size: 18,
                              ),
                              label:
                                  const Text(
                                'Sort',
                              ),
                              style:
                                  OutlinedButton
                                      .styleFrom(
                                foregroundColor:
                                    primaryColor,
                                side:
                                    const BorderSide(
                                  color:
                                      primaryColor,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // =================================================
                    // PRODUCT COUNT
                    // =================================================

                    Padding(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 16,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                        children: [

                          Text(
                            '${items.length} products',
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                              color:
                                  Colors.grey,
                            ),
                          ),

                          if (sortOption !=
                              'Default')
                            Text(
                              sortOption,
                              style:
                                  const TextStyle(
                                color:
                                    primaryColor,
                                fontSize:
                                    13,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // =================================================
                    // PRODUCTS GRID
                    // =================================================

                    Expanded(
                      child: items.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                children: [

                                  Icon(
                                    Icons
                                        .search_off,
                                    size: 65,
                                    color:
                                        Colors.grey,
                                  ),

                                  SizedBox(
                                    height: 12,
                                  ),

                                  Text(
                                    'No products found',
                                    style:
                                        TextStyle(
                                      fontSize:
                                          18,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  SizedBox(
                                    height: 5,
                                  ),

                                  Text(
                                    'Try another search or filter.',
                                    style:
                                        TextStyle(
                                      color:
                                          Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              color:
                                  primaryColor,
                              onRefresh:
                                  loadProducts,
                              child:
                                  GridView.builder(
                                padding:
                                    const EdgeInsets
                                        .fromLTRB(
                                  16,
                                  4,
                                  16,
                                  25,
                                ),

                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      2,

                                  crossAxisSpacing:
                                      12,

                                  mainAxisSpacing:
                                      12,

                                  mainAxisExtent:
                                      MediaQuery.of(
                                                context,
                                              ).size.width >
                                              800
                                          ? 430
                                          : 390,
                                ),

                                itemCount:
                                    items.length,

                                itemBuilder:
                                    (
                                  context,
                                  index,
                                ) {
                                  return productCard(
                                    context,
                                    items[index],
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}