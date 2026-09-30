import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AdminProduct {
  int id;
  String name;
  String description;
  String category;
  String brand;
  String sku;
  double price;
  double mrp;
  double discount;
  int stock;
  String imageUrl;
  bool isAvailable;
  bool isSubscriptionEligible;
  Uint8List? imageBytes;

  AdminProduct({
    required this.id,
    required this.name,
    this.description = '',
    required this.category,
    this.brand = '',
    this.sku = '',
    required this.price,
    this.mrp = 0,
    this.discount = 0,
    required this.stock,
    this.imageUrl = '',
    this.isAvailable = true,
    this.isSubscriptionEligible = true,
    this.imageBytes,
  });

  factory AdminProduct.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminProduct(
      id: int.tryParse(
            '${json['id'] ?? 0}',
          ) ??
          0,
      name: json['name']?.toString() ?? '',
      description:
          json['description']?.toString() ?? '',
      category:
          json['category']?.toString() ?? '',
      brand:
          json['brand']?.toString() ?? '',
      sku:
          json['sku']?.toString() ?? '',
      price:
          double.tryParse(
                '${json['price'] ?? 0}',
              ) ??
              0,
      mrp:
          double.tryParse(
                '${json['mrp'] ?? 0}',
              ) ??
              0,
      discount:
          double.tryParse(
                '${json['discount'] ?? 0}',
              ) ??
              0,
      stock:
          int.tryParse(
                '${json['stock'] ?? 0}',
              ) ??
              0,
      imageUrl:
          json['image_url']?.toString() ?? '',
      isAvailable:
          json['is_available'] == null
              ? true
              : json['is_available'] == true,
      isSubscriptionEligible:
          json['is_subscription_eligible'] == null
              ? true
              : json['is_subscription_eligible'] == true,
    );
  }
}

class AdminProductsScreen
    extends StatefulWidget {
  const AdminProductsScreen({
    super.key,
  });

  @override
  State<AdminProductsScreen> createState() =>
      _AdminProductsScreenState();
}

