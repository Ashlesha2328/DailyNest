import 'package:flutter/material.dart';

import '../services/api_service.dart';

class InventoryProduct {
  int id;
  String name;
  String category;
  double price;
  int stock;

  InventoryProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
  });

  factory InventoryProduct.fromJson(
    Map<String, dynamic> json,
  ) {
    return InventoryProduct(
      id: int.tryParse(
            '${json['id'] ?? 0}',
          ) ??
          0,
      name:
          json['name']?.toString() ?? '',
      category:
          json['category']?.toString() ?? '',
      price:
          double.tryParse(
                '${json['price'] ?? 0}',
              ) ??
              0,
      stock:
          int.tryParse(
                '${json['stock'] ?? 0}',
              ) ??
              0,
    );
  }
}

class AdminInventoryScreen
    extends StatefulWidget {
  const AdminInventoryScreen({
    super.key,
  });

  @override
  State<AdminInventoryScreen> createState() =>
      _AdminInventoryScreenState();
}

class _AdminInventoryScreenState
    extends State<AdminInventoryScreen> {
  static const Color primaryColor =
      Color(0xFF159A93);

  final TextEditingController searchController =
      TextEditingController();

  List<InventoryProduct> products = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadProducts();
  }

  // ==========================
  // LOAD PRODUCTS
  // ==========================

  Future<void> loadProducts() async {
    setState(() {
      isLoading = true;
    });

    final result =
        await ApiService.getAllProducts();

    if (!mounted) return;

    if (result['success'] == true) {
      final List data =
          result['products'] ?? [];

      setState(() {
        products = data
            .map(
              (item) =>
                  InventoryProduct.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();

        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ??
                'Unable to load products',
          ),
        ),
      );
    }
  }

  // ==========================
  // FILTER
  // ==========================

  List<InventoryProduct>
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
              .contains(query);
    }).toList();
  }

  // ==========================
  // LOW STOCK
  // ==========================

  int get lowStockCount {
    return products.where((product) {
      return product.stock > 0 &&
          product.stock <= 10;
    }).length;
  }

  // ==========================
  // OUT OF STOCK
  // ==========================

  int get outOfStockCount {
    return products.where((product) {
      return product.stock == 0;
    }).length;
  }

  // ==========================
  // STOCK COLOR
  // ==========================

  Color stockColor(int stock) {
    if (stock == 0) {
      return Colors.red;
    }

    if (stock <= 10) {
      return Colors.orange;
    }

    return Colors.green;
  }

  // ==========================
  // STOCK STATUS
  // ==========================

  String stockStatus(int stock) {
    if (stock == 0) {
      return 'Out of Stock';
    }

    if (stock <= 10) {
      return 'Low Stock';
    }

    return 'In Stock';
  }

  // ==========================
  // UPDATE STOCK
  // ==========================

  Future<void> updateStock(
    InventoryProduct product,
    int change,
  ) async {
    final newStock =
        product.stock + change;

    if (newStock < 0) {
      return;
    }

    final oldStock = product.stock;

    setState(() {
      product.stock = newStock;
    });

    final result =
        await ApiService.updateProductStock(
      id: product.id,
      stock: newStock,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '${product.name} stock updated to $newStock',
          ),
        ),
      );
    } else {
      setState(() {
        product.stock = oldStock;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ??
                'Unable to update stock',
          ),
        ),
      );
    }
  }

  // ==========================
  // STOCK DIALOG
  // ==========================

  void showStockUpdateDialog(
    InventoryProduct product,
  ) {
    final controller =
        TextEditingController(
      text: product.stock.toString(),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Update Stock',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: TextField(
            controller: controller,
            keyboardType:
                TextInputType.number,
            decoration:
                const InputDecoration(
              labelText: 'Stock Quantity',
              prefixIcon: Icon(
                Icons.inventory_2_outlined,
              ),
              border:
                  OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text('Cancel'),
            ),

            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    primaryColor,
                foregroundColor:
                    Colors.white,
              ),

              onPressed: () async {
                final stock =
                    int.tryParse(
                  controller.text.trim(),
                );

                if (stock == null ||
                    stock < 0) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a valid stock quantity',
                      ),
                    ),
                  );

                  return;
                }

                Navigator.pop(
                  dialogContext,
                );

                final oldStock =
                    product.stock;

                setState(() {
                  product.stock = stock;
                });

                final result =
                    await ApiService
                        .updateProductStock(
                  id: product.id,
                  stock: stock,
                );

                if (!mounted) return;

                if (result['success'] ==
                    true) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Stock updated successfully',
                      ),
                    ),
                  );
                } else {
                  setState(() {
                    product.stock =
                        oldStock;
                  });

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      content: Text(
                        result['message'] ??
                            'Unable to update stock',
                      ),
                    ),
                  );
                }
              },

              child:
                  const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  // ==========================
  // BUILD
  // ==========================

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

        title: const Text(
          'Inventory Management',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
            ),
            onPressed:
                loadProducts,
          ),
        ],
      ),

      body: Column(
        children: [
          // ==========================
          // SUMMARY CARDS
          // ==========================

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              5,
            ),

            child: Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    title: 'Products',
                    value:
                        '${products.length}',
                    icon: Icons
                        .inventory_2_outlined,
                    color:
                        primaryColor,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: _summaryCard(
                    title: 'Low Stock',
                    value:
                        '$lowStockCount',
                    icon: Icons
                        .warning_amber_outlined,
                    color:
                        Colors.orange,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: _summaryCard(
                    title: 'Out',
                    value:
                        '$outOfStockCount',
                    icon: Icons
                        .remove_shopping_cart_outlined,
                    color:
                        Colors.red,
                  ),
                ),
              ],
            ),
          ),

          // ==========================
          // SEARCH
          // ==========================

          Padding(
            padding:
                const EdgeInsets.all(16),

            child: TextField(
              controller:
                  searchController,

              onChanged: (_) {
                setState(() {});
              },

              decoration:
                  InputDecoration(
                hintText:
                    'Search products...',

                prefixIcon:
                    const Icon(
                  Icons.search,
                ),

                suffixIcon:
                    searchController
                            .text
                            .isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController
                                  .clear();

                              setState(() {});
                            },
                            icon:
                                const Icon(
                              Icons.clear,
                            ),
                          )
                        : null,

                filled: true,
                fillColor:
                    Colors.white,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(14),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),
          ),

          // ==========================
          // PRODUCT COUNT
          // ==========================

          Padding(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 16,
            ),

            child: Row(
              children: [
                Text(
                  '${displayedProducts.length} Products',
                  style:
                      const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const Spacer(),

                Text(
                  'Total: ${products.length}',
                  style:
                      const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          // ==========================
          // PRODUCT LIST
          // ==========================

          Expanded(
            child: isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(
                      color:
                          primaryColor,
                    ),
                  )
                : displayedProducts
                        .isEmpty
                    ? const Center(
                        child: Text(
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
                    : ListView.builder(
                        padding:
                            const EdgeInsets
                                .fromLTRB(
                          16,
                          5,
                          16,
                          20,
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

                            elevation: 1,

                            margin:
                                const EdgeInsets
                                    .only(
                              bottom: 12,
                            ),

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                16,
                              ),
                            ),

                            child:
                                Padding(
                              padding:
                                  const EdgeInsets
                                      .all(
                                14,
                              ),

                              child:
                                  Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height:
                                            60,
                                        width:
                                            60,
                                        decoration:
                                            BoxDecoration(
                                          color:
                                              const Color(
                                            0xFFE8F7F5,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child:
                                            const Icon(
                                          Icons
                                              .inventory_2_outlined,
                                          color:
                                              primaryColor,
                                          size:
                                              30,
                                        ),
                                      ),

                                      const SizedBox(
                                        width:
                                            14,
                                      ),

                                      Expanded(
                                        child:
                                            Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product
                                                  .name,
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
                                              product
                                                  .category,
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
                                                  '₹${product.price.toStringAsFixed(0)}',
                                                  style:
                                                      const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),

                                                const SizedBox(
                                                  width:
                                                      12,
                                                ),

                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal:
                                                        8,
                                                    vertical:
                                                        4,
                                                  ),

                                                  decoration:
                                                      BoxDecoration(
                                                    color:
                                                        stockColor(
                                                      product.stock,
                                                    ).withOpacity(
                                                      0.10,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      10,
                                                    ),
                                                  ),

                                                  child:
                                                      Text(
                                                    stockStatus(
                                                      product.stock,
                                                    ),
                                                    style:
                                                        TextStyle(
                                                      color:
                                                          stockColor(
                                                        product.stock,
                                                      ),
                                                      fontSize:
                                                          11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height:
                                        15,
                                  ),

                                  const Divider(),

                                  const SizedBox(
                                    height:
                                        8,
                                  ),

                                  // ==========================
                                  // STOCK CONTROLS
                                  // ==========================

                                  Row(
                                    children: [
                                      const Text(
                                        'Current Stock',
                                        style:
                                            TextStyle(
                                          color:
                                              Colors.grey,
                                        ),
                                      ),

                                      const SizedBox(
                                        width:
                                            8,
                                      ),

                                      Text(
                                        '${product.stock}',
                                        style:
                                            TextStyle(
                                          color:
                                              stockColor(
                                            product.stock,
                                          ),
                                          fontSize:
                                              18,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),

                                      const Spacer(),

                                      IconButton(
                                        onPressed:
                                            product.stock >
                                                    0
                                                ? () {
                                                    updateStock(
                                                      product,
                                                      -1,
                                                    );
                                                  }
                                                : null,

                                        icon:
                                            const Icon(
                                          Icons
                                              .remove,
                                        ),

                                        style:
                                            IconButton
                                                .styleFrom(
                                          backgroundColor:
                                              const Color(
                                            0xFFF1F1F1,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(
                                        width:
                                            6,
                                      ),

                                      IconButton(
                                        onPressed:
                                            () {
                                          updateStock(
                                            product,
                                            1,
                                          );
                                        },

                                        icon:
                                            const Icon(
                                          Icons
                                              .add,
                                        ),

                                        style:
                                            IconButton
                                                .styleFrom(
                                          backgroundColor:
                                              const Color(
                                            0xFFE8F7F5,
                                          ),
                                          foregroundColor:
                                              primaryColor,
                                        ),
                                      ),

                                      const SizedBox(
                                        width:
                                            6,
                                      ),

                                      IconButton(
                                        onPressed:
                                            () {
                                          showStockUpdateDialog(
                                            product,
                                          );
                                        },

                                        icon:
                                            const Icon(
                                          Icons
                                              .edit_outlined,
                                        ),

                                        style:
                                            IconButton
                                                .styleFrom(
                                          backgroundColor:
                                              const Color(
                                            0xFFE8F7F5,
                                          ),
                                          foregroundColor:
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
        ],
      ),
    );
  }

  // ==========================
  // SUMMARY CARD
  // ==========================

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(12),

      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            color: color,
            size: 25,
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            value,
            style:
                const TextStyle(
              fontSize: 19,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          Text(
            title,
            style:
                const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}