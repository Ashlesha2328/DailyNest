import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/subscription_screen.dart';

import 'cart_data.dart';

void main() {
  runApp(const DailyNestApp());
}

class DailyNestApp extends StatelessWidget {
  const DailyNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DailyNest',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
        useMaterial3: true,
      ),

      home: const LoginScreen(),
    );
  }
}

// =====================================
// MAIN NAVIGATION
// =====================================

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}

class _MainNavigationState
    extends State<MainNavigation> {

  int selectedIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    CategoriesScreen(),
    OrdersScreen(),
    CartScreen(),
    SubscriptionsScreen(),
  ];

  // =====================================
  // CART COUNT
  // =====================================

  int get cartCount {
    int count = 0;

    for (final item in CartData.items) {
      count += item.quantity;
    }

    return count;
  }

  // =====================================
  // CART ICON WITH BADGE
  // =====================================

  Widget buildCartIcon({
    required bool selected,
  }) {
    return ValueListenableBuilder<int>(
      valueListenable: CartData.cartVersion,

      builder: (context, version, child) {
        final int count = cartCount;

        // No products
        if (count == 0) {
          return Icon(
            selected
                ? Icons.shopping_cart
                : Icons.shopping_cart_outlined,
          );
        }

        // Products added
        return Badge(
          backgroundColor: Colors.red,
          textColor: Colors.white,

          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 2,
          ),

          label: Text(
            count > 99 ? '99+' : '$count',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),

          child: Icon(
            selected
                ? Icons.shopping_cart
                : Icons.shopping_cart_outlined,
          ),
        );
      },
    );
  }

  // =====================================
  // BUILD
  // =====================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,

        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        destinations: [
          // HOME
          const NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),

          // CATEGORIES
          const NavigationDestination(
            icon: Icon(
              Icons.category_outlined,
            ),
            selectedIcon: Icon(
              Icons.category,
            ),
            label: 'Categories',
          ),

          // ORDERS
          const NavigationDestination(
            icon: Icon(
              Icons.receipt_long_outlined,
            ),
            selectedIcon: Icon(
              Icons.receipt_long,
            ),
            label: 'Orders',
          ),

          // CART
          NavigationDestination(
            icon: buildCartIcon(
              selected: false,
            ),

            selectedIcon: buildCartIcon(
              selected: true,
            ),

            label: 'Cart',
          ),

          // SUBSCRIPTION
          const NavigationDestination(
            icon: Icon(
              Icons.repeat_outlined,
            ),
            selectedIcon: Icon(
              Icons.repeat,
            ),
            label: 'Subscription',
          ),
        ],
      ),
    );
  }
}