class _AdminProductsScreenState
    extends State<AdminProductsScreen> {
  static const Color primaryColor =
      Color(0xFF159A93);

  final TextEditingController searchController =
      TextEditingController();

  final List<AdminProduct> products = [];

  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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

    try {
      final result =
          await ApiService.getAllProducts();

      if (!mounted) return;

      if (result['success'] == true) {
        final List<dynamic> data =
            result['products'] ?? [];

        setState(() {
          products.clear();

          for (final item in data) {
            products.add(
              AdminProduct.fromJson(
                Map<String, dynamic>.from(
                  item,
                ),
              ),
            );
          }

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              result['message'] ??
                  'Unable to load products';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load products';
      });
    }
  }

  // =========================================================
  // SEARCH
  // =========================================================

  List<AdminProduct>
      get filteredProducts {
    final query =
        searchController.text
            .toLowerCase()
            .trim();

    if (query.isEmpty) {
      return products;
    }

    return products.where((product) {
      return product.name
              .toLowerCase()
              .contains(query) ||
          product.category
              .toLowerCase()
              .contains(query) ||
          product.brand
              .toLowerCase()
              .contains(query) ||
          product.sku
              .toLowerCase()
              .contains(query);
    }).toList();
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
  // CATEGORY IMAGE
  // =========================================================
String fallbackImageForCategory(
  String category, [
  String productName = '',
]) {
  final cat = category.toLowerCase().trim();
  final name = productName.toLowerCase().trim();

  // Product-specific images
  if (name.contains('paneer')) {
    return 'assets/products/paneer.png';
  }
  if (name.contains('curd')) {
    return 'assets/products/curd.png';
  }
  if (name.contains('milk')) {
    return 'assets/products/fresh_milk.png';
  }
  if (name.contains('mango')) {
    return 'assets/products/mango.png';
  }
  if (name.contains('orange juice')) {
    return 'assets/products/orange_juice.png';
  }
  if (name.contains('orange')) {
    return 'assets/products/orange.png';
  }
  if (name.contains('onion')) {
    return 'assets/products/onion.png';
  }
  if (name.contains('tomato')) {
    return 'assets/products/tomato.png';
  }
  if (name.contains('potato')) {
    return 'assets/products/potato.png';
  }
  if (name.contains('rice')) {
    return 'assets/products/rice.png';
  }
  if (name.contains('toor dal')) {
    return 'assets/products/toor_dal.png';
  }
  if (name.contains('toothpaste')) {
    return 'assets/products/toothpaste.png';
  }
  if (name.contains('shampoo')) {
    return 'assets/products/shampoo.png';
  }
  if (name.contains('tea')) {
    return 'assets/products/tea.png';
  }
  if (name.contains('tissue')) {
    return 'assets/products/tissue_paper.png';
  }
  if (name.contains('toilet cleaner')) {
    return 'assets/products/toilet_cleaner.png';
  }
  if (name.contains('wheat flour')) {
    return 'assets/products/wheat_flour.png';
  }
  if (name.contains('white bread')) {
    return 'assets/products/white_bread.png';
  }
  if (name.contains('snack')) {
    return 'assets/products/snacks.png';
  }

  // Category fallback images
  if (cat.contains('milk') || cat.contains('dairy')) {
    return 'assets/products/milk_dairy.png';
  }

  if (cat.contains('fruit')) {
    return 'assets/products/fruits.png';
  }

  if (cat.contains('vegetable')) {
    return 'assets/products/vegetables.png';
  }

  if (cat.contains('grocery')) {
    return 'assets/products/grocery.png';
  }

  if (cat.contains('household')) {
    return 'assets/products/household.png';
  }

  if (cat.contains('pet')) {
    return 'assets/products/pet_care.png';
  }

  if (cat.contains('personal')) {
    return 'assets/products/personal_care.png';
  }

  if (cat.contains('snack')) {
    return 'assets/products/snacks.png';
  }

  if (cat.contains('daily')) {
    return 'assets/products/daily_essentials.png';
  }

  return 'assets/products/grocery.png';
}
  //============================
  // PRODUCT IMAGE
  // =========================================================

  Widget productImage(
  AdminProduct product, {
  double size = 80,
}) {
  final fallbackUrl = fallbackImageForCategory(
    product.category,
  );

  // 1. Uploaded image preview
  if (product.imageBytes != null) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.memory(
        product.imageBytes!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }

  final imageUrl = product.imageUrl.trim();

  // 2. Local Flutter asset image
  if (imageUrl.startsWith('assets/')) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.asset(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            color: const Color(0xFFE8F7F5),
            child: const Icon(
              Icons.image_not_supported_outlined,
              color: primaryColor,
              size: 32,
            ),
          );
        },
      ),
    );
  }

  // 3. Network image
  return ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: Image.network(
      imageUrl.isNotEmpty ? imageUrl : fallbackUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      loadingBuilder: (
        context,
        child,
        loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          width: size,
          height: size,
          color: const Color(0xFFE8F7F5),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: primaryColor,
            ),
          ),
        );
      },
      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return Container(
          width: size,
          height: size,
          color: const Color(0xFFE8F7F5),
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: primaryColor,
            size: 32,
          ),
        );
      },
    ),
  );
}

  // =========================================================
  // PICK IMAGE
  // =========================================================
Future<Uint8List?> pickProductImage() async {
  try {
    final file = await FilePicker.pickFile(
      type: FileType.image,
    );

    if (file == null) {
      return null;
    }

    final bytes = await file.readAsBytes();

    return bytes;
  } catch (e) {
    debugPrint('Image picker error: $e');
    return null;
  }
}

  // =========================================================
  // ADD / EDIT PRODUCT
  // =========================================================

  void showProductDialog({
    AdminProduct? product,
  }) {
    final nameController =
        TextEditingController(
      text: product?.name ?? '',
    );

    final descriptionController =
        TextEditingController(
      text: product?.description ?? '',
    );

    final categoryController =
        TextEditingController(
      text: product?.category ?? '',
    );

    final brandController =
        TextEditingController(
      text: product?.brand ?? '',
    );

    final skuController =
        TextEditingController(
      text: product?.sku ?? '',
    );

    final priceController =
        TextEditingController(
      text: product != null
          ? product.price.toString()
          : '',
    );

    final mrpController =
        TextEditingController(
      text: product != null
          ? product.mrp.toString()
          : '',
    );

    final discountController =
        TextEditingController(
      text: product != null
          ? product.discount.toString()
          : '0',
    );

    final stockController =
        TextEditingController(
      text: product != null
          ? product.stock.toString()
          : '',
    );

    final imageUrlController =
        TextEditingController(
      text: product?.imageUrl ?? '',
    );

    Uint8List? selectedImageBytes =
        product?.imageBytes;

    bool isAvailable =
        product?.isAvailable ?? true;

    bool isSubscriptionEligible =
        product?.isSubscriptionEligible ??
            true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: Text(
                product == null
                    ? 'Add Product'
                    : 'Edit Product',
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              content: SizedBox(
                width: 500,

                child:
                    SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [

                      // PRODUCT IMAGE PREVIEW
                      Container(
                        width: 150,
                        height: 150,
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFE8F7F5,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),
                        ),
                        child:
                            ClipRRect(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),
                          child:
                              selectedImageBytes !=
                                      null
                                  ? Image.memory(
                                      selectedImageBytes!,
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      imageUrlController
                                              .text
                                              .trim()
                                              .isNotEmpty
                                          ? imageUrlController
                                              .text
                                              .trim()
                                          : fallbackImageForCategory(
                                              categoryController
                                                  .text,
                                            ),
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return const Icon(
                                          Icons
                                              .image_outlined,
                                          color:
                                              primaryColor,
                                          size: 50,
                                        );
                                      },
                                    ),
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      // UPLOAD
                      ElevatedButton.icon(
  style: ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
  ),
  onPressed: () async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.image,
        
      );

      if (file != null) {
        final bytes = await file.readAsBytes();

          setDialogState(() {
            selectedImageBytes = bytes;
          });
        
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to select image: $e'),
        ),
      );
    }
  },
  icon: const Icon(Icons.upload_file),
  label: const Text('Upload Product Image'),
),

                      const SizedBox(
                        height: 15,
                      ),

                      // NAME
                      TextField(
                        controller:
                            nameController,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Product Name',
                          prefixIcon:
                              Icon(
                            Icons
                                .shopping_bag_outlined,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      // DESCRIPTION
                      TextField(
                        controller:
                            descriptionController,
                        maxLines: 3,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Description',
                          prefixIcon:
                              Icon(
                            Icons
                                .description_outlined,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      // CATEGORY
                      TextField(
                        controller:
                            categoryController,
                        onChanged:
                            (_) {
                          setDialogState(
                            () {},
                          );
                        },
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Category',
                          prefixIcon:
                              Icon(
                            Icons
                                .category_outlined,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      // BRAND
                      TextField(
                        controller:
                            brandController,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Brand',
                          prefixIcon:
                              Icon(
                            Icons
                                .business_outlined,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      // SKU
                      TextField(
                        controller:
                            skuController,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'SKU',
                          prefixIcon:
                              Icon(
                            Icons
                                .qr_code_outlined,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      // PRICE
                      TextField(
                        controller:
                            priceController,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Price',
                          prefixIcon:
                              Icon(
                            Icons
                                .currency_rupee,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      // MRP
                      TextField(
                        controller:
                            mrpController,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                        decoration:
                            const InputDecoration(
                          labelText:
                              'MRP',
                          prefixIcon:
                              Icon(
                            Icons
                                .price_check,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      // DISCOUNT
                      TextField(
                        controller:
                            discountController,
                        keyboardType:
                            const TextInputType
                                .numberWithOptions(
                          decimal: true,
                        ),
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Discount',
                          prefixIcon:
                              Icon(
                            Icons
                                .discount_outlined,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      // STOCK
                      TextField(
                        controller:
                            stockController,
                        keyboardType:
                            TextInputType.number,
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Stock',
                          prefixIcon:
                              Icon(
                            Icons
                                .inventory_2_outlined,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      // IMAGE URL
                      TextField(
                        controller:
                            imageUrlController,
                        keyboardType:
                            TextInputType.url,
                        onChanged:
                            (_) {
                          setDialogState(
                            () {},
                          );
                        },
                        decoration:
                            const InputDecoration(
                          labelText:
                              'Product Image URL',
                          hintText:
                              'https://...',
                          prefixIcon:
                              Icon(
                            Icons
                                .image_outlined,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      // URL NOTE
                      Container(
                        width:
                            double.infinity,
                        padding:
                            const EdgeInsets
                                .all(
                          12,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFE8F7F5,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                        child:
                            const Text(
                          'If Image URL is empty, a category-based image will be displayed automatically.',
                          style:
                              TextStyle(
                            fontSize: 12,
                            color:
                                Colors.black54,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      // AVAILABLE
                      SwitchListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        title:
                            const Text(
                          'Product Available',
                        ),
                        value:
                            isAvailable,
                        activeColor:
                            primaryColor,
                        onChanged:
                            (value) {
                          setDialogState(
                            () {
                              isAvailable =
                                  value;
                            },
                          );
                        },
                      ),

                      // SUBSCRIPTION
                      SwitchListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        title:
                            const Text(
                          'Subscription Eligible',
                        ),
                        value:
                            isSubscriptionEligible,
                        activeColor:
                            primaryColor,
                        onChanged:
                            (value) {
                          setDialogState(
                            () {
                              isSubscriptionEligible =
                                  value;
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              actions: [

                // CANCEL
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child:
                      const Text(
                    'Cancel',
                  ),
                ),

                // SAVE
                ElevatedButton(
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        primaryColor,
                    foregroundColor:
                        Colors.white,
                  ),

                  onPressed:
                      () async {
                    final name =
                        nameController
                            .text
                            .trim();

                    final description =
                        descriptionController
                            .text
                            .trim();

                    final category =
                        categoryController
                            .text
                            .trim();

                    final brand =
                        brandController
                            .text
                            .trim();

                    final sku =
                        skuController
                            .text
                            .trim();

                    final price =
                        double.tryParse(
                      priceController
                          .text
                          .trim(),
                    );

                    final mrp =
                        double.tryParse(
                      mrpController
                          .text
                          .trim(),
                    );

                    final discount =
                        double.tryParse(
                              discountController
                                  .text
                                  .trim(),
                            ) ??
                            0;

                    final stock =
                        int.tryParse(
                      stockController
                          .text
                          .trim(),
                    );

                    final imageUrl =
                        imageUrlController
                            .text
                            .trim();

                    // VALIDATION
                    if (name.isEmpty ||
                        category.isEmpty ||
                        price == null ||
                        mrp == null ||
                        stock == null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content:
                              Text(
                            'Please enter all required product details',
                          ),
                        ),
                      );
                      return;
                    }

                    // =================================================
                    // ADD PRODUCT
                    // =================================================

                    if (product == null) {
                      final result =
                          await ApiService.addProduct(
                        name: name,
                        description:
                            description
                                    .isEmpty
                                ? null
                                : description,
                        category:
                            category,
                        brand: brand
                                .isEmpty
                            ? null
                            : brand,
                        sku: sku.isEmpty
                            ? null
                            : sku,
                        price: price,
                        mrp: mrp,
                        discount:
                            discount,
                        stock: stock,
                        imageUrl:
                            imageUrl.isEmpty
                                ? null
                                : imageUrl,
                        isAvailable:
                            isAvailable,
                        isSubscriptionEligible:
                            isSubscriptionEligible,
                      );

                      if (!mounted)
                        return;

                      if (result[
                              'success'] ==
                          true) {
                        Navigator.pop(
                          dialogContext,
                        );

                        await loadProducts();

                        if (!mounted)
                          return;

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content:
                                Text(
                              'Product added successfully',
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          SnackBar(
                            content:
                                Text(
                              result[
                                      'message'] ??
                                  'Unable to add product',
                            ),
                          ),
                        );
                      }

                      return;
                    }

                    // =================================================
                    // EDIT PRODUCT
                    // =================================================

                    final result =
                        await ApiService.updateProduct(
                      productId:
                          product.id,
                      name: name,
                      description:
                          description
                                  .isEmpty
                              ? null
                              : description,
                      category:
                          category,
                      brand: brand.isEmpty
                          ? null
                          : brand,
                      sku: sku.isEmpty
                          ? null
                          : sku,
                      price: price,
                      mrp: mrp,
                      discount:
                          discount,
                      stock: stock,
                      imageUrl:
                          imageUrl.isEmpty
                              ? null
                              : imageUrl,
                      isAvailable:
                          isAvailable,
                      isSubscriptionEligible:
                          isSubscriptionEligible,
                    );

                    if (!mounted)
                      return;

                    if (result[
                            'success'] ==
                        true) {
                      Navigator.pop(
                        dialogContext,
                      );

                      await loadProducts();

                      if (!mounted)
                        return;

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content:
                              Text(
                            'Product updated successfully',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content:
                              Text(
                            result[
                                    'message'] ??
                                'Unable to update product',
                          ),
                        ),
                      );
                    }
                  },

                  child: Text(
                    product == null
                        ? 'Add Product'
                        : 'Update',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================================================
  // DELETE
  // =========================================================

  void deleteProduct(
    AdminProduct product,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
              const Text(
            'Delete Product',
            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          content: Text(
            'Are you sure you want to delete "${product.name}"?',
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
                foregroundColor:
                    Colors.white,
              ),

              onPressed:
                  () async {
                final result =
                    await ApiService
                        .deleteProduct(
                  productId:
                      product.id,
                );

                if (!mounted) return;

                if (result[
                        'success'] ==
                    true) {
                  Navigator.pop(
                    dialogContext,
                  );

                  setState(() {
                    products
                        .remove(
                      product,
                    );
                  });

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content:
                          Text(
                        'Product deleted successfully',
                      ),
                    ),
                  );
                } else {
                  Navigator.pop(
                    dialogContext,
                  );

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      content:
                          Text(
                        result[
                                'message'] ??
                            'Unable to delete product',
                      ),
                    ),
                  );
                }
              },

              child:
                  const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // STOCK COLOR
  // =========================================================

  Color stockColor(
    int stock,
  ) {
    if (stock <= 5) {
      return Colors.red;
    }

    if (stock <= 10) {
      return Colors.orange;
    }

    return Colors.green;
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final displayedProducts =
        filteredProducts;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F9F9),

      appBar: AppBar(
        backgroundColor:
            Colors.white,
        foregroundColor:
            Colors.black87,
        elevation: 0,

        title:
            const Text(
          'Manage Products',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        actions: [

          IconButton(
            onPressed:
                isLoading
                    ? null
                    : loadProducts,
            icon:
                const Icon(
              Icons.refresh,
            ),
            tooltip:
                'Refresh',
          ),

          IconButton(
            onPressed: () {
              showProductDialog();
            },
            icon:
                const Icon(
              Icons.add,
            ),
            tooltip:
                'Add Product',
          ),
        ],
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor:
            primaryColor,
        foregroundColor:
            Colors.white,
        onPressed: () {
          showProductDialog();
        },
        icon:
            const Icon(
          Icons.add,
        ),
        label:
            const Text(
          'Add Product',
        ),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color:
                    primaryColor,
              ),
            )
          : errorMessage
                  .isNotEmpty
              ? Center(
                  child:
                      Padding(
                    padding:
                        const EdgeInsets
                            .all(
                      24,
                    ),
                    child:
                        Column(
                      mainAxisSize:
                          MainAxisSize
                              .min,
                      children: [

                        const Icon(
                          Icons
                              .error_outline,
                          color:
                              Colors.red,
                          size: 50,
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        Text(
                          errorMessage,
                          textAlign:
                              TextAlign
                                  .center,
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
                              .all(
                        16,
                      ),

                      child:
                          TextField(
                        controller:
                            searchController,

                        onChanged:
                            (_) {
                          setState(
                              () {});
                        },

                        decoration:
                            InputDecoration(
                          hintText:
                              'Search products...',

                          prefixIcon:
                              const Icon(
                            Icons
                                .search,
                          ),

                          suffixIcon:
                              searchController
                                      .text
                                      .isNotEmpty
                                  ? IconButton(
                                      onPressed:
                                          () {
                                        searchController
                                            .clear();

                                        setState(
                                            () {});
                                      },
                                      icon:
                                          const Icon(
                                        Icons
                                            .clear,
                                      ),
                                    )
                                  : null,

                          filled:
                              true,

                          fillColor:
                              Colors.white,

                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                            borderSide:
                                BorderSide
                                    .none,
                          ),
                        ),
                      ),
                    ),

                    // =================================================
                    // COUNT
                    // =================================================

                    Padding(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal:
                            16,
                      ),

                      child: Row(
                        children: [

                          Text(
                            '${displayedProducts.length} Products',
                            style:
                                const TextStyle(
                              fontSize:
                                  17,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            'Total: ${products.length}',
                            style:
                                const TextStyle(
                              color:
                                  Colors
                                      .grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // =================================================
                    // PRODUCT LIST
                    // =================================================

                    Expanded(
                      child:
                          displayedProducts
                                  .isEmpty
                              ? const Center(
                                  child:
                                      Text(
                                    'No products found',
                                    style:
                                        TextStyle(
                                      color:
                                          Colors.grey,
                                      fontSize:
                                          16,
                                    ),
                                  ),
                                )
                              : RefreshIndicator(
                                  color:
                                      primaryColor,

                                  onRefresh:
                                      loadProducts,

                                  child:
                                      ListView.builder(
                                    padding:
                                        const EdgeInsets.fromLTRB(
                                      16,
                                      5,
                                      16,
                                      100,
                                    ),

                                    itemCount:
                                        displayedProducts
                                            .length,

                                    itemBuilder:
                                        (
                                      context,
                                      index,
                                    ) {
                                      final product =
                                          displayedProducts[
                                              index];

                                      return Card(
                                        color:
                                            Colors.white,

                                        margin:
                                            const EdgeInsets.only(
                                          bottom:
                                              12,
                                        ),

                                        elevation:
                                            1,

                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(
                                            16,
                                          ),
                                        ),

                                        child:
                                            Padding(
                                          padding:
                                              const EdgeInsets.all(
                                            14,
                                          ),

                                          child:
                                              Row(
                                            children: [

                                              // =================================================
                                              // IMAGE
                                              // =================================================

                                              Container(
                                                height:
                                                    85,
                                                width:
                                                    85,

                                                decoration:
                                                    BoxDecoration(
                                                  color:
                                                      const Color(
                                                    0xFFE8F7F5,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    16,
                                                  ),
                                                ),

                                                child:
                                                    productImage(
                                                  product,
                                                  size:
                                                      85,
                                                ),
                                              ),

                                              const SizedBox(
                                                width:
                                                    15,
                                              ),

                                              // =================================================
                                              // DETAILS
                                              // =================================================

                                              Expanded(
                                                child:
                                                    Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,

                                                  children: [

                                                    Text(
                                                      product.name,
                                                      maxLines:
                                                          2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            16,
                                                      ),
                                                    ),

                                                    const SizedBox(
                                                      height:
                                                          4,
                                                    ),

                                                    Text(
                                                      product.category,
                                                      style:
                                                          const TextStyle(
                                                        color:
                                                            Colors.grey,
                                                        fontSize:
                                                            13,
                                                      ),
                                                    ),

                                                    const SizedBox(
                                                      height:
                                                          7,
                                                    ),

                                                    Row(
                                                      children: [

                                                        Text(
                                                          money(
                                                            product.price,
                                                          ),
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                15,
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                          width:
                                                              15,
                                                        ),

                                                        Text(
                                                          'Stock: ${product.stock}',
                                                          style:
                                                              TextStyle(
                                                            color:
                                                                stockColor(
                                                              product.stock,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize:
                                                                13,
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    if (product.brand
                                                        .isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                          top:
                                                              4,
                                                        ),
                                                        child:
                                                            Text(
                                                          product.brand,
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                Colors.grey,
                                                            fontSize:
                                                                12,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),

                                              // =================================================
                                              // MENU
                                              // =================================================

                                              PopupMenuButton<
                                                  String>(
                                                onSelected:
                                                    (
                                                  value,
                                                ) {
                                                  if (value ==
                                                      'edit') {
                                                    showProductDialog(
                                                      product:
                                                          product,
                                                    );
                                                  }

                                                  if (value ==
                                                      'delete') {
                                                    deleteProduct(
                                                      product,
                                                    );
                                                  }
                                                },

                                                itemBuilder:
                                                    (
                                                  context,
                                                ) =>
                                                        const [

                                                  PopupMenuItem(
                                                    value:
                                                        'edit',
                                                    child:
                                                        Row(
                                                      children: [

                                                        Icon(
                                                          Icons
                                                              .edit_outlined,
                                                        ),

                                                        SizedBox(
                                                          width:
                                                              10,
                                                        ),

                                                        Text(
                                                          'Edit',
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  PopupMenuItem(
                                                    value:
                                                        'delete',
                                                    child:
                                                        Row(
                                                      children: [

                                                        Icon(
                                                          Icons
                                                              .delete_outline,
                                                          color:
                                                              Colors.red,
                                                        ),

                                                        SizedBox(
                                                          width:
                                                              10,
                                                        ),

                                                        Text(
                                                          'Delete',
                                                        ),
                                                      ],
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
                  ],
                ),
    );
  }
}