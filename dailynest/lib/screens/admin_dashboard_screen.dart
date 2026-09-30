import 'package:flutter/material.dart';

import '../services/api_service.dart';

import 'admin_products_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_users_screen.dart';
import 'admin_inventory_screen.dart';
import 'admin_categories_screen.dart';
import 'admin_subscriptions_screen.dart';
import 'admin_coupons_screen.dart';
import 'admin_delivery_slots_screen.dart';
import 'admin_service_areas_screen.dart';
import 'admin_payments_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_customers_screen.dart';
import 'admin_delivery_partners_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const Color primaryColor = Color(0xFF159A93);

  int products = 0;
  int customers = 0;
  int orders = 0;
  double revenue = 0;

  bool isLoading = true;

  List<dynamic> recentOrders = [];
  bool isOrdersLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  // ============================================================
  // LOAD DASHBOARD DATA
  // ============================================================

  Future<void> loadDashboardData() async {
    await Future.wait([
      loadDashboardStats(),
      loadRecentOrders(),
    ]);
  }

  // ============================================================
  // LOAD STATISTICS
  // ============================================================

  Future<void> loadDashboardStats() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    final result = await ApiService.getDashboardStats();

    if (!mounted) return;

    if (result['success'] == true) {
      final stats = result['stats'] ?? {};

      setState(() {
        products =
            int.tryParse('${stats['products'] ?? 0}') ?? 0;

        customers =
            int.tryParse('${stats['customers'] ?? 0}') ?? 0;

        orders =
            int.tryParse('${stats['orders'] ?? 0}') ?? 0;

        revenue =
            double.tryParse('${stats['revenue'] ?? 0}') ?? 0;

        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ============================================================
  // LOAD RECENT ORDERS
  // ============================================================

  Future<void> loadRecentOrders() async {
    if (mounted) {
      setState(() {
        isOrdersLoading = true;
      });
    }

    final result = await ApiService.getAllOrders();

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        recentOrders =
            List<dynamic>.from(result['orders'] ?? []);

        isOrdersLoading = false;
      });
    } else {
      setState(() {
        recentOrders = [];
        isOrdersLoading = false;
      });
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,

        centerTitle: false,

        leading: IconButton(
          icon: const Icon(
            Icons.menu_rounded,
            color: Colors.black87,
            size: 30,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Admin menu'),
              ),
            );
          },
        ),

        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.black87,
              size: 28,
            ),
            onPressed: refreshDashboard,
          ),

          IconButton(
            tooltip: 'Logout',
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.black87,
              size: 28,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          const SizedBox(width: 6),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: refreshDashboard,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            30,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // WELCOME
              // ==================================================

              const Text(
                'Welcome, Admin 👋',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Manage your DailyNest application',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // BANNER
              // ==================================================

              _buildBanner(),

              const SizedBox(height: 22),

              // ==================================================
              // STATISTICS
              // ==================================================

              _buildStatistics(),

              const SizedBox(height: 28),

              // ==================================================
              // QUICK ACTIONS
              // ==================================================

              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 14),

              _actionTile(
                context,
                icon: Icons.add_box_rounded,
                title: 'Add Product',
                subtitle: 'Add a new product',
                iconColor: const Color(0xFF159A93),
                iconBackground: const Color(0xFFDDF5EA),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminProductsScreen(),
                    ),
                  );
                },
              ),

              _actionTile(
                context,
                icon: Icons.shopping_cart_rounded,
                title: 'Manage Products',
                subtitle: 'View, edit or delete products',
                iconColor: const Color(0xFF00897B),
                iconBackground: const Color(0xFFE0F2F1),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminProductsScreen(),
                    ),
                  );
                },
              ),

              _actionTile(
                context,
                icon: Icons.inventory_2_rounded,
                title: 'Manage Orders',
                subtitle: 'View and update orders',
                iconColor: const Color(0xFFEF8A17),
                iconBackground: const Color(0xFFFFEEDB),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminOrdersScreen(),
                    ),
                  );
                },
              ),

              _actionTile(
                context,
                icon: Icons.people_rounded,
                title: 'Manage Users',
                subtitle: 'View registered users',
                iconColor: const Color(0xFF1976D2),
                iconBackground: const Color(0xFFE1F0FF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminUsersScreen(),
                    ),
                  );
                },
              ),

              _actionTile(
                context,
                icon: Icons.person_search_rounded,
                title: 'Manage Customers',
                subtitle: 'View customer details',
                iconColor: const Color(0xFF7E57C2),
                iconBackground: const Color(0xFFF0E8FF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminCustomersScreen(),
                    ),
                  );
                },
              ),

              _actionTile(
                context,
                icon: Icons.delivery_dining_rounded,
                title: 'Manage Delivery Partners',
                subtitle: 'Manage delivery boys and assignments',
                iconColor: const Color(0xFF00838F),
                iconBackground: const Color(0xFFE0F7FA),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminDeliveryPartnersScreen(),
                    ),
                  );
                },
              ),

              _actionTile(
                context,
                icon: Icons.inventory_rounded,
                title: 'Manage Inventory',
                subtitle: 'View and update product stock',
                iconColor: const Color(0xFF43A047),
                iconBackground: const Color(0xFFE8F5E9),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminInventoryScreen(),
                    ),
                  );
                },
              ),

              _actionTile(
                context,
                icon: Icons.autorenew_rounded,
                title: 'Manage Subscriptions',
                subtitle: 'View and update subscriptions',
                iconColor: const Color(0xFF8E24AA),
                iconBackground: const Color(0xFFF3E5F5),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminSubscriptionsScreen(),
                    ),
                  );
                },
              ),

              _actionTile(
                context,
                icon: Icons.local_offer_rounded,
                title: 'Manage Coupons & Offers',
                subtitle: 'Create and manage promotional coupons',
                iconColor: const Color(0xFFE53935),
                iconBackground: const Color(0xFFFFEBEE),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminCouponsScreen(),
                    ),
                  );
                },
              ),

              _actionTile(
                context,
                icon: Icons.access_time_filled_rounded,
                title: 'Manage Delivery Slots',
                subtitle: 'Manage delivery time slots and capacity',
                iconColor: const Color(0xFFFB8C00),
                iconBackground: const Color(0xFFFFF3E0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminDeliverySlotsScreen(),
                    ),
                  );
                },
              ),

              _actionTile(
                context,
                icon: Icons.location_on_rounded,
                title: 'Manage Service Areas',
                subtitle: 'Manage pincodes and delivery availability',
                iconColor: const Color(0xFF3949AB),
                iconBackground: const Color(0xFFE8EAF6),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminServiceAreasScreen(),
                    ),
                  );
                },
              ),

              _actionTile(
                context,
                icon: Icons.payments_rounded,
                title: 'Payments & Refunds',
                subtitle: 'Manage payments and process refunds',
                iconColor: const Color(0xFF00897B),
                iconBackground: const Color(0xFFE0F2F1),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminPaymentsScreen(),
                    ),
                  );
                },
              ),

              _actionTile(
                context,
                icon: Icons.analytics_rounded,
                title: 'Reports & Analytics',
                subtitle: 'View sales, orders and business reports',
                iconColor: const Color(0xFF5E35B1),
                iconBackground: const Color(0xFFEDE7F6),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminReportsScreen(),
                    ),
                  );
                },
              ),

              _actionTile(
                context,
                icon: Icons.category_rounded,
                title: 'Manage Categories',
                subtitle: 'Add, edit or delete categories',
                iconColor: const Color(0xFF6D4C41),
                iconBackground: const Color(0xFFEFEBE9),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminCategoriesScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ==================================================
              // RECENT ORDERS
              // ==================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Orders',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  if (recentOrders.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AdminOrdersScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              if (isOrdersLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(25),
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  ),
                )
              else if (recentOrders.isEmpty)
                _buildEmptyOrders()
              else
                Column(
                  children: recentOrders
                      .take(5)
                      .map(
                        (order) => _realOrderTile(order),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BANNER
  // ============================================================

  Widget _buildBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),

      child: Container(
        width: double.infinity,

        decoration: BoxDecoration(
          color: const Color(0xFFE8F7F5),
          borderRadius: BorderRadius.circular(20),
        ),

        child: Image.asset(
          'assets/images/dailynest_banner.png',

          width: double.infinity,

          fit: BoxFit.contain,

          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return Container(
              height: 180,

              decoration: BoxDecoration(
                color: const Color(0xFFE8F7F5),
                borderRadius: BorderRadius.circular(20),
              ),

              child: const Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 55,
                  color: primaryColor,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  Widget _buildStatistics() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DashboardCard(
                title: 'Products',
                value: isLoading
                    ? '...'
                    : products.toString(),
                imagePath:
                    'assets/images/products_dashboard.jpeg',
                backgroundColor:
                    const Color(0xFFF0FBF7),
                iconBackground:
                    const Color(0xFFDDF5EA),
                accentColor:
                    const Color(0xFF159A93),
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: DashboardCard(
                title: 'Users',
                value: isLoading
                    ? '...'
                    : customers.toString(),
                imagePath:
                    'assets/images/users_dashboard.jpeg',
                backgroundColor:
                    const Color(0xFFF2F7FF),
                iconBackground:
                    const Color(0xFFE1F0FF),
                accentColor:
                    const Color(0xFF1976D2),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        Row(
          children: [
            Expanded(
              child: DashboardCard(
                title: 'Orders',
                value: isLoading
                    ? '...'
                    : orders.toString(),
                imagePath:
                    'assets/images/orders_dashboard.jpeg',
                backgroundColor:
                    const Color(0xFFFFF7EF),
                iconBackground:
                    const Color(0xFFFFEEDB),
                accentColor:
                    const Color(0xFFEF8A17),
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: DashboardCard(
                title: 'Revenue',
                value: isLoading
                    ? '...'
                    : '₹${revenue.toStringAsFixed(0)}',
                imagePath:
                    'assets/images/revenue_dashboard.jpeg',
                backgroundColor:
                    const Color(0xFFF1FBF3),
                iconBackground:
                    const Color(0xFFE4F6E8),
                accentColor:
                    const Color(0xFF3B9B55),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // ACTION TILE
  // ============================================================

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color iconBackground,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: Colors.grey.shade200,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 7,
        ),

        leading: Container(
          height: 58,
          width: 58,

          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(16),
          ),

          child: Icon(
            icon,
            color: iconColor,
            size: 30,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),

          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ),

        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Colors.grey.shade600,
          size: 29,
        ),

        onTap: onTap,
      ),
    );
  }

  // ============================================================
  // EMPTY ORDERS
  // ============================================================

  Widget _buildEmptyOrders() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(28),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: Column(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 10),

          Text(
            'No orders found',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REAL ORDER TILE
  // ============================================================

  Widget _realOrderTile(dynamic order) {
    final orderId = order['id'] ?? '';

    final customer =
        order['customer_name'] ?? 'Customer';

    final amount =
        double.tryParse(
              '${order['total_amount'] ?? 0}',
            ) ??
            0;

    final status =
        order['order_status'] ?? 'Placed';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 5,
        ),

        leading: Container(
          height: 48,
          width: 48,

          decoration: BoxDecoration(
            color: const Color(0xFFE8F7F5),
            borderRadius: BorderRadius.circular(14),
          ),

          child: const Icon(
            Icons.shopping_bag_outlined,
            color: primaryColor,
          ),
        ),

        title: Text(
          '#DN$orderId',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          customer.toString(),
        ),

        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,

          children: [
            Text(
              '₹${amount.toStringAsFixed(0)}',

              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 4),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),

              decoration: BoxDecoration(
                color: _statusColor(
                  status.toString(),
                ).withOpacity(0.1),

                borderRadius:
                    BorderRadius.circular(10),
              ),

              child: Text(
                status.toString(),

                style: TextStyle(
                  color: _statusColor(
                    status.toString(),
                  ),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        onTap: () {
          _showOrderDetails(order);
        },
      ),
    );
  }

  // ============================================================
  // ORDER DETAILS
  // ============================================================

  void _showOrderDetails(dynamic order) {
    showDialog(
      context: context,

      builder: (dialogContext) {
        final items =
            List<dynamic>.from(order['items'] ?? []);

        final orderId = order['id'] ?? '';

        final customer =
            order['customer_name'] ?? 'Customer';

        final email =
            order['customer_email'] ?? '';

        final mobile =
            order['customer_mobile'] ?? '';

        final subtotal =
            double.tryParse(
                  '${order['subtotal'] ?? 0}',
                ) ??
                0;

        final deliveryCharge =
            double.tryParse(
                  '${order['delivery_charge'] ?? 0}',
                ) ??
                0;

        final tax =
            double.tryParse(
                  '${order['tax'] ?? 0}',
                ) ??
                0;

        final discount =
            double.tryParse(
                  '${order['discount'] ?? 0}',
                ) ??
                0;

        final total =
            double.tryParse(
                  '${order['total_amount'] ?? 0}',
                ) ??
                0;

        final paymentMethod =
            order['payment_method'] ??
                'Cash on Delivery';

        final status =
            order['order_status'] ??
                'Placed';

        final address =
            order['delivery_address'] ??
                'Not available';

        final deliveryDate =
            order['delivery_date'] ??
                'Not selected';

        final deliverySlot =
            order['delivery_slot'] ??
                'Not selected';

        return Dialog(
          insetPadding:
              const EdgeInsets.all(18),

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),

          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 600,
              maxHeight: 720,
            ),

            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // HEADER

                  Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,

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

                        child: const Icon(
                          Icons
                              .shopping_bag_outlined,
                          color:
                              primaryColor,
                          size: 27,
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
                              '#DN$orderId',
                              style:
                                  const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 3,
                            ),

                            Text(
                              customer.toString(),
                              style:
                                  const TextStyle(
                                color:
                                    Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        icon:
                            const Icon(
                          Icons.close,
                        ),
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },
                      ),
                    ],
                  ),

                  const Divider(
                    height: 30,
                  ),

                  // CUSTOMER

                  const Text(
                    'Customer Details',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _detailRow(
                    Icons.person_outline,
                    'Name',
                    customer.toString(),
                  ),

                  if (email
                      .toString()
                      .isNotEmpty)
                    _detailRow(
                      Icons.email_outlined,
                      'Email',
                      email.toString(),
                    ),

                  if (mobile
                      .toString()
                      .isNotEmpty)
                    _detailRow(
                      Icons.phone_outlined,
                      'Mobile',
                      '+91 ${mobile.toString()}',
                    ),

                  const SizedBox(
                    height: 18,
                  ),

                  // STATUS

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [
                      const Text(
                        'Order Status',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              _statusColor(
                            status.toString(),
                          ).withOpacity(
                            0.1,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),

                        child: Text(
                          status.toString(),
                          style: TextStyle(
                            color:
                                _statusColor(
                              status.toString(),
                            ),
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // ITEMS

                  const Text(
                    'Order Items',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  if (items.isEmpty)
                    const Text(
                      'No items found',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    )
                  else
                    Column(
                      children:
                          items.map((item) {
                        final name =
                            item[
                                    'product_name'] ??
                                'Product';

                        final quantity =
                            item[
                                    'quantity'] ??
                                1;

                        final price =
                            double.tryParse(
                                  '${item['price'] ?? 0}',
                                ) ??
                                0;

                        return Container(
                          margin:
                              const EdgeInsets
                                  .only(
                            bottom: 8,
                          ),

                          padding:
                              const EdgeInsets
                                  .all(12),

                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFF7F9F9,
                            ),

                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
                          ),

                          child: Row(
                            children: [
                              Container(
                                height: 45,
                                width: 45,

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
                                    const Icon(
                                  Icons
                                      .shopping_bag_outlined,
                                  color:
                                      primaryColor,
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
                                      name.toString(),
                                      maxLines: 2,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 4,
                                    ),

                                    Text(
                                      'Qty: $quantity',
                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Text(
                                '₹${price.toStringAsFixed(0)}',
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(
                    height: 18,
                  ),

                  // DELIVERY

                  const Text(
                    'Delivery Details',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _detailRow(
                    Icons.location_on_outlined,
                    'Address',
                    address.toString(),
                  ),

                  _detailRow(
                    Icons.calendar_today_outlined,
                    'Delivery Date',
                    deliveryDate.toString(),
                  ),

                  _detailRow(
                    Icons.access_time_outlined,
                    'Delivery Slot',
                    deliverySlot.toString(),
                  ),

                  _detailRow(
                    Icons.payment_outlined,
                    'Payment',
                    paymentMethod.toString(),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // PRICE SUMMARY

                  const Text(
                    'Price Summary',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _priceRow(
                    'Subtotal',
                    subtotal,
                  ),

                  _priceRow(
                    'Delivery Charge',
                    deliveryCharge,
                  ),

                  _priceRow(
                    'Tax',
                    tax,
                  ),

                  if (discount > 0)
                    _priceRow(
                      'Discount',
                      -discount,
                    ),

                  const Divider(
                    height: 20,
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
                        '₹${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              primaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  SizedBox(
                    width:
                        double.infinity,

                    child:
                        ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          dialogContext,
                        );
                      },

                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            primaryColor,
                        foregroundColor:
                            Colors.white,
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 14,
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
                        'Close',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 10),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            size: 19,
            color: primaryColor,
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 110,

            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight:
                    FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRICE ROW
  // ============================================================

  Widget _priceRow(
    String title,
    double amount,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 8),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          Text(
            amount < 0
                ? '-₹${amount.abs().toStringAsFixed(0)}'
                : '₹${amount.toStringAsFixed(0)}',

            style: const TextStyle(
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;

      case 'Cancelled':
        return Colors.red;

      case 'Processing':
        return Colors.orange;

      case 'Out for Delivery':
        return Colors.blue;

      case 'Placed':
      default:
        return primaryColor;
    }
  }
}

// =================================================================
// DASHBOARD CARD
// =================================================================

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String imagePath;

  final Color backgroundColor;
  final Color iconBackground;
  final Color accentColor;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.imagePath,
    required this.backgroundColor,
    required this.iconBackground,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125,

      decoration: BoxDecoration(
        color: backgroundColor,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(14),

        child: Row(
          children: [
            // ====================================================
            // LEFT IMAGE
            // ====================================================

            Container(
              height: 82,
              width: 82,

              padding:
                  const EdgeInsets.all(8),

              decoration: BoxDecoration(
                color: iconBackground,

                borderRadius:
                    BorderRadius.circular(18),
              ),

              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(12),

                child: Image.asset(
                  imagePath,

                  fit: BoxFit.contain,

                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Icon(
                      _getIcon(),
                      size: 38,
                      color: accentColor,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 14),

            // ====================================================
            // RIGHT COUNT + LABEL
            // ====================================================

            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    value,

                    maxLines: 1,

                    overflow:
                        TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    title,

                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w500,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (title) {
      case 'Products':
        return Icons.shopping_basket_rounded;

      case 'Users':
        return Icons.people_rounded;

      case 'Orders':
        return Icons.inventory_2_rounded;

      case 'Revenue':
        return Icons.currency_rupee_rounded;

      default:
        return Icons.dashboard_rounded;
    }
  }
}