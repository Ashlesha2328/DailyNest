import 'package:flutter/material.dart';

class AdminCoupon {
  String code;
  String title;
  String discount;
  String expiry;
  bool active;

  AdminCoupon({
    required this.code,
    required this.title,
    required this.discount,
    required this.expiry,
    required this.active,
  });
}

class AdminCouponsScreen extends StatefulWidget {
  const AdminCouponsScreen({super.key});

  @override
  State<AdminCouponsScreen> createState() => _AdminCouponsScreenState();
}

class _AdminCouponsScreenState extends State<AdminCouponsScreen> {
  static const Color primaryColor = Color(0xFF159A93);

  final TextEditingController searchController = TextEditingController();

  final List<AdminCoupon> coupons = [
    AdminCoupon(
      code: 'WELCOME50',
      title: 'Welcome Offer',
      discount: '₹50 OFF',
      expiry: '30 Sep 2026',
      active: true,
    ),
    AdminCoupon(
      code: 'DAILY20',
      title: 'Daily Essentials',
      discount: '20% OFF',
      expiry: '15 Oct 2026',
      active: true,
    ),
    AdminCoupon(
      code: 'FRESH100',
      title: 'Fresh Grocery Offer',
      discount: '₹100 OFF',
      expiry: '31 Oct 2026',
      active: true,
    ),
    AdminCoupon(
      code: 'SAVE10',
      title: 'Special Discount',
      discount: '10% OFF',
      expiry: '10 Nov 2026',
      active: false,
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<AdminCoupon> get filteredCoupons {
    final query = searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      return coupons;
    }

    return coupons.where((coupon) {
      return coupon.code.toLowerCase().contains(query) ||
          coupon.title.toLowerCase().contains(query);
    }).toList();
  }

  void showCouponDialog({AdminCoupon? coupon}) {
    final codeController = TextEditingController(
      text: coupon?.code ?? '',
    );

    final titleController = TextEditingController(
      text: coupon?.title ?? '',
    );

    final discountController = TextEditingController(
      text: coupon?.discount ?? '',
    );

    final expiryController = TextEditingController(
      text: coupon?.expiry ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            coupon == null ? 'Add Coupon' : 'Edit Coupon',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Coupon Code',
                    prefixIcon: Icon(Icons.confirmation_number_outlined),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Offer Title',
                    prefixIcon: Icon(Icons.local_offer_outlined),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: discountController,
                  decoration: const InputDecoration(
                    labelText: 'Discount',
                    hintText: 'Example: 20% OFF / ₹100 OFF',
                    prefixIcon: Icon(Icons.percent),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: expiryController,
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date',
                    hintText: 'Example: 30 Sep 2026',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final code = codeController.text.trim().toUpperCase();
                final title = titleController.text.trim();
                final discount = discountController.text.trim();
                final expiry = expiryController.text.trim();

                if (code.isEmpty ||
                    title.isEmpty ||
                    discount.isEmpty ||
                    expiry.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter all coupon details',
                      ),
                    ),
                  );
                  return;
                }

                setState(() {
                  if (coupon == null) {
                    coupons.add(
                      AdminCoupon(
                        code: code,
                        title: title,
                        discount: discount,
                        expiry: expiry,
                        active: true,
                      ),
                    );
                  } else {
                    coupon.code = code;
                    coupon.title = title;
                    coupon.discount = discount;
                    coupon.expiry = expiry;
                  }
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      coupon == null
                          ? 'Coupon added successfully'
                          : 'Coupon updated successfully',
                    ),
                  ),
                );
              },
              child: Text(
                coupon == null ? 'Add Coupon' : 'Update',
              ),
            ),
          ],
        );
      },
    );
  }

  void deleteCoupon(AdminCoupon coupon) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Coupon',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${coupon.code}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  coupons.remove(coupon);
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Coupon deleted successfully',
                    ),
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedCoupons = filteredCoupons;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,

        title: const Text(
          'Coupons & Offers',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              showCouponDialog();
            },
            icon: const Icon(Icons.add),
            tooltip: 'Add Coupon',
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          showCouponDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Coupon'),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search coupons...',
                prefixIcon: const Icon(Icons.search),

                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                Text(
                  '${displayedCoupons.length} Coupons',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                Text(
                  'Total: ${coupons.length}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: displayedCoupons.isEmpty
                ? const Center(
                    child: Text(
                      'No coupons found',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      5,
                      16,
                      100,
                    ),
                    itemCount: displayedCoupons.length,
                    itemBuilder: (context, index) {
                      final coupon = displayedCoupons[index];

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Container(
                                height: 55,
                                width: 55,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F7F5),
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.local_offer_outlined,
                                  color: primaryColor,
                                  size: 28,
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      coupon.code,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      coupon.title,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),

                                    const SizedBox(height: 7),

                                    Row(
                                      children: [
                                        Text(
                                          coupon.discount,
                                          style: const TextStyle(
                                            color: primaryColor,
                                            fontWeight:
                                                FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),

                                        const SizedBox(width: 15),

                                        Text(
                                          'Exp: ${coupon.expiry}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              Column(
                                children: [
                                  Switch(
                                    value: coupon.active,
                                    activeThumbColor: primaryColor,
                                    onChanged: (value) {
                                      setState(() {
                                        coupon.active = value;
                                      });
                                    },
                                  ),

                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        showCouponDialog(
                                          coupon: coupon,
                                        );
                                      }

                                      if (value == 'delete') {
                                        deleteCoupon(coupon);
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit_outlined,
                                            ),
                                            SizedBox(width: 10),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),

                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 10),
                                            Text('Delete'),
                                          ],
                                        ),
                                      ),
                                    ],
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
}