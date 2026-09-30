import 'package:flutter/material.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  static const Color primaryColor = Color(0xFF159A93);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          'Reports & Analytics',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ==========================
            // SUMMARY CARDS
            // ==========================

            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: const [
                _ReportCard(
                  title: 'Total Revenue',
                  value: '₹45,680',
                  icon: Icons.currency_rupee,
                ),
                _ReportCard(
                  title: 'Total Orders',
                  value: '82',
                  icon: Icons.shopping_bag_outlined,
                ),
                _ReportCard(
                  title: 'Customers',
                  value: '156',
                  icon: Icons.people_outline,
                ),
                _ReportCard(
                  title: 'Products',
                  value: '24',
                  icon: Icons.inventory_2_outlined,
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ==========================
            // SALES OVERVIEW
            // ==========================

            const Text(
              'Sales Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            Card(
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Weekly Revenue',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F7F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '+12.5%',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      height: 180,
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.end,
                        mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                        children: [
                          _bar('Mon', 0.45, '₹4.2K'),
                          _bar('Tue', 0.60, '₹5.8K'),
                          _bar('Wed', 0.40, '₹3.9K'),
                          _bar('Thu', 0.75, '₹7.1K'),
                          _bar('Fri', 0.55, '₹5.2K'),
                          _bar('Sat', 0.90, '₹8.6K'),
                          _bar('Sun', 0.70, '₹6.7K'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ==========================
            // ORDER STATUS
            // ==========================

            const Text(
              'Order Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            Card(
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _statRow(
                      'Delivered',
                      '52',
                      Colors.green,
                      0.63,
                    ),
                    const SizedBox(height: 18),
                    _statRow(
                      'Processing',
                      '15',
                      Colors.orange,
                      0.18,
                    ),
                    const SizedBox(height: 18),
                    _statRow(
                      'Pending',
                      '10',
                      Colors.blue,
                      0.12,
                    ),
                    const SizedBox(height: 18),
                    _statRow(
                      'Cancelled',
                      '5',
                      Colors.red,
                      0.07,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ==========================
            // TOP PRODUCTS
            // ==========================

            const Text(
              'Top Selling Products',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            _productTile(
              rank: '1',
              name: 'Amul Taaza Milk',
              category: 'Milk & Dairy',
              sold: '128 sold',
              revenue: '₹3,840',
            ),

            _productTile(
              rank: '2',
              name: 'Fresh Bananas',
              category: 'Fruits',
              sold: '96 sold',
              revenue: '₹4,800',
            ),

            _productTile(
              rank: '3',
              name: 'Fresh Tomatoes',
              category: 'Vegetables',
              sold: '84 sold',
              revenue: '₹3,360',
            ),

            _productTile(
              rank: '4',
              name: 'Aashirvaad Atta',
              category: 'Grocery',
              sold: '62 sold',
              revenue: '₹17,360',
            ),

            const SizedBox(height: 28),

            // ==========================
            // LOW STOCK
            // ==========================

            const Text(
              'Low Stock Products',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            _stockTile(
              name: 'Brown Bread',
              stock: '6 units left',
              icon: Icons.bakery_dining_outlined,
            ),

            _stockTile(
              name: 'Aashirvaad Atta',
              stock: '12 units left',
              icon: Icons.shopping_bag_outlined,
            ),

            _stockTile(
              name: 'Fresh Tomatoes',
              stock: '18 units left',
              icon: Icons.eco_outlined,
            ),

            const SizedBox(height: 20),

            // ==========================
            // CUSTOMER STATISTICS
            // ==========================

            const Text(
              'Customer Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            Card(
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Expanded(
                      child: _customerStat(
                        '156',
                        'Total Customers',
                        Icons.people_outline,
                      ),
                    ),
                    Container(
                      height: 60,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: _customerStat(
                        '42',
                        'New This Month',
                        Icons.person_add_outlined,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==========================
  // BAR
  // ==========================

  static Widget _bar(
    String day,
    double height,
    String value,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 5),

        Container(
          width: 25,
          height: 120 * height,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
            ),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          day,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // ==========================
  // STAT ROW
  // ==========================

  static Widget _statRow(
    String title,
    String value,
    Color color,
    double progress,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 10),

            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const Spacer(),

            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        LinearProgressIndicator(
          value: progress,
          minHeight: 7,
          borderRadius: BorderRadius.circular(10),
          color: color,
          backgroundColor: Colors.grey.shade200,
        ),
      ],
    );
  }

  // ==========================
  // PRODUCT TILE
  // ==========================

  static Widget _productTile({
    required String rank,
    required String name,
    required String category,
    required String sold,
    required String revenue,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE8F7F5),
          child: Text(
            rank,
            style: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          '$category • $sold',
        ),

        trailing: Text(
          revenue,
          style: const TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ==========================
  // STOCK TILE
  // ==========================

  static Widget _stockTile({
    required String name,
    required String stock,
    required IconData icon,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.red,
          ),
        ),

        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: const Text(
          'Inventory needs attention',
        ),

        trailing: Text(
          stock,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ==========================
  // CUSTOMER STAT
  // ==========================

  static Widget _customerStat(
    String value,
    String title,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: primaryColor,
          size: 28,
        ),

        const SizedBox(height: 8),

        Text(
          value,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// =====================================
// REPORT CARD
// =====================================

class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ReportCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  static const Color primaryColor = Color(0xFF159A93);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: primaryColor,
              size: 27,
            ),

            const Spacer(),

            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}