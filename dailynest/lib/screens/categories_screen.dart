import 'package:flutter/material.dart';
import 'products_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const Color primaryColor = Color(0xFF00897B);

  final List<Map<String, dynamic>> categories = const [
    {
      'name': 'Milk & Dairy',
      'image': 'assets/products/milk_dairy.png',
      'icon': Icons.local_drink_outlined,
    },
    {
      'name': 'Fruits',
      'image': 'assets/products/fruits.png',
      'icon': Icons.apple_outlined,
    },
    {
      'name': 'Vegetables',
      'image': 'assets/products/vegetables.png',
      'icon': Icons.eco_outlined,
    },
    {
      'name': 'Grocery',
      'image': 'assets/products/grocery.png',
      'icon': Icons.shopping_basket_outlined,
    },
    {
      'name': 'Bakery',
      'image': 'assets/products/bakery.png',
      'icon': Icons.bakery_dining_outlined,
    },
    {
      'name': 'Beverages',
      'image': 'assets/products/beverages.png',
      'icon': Icons.coffee_outlined,
    },
    {
      'name': 'Household',
      'image': 'assets/products/household.png',
      'icon': Icons.cleaning_services_outlined,
    },
    {
      'name': 'Snacks',
      'image': 'assets/products/snacks.png',
      'icon': Icons.fastfood_outlined,
    },
    {
      'name': 'Baby Care',
      'image': 'assets/products/baby_care.png',
      'icon': Icons.child_care_outlined,
    },
    {
      'name': 'Personal Care',
      'image': 'assets/products/personal_care.png',
      'icon': Icons.face_outlined,
    },
    {
      'name': 'Pet Care',
      'image': 'assets/products/pet_care.png',
      'icon': Icons.pets_outlined,
    },
    {
      'name': 'Daily Essentials',
      'image': 'assets/products/daily_essentials.png',
      'icon': Icons.inventory_2_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),

        child: GridView.builder(
          padding: const
          EdgeInsets.only(bottom: 20),
          itemCount: categories.length,

          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.40,
          ),

          itemBuilder: (context, index) {
            final category = categories[index];

            return InkWell(
              borderRadius: BorderRadius.circular(16),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductsScreen(
                      categoryName: category['name'],
                    ),
                  ),
                );
              },

              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),

                  border: Border.all(
                    color: primaryColor.withOpacity(0.12),
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // CATEGORY IMAGE
                    Container(
  width: 115,
  height: 115,

  decoration: BoxDecoration(
    color: const Color(0xFFF2FAF8),
    borderRadius: BorderRadius.circular(18),
  ),

  child: ClipRRect(
    borderRadius: BorderRadius.circular(18),

    child: Transform.scale(
      scale: 1.25,

      child: Image.asset(
        category['image'],
        fit: BoxFit.contain,

        errorBuilder: (context, error, stackTrace) {
          return Icon(
            category['icon'],
            size: 50,
            color: primaryColor,
          );
        },
      ),
    ),
  ),
),

                    const SizedBox(height: 8),

                    // CATEGORY NAME
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                      ),

                      child: Text(
                        category['name'],

                        textAlign: TextAlign.center,

                        maxLines: 2,

                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}