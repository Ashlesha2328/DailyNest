import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // =====================================================
  // BASE URL
  // =====================================================

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    } else {
      return 'http://10.0.2.2:5000';
    }
  }

  // =====================================================
  // LOGIN API
  // =====================================================

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
          'otp': data['otp'],
          'expiresIn': data['expiresIn'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Login failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // REGISTER API
  // =====================================================

  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String mobile,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'mobile': mobile,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
          'otp': data['otp'],
          'expiresIn': data['expiresIn'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Registration failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // GENERATE OTP API
  // =====================================================

  static Future<Map<String, dynamic>> generateOtp({
    required String email,
    required String mobile,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/generate-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'mobile': mobile,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'otp': data['otp'],
          'expiresIn': data['expiresIn'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'OTP generation failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // VERIFY OTP API
  // =====================================================

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String mobile,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'mobile': mobile,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ?? 'OTP verification failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // ADD DELIVERY ADDRESS API
  // =====================================================

  static Future<Map<String, dynamic>> addAddress({
    required int userId,
    required String fullName,
    required String mobile,
    required String houseFlatBuilding,
    required String areaLocality,
    required String city,
    required String pincode,
    required String addressType,
    required bool isDefault,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/addresses'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'full_name': fullName,
          'mobile': mobile,
          'house_flat_building': houseFlatBuilding,
          'area_locality': areaLocality,
          'city': city,
          'pincode': pincode,
          'address_type': addressType,
          'is_default': isDefault,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'address': data['address'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ?? 'Unable to save address',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // GET SAVED ADDRESSES API
  // =====================================================

  static Future<Map<String, dynamic>> getAddresses({
    required int userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/addresses/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'addresses': data['addresses'] ?? [],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ?? 'Unable to fetch addresses',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // DELETE ADDRESS API
  // =====================================================

  static Future<Map<String, dynamic>> deleteAddress({
    required int addressId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/addresses/$addressId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ?? 'Unable to delete address',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // SET DEFAULT ADDRESS API
  // =====================================================

  static Future<Map<String, dynamic>> setDefaultAddress({
    required int addressId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(
          '$baseUrl/api/addresses/$addressId/default',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'address': data['address'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ?? 'Unable to set default address',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // ADD TO CART API
  // =====================================================

  static Future<Map<String, dynamic>> addToCart({
    required int userId,
    required int productId,
    required String productName,
    String? productImage,
    required double price,
    int quantity = 1,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/cart'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'product_id': productId,
          'product_name': productName,
          'product_image': productImage,
          'price': price,
          'quantity': quantity,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'cartItem': data['cartItem'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ?? 'Unable to add to cart',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // GET CART API
  // =====================================================

  static Future<Map<String, dynamic>> getCart({
    required int userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/cart/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'cart': data['cart'] ?? [],
          'total': data['total'] ?? '0.00',
          'itemCount': data['itemCount'] ?? 0,
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ?? 'Unable to fetch cart',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // UPDATE CART QUANTITY API
  // =====================================================

  static Future<Map<String, dynamic>> updateCartQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/cart/$cartItemId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'quantity': quantity,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'cartItem': data['cartItem'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ?? 'Unable to update quantity',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // DELETE CART ITEM API
  // =====================================================

  static Future<Map<String, dynamic>> deleteCartItem({
    required int cartItemId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/cart/$cartItemId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ?? 'Unable to remove item',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // CLEAR CART API
  // =====================================================

  static Future<Map<String, dynamic>> clearCart({
    required int userId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/cart/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ?? 'Unable to clear cart',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // CREATE ORDER
  // =====================================================

  static Future<Map<String, dynamic>> createOrder({
    required int userId,
    required double subtotal,
    required double deliveryCharge,
    required double tax,
    required double discount,
    required double totalAmount,
    required String paymentMethod,
    String? deliveryAddress,
    String? deliveryDate,
    String? deliverySlot,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/orders'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'subtotal': subtotal,
          'delivery_charge': deliveryCharge,
          'tax': tax,
          'discount': discount,
          'total_amount': totalAmount,
          'payment_method': paymentMethod,
          'delivery_address': deliveryAddress,
          'delivery_date': deliveryDate,
          'delivery_slot': deliverySlot,
          'items': items,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'order': data['order'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ?? 'Unable to place order',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // GET USER ORDERS
  // =====================================================

  static Future<Map<String, dynamic>> getUserOrders({
    required int userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'orders': data['orders'] ?? [],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ?? 'Unable to fetch orders',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // GET ALL ORDERS - ADMIN
  // =====================================================

  static Future<Map<String, dynamic>> getAllOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/all'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'orders': data['orders'] ?? [],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ?? 'Unable to fetch all orders',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // GET SINGLE ORDER
  // =====================================================

  static Future<Map<String, dynamic>> getOrderById({
    required int orderId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/$orderId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'order': data['order'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ?? 'Unable to fetch order',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // UPDATE ORDER STATUS
  // =====================================================

  static Future<Map<String, dynamic>> updateOrderStatus({
    required int orderId,
    required String orderStatus,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(
          '$baseUrl/api/orders/$orderId/status',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'order_status': orderStatus,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'order': data['order'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ?? 'Unable to update order status',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // ADD PRODUCT API
  // =====================================================

  static Future<Map<String, dynamic>> addProduct({
    required String name,
    String? description,
    required String category,
    String? brand,
    String? sku,
    required double price,
    required double mrp,
    double discount = 0,
    int stock = 0,
    String? imageUrl,
    bool isAvailable = true,
    bool isSubscriptionEligible = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/products'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'category': category,
          'brand': brand,
          'sku': sku,
          'price': price,
          'mrp': mrp,
          'discount': discount,
          'stock': stock,
          'image_url': imageUrl,
          'is_available': isAvailable,
          'is_subscription_eligible':
              isSubscriptionEligible,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'product': data['product'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ?? 'Unable to add product',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // GET ALL PRODUCTS API
  // =====================================================

  static Future<Map<String, dynamic>> getAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/products'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'products': data['products'] ?? [],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ?? 'Unable to fetch products',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // GET SINGLE PRODUCT API
  // =====================================================

  static Future<Map<String, dynamic>> getProductById({
    required int productId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/products/$productId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'product': data['product'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ?? 'Unable to fetch product',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // UPDATE PRODUCT API
  // =====================================================

  static Future<Map<String, dynamic>> updateProduct({
    required int productId,
    required String name,
    String? description,
    required String category,
    String? brand,
    String? sku,
    required double price,
    required double mrp,
    double discount = 0,
    int stock = 0,
    String? imageUrl,
    bool isAvailable = true,
    bool isSubscriptionEligible = true,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(
          '$baseUrl/api/products/$productId',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'category': category,
          'brand': brand,
          'sku': sku,
          'price': price,
          'mrp': mrp,
          'discount': discount,
          'stock': stock,
          'image_url': imageUrl,
          'is_available': isAvailable,
          'is_subscription_eligible':
              isSubscriptionEligible,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'product': data['product'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ?? 'Unable to update product',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // UPDATE PRODUCT STOCK API
  // =====================================================

  static Future<Map<String, dynamic>> updateProductStock({
    required int id,
    required int stock,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(
          '$baseUrl/api/products/$id/stock',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'stock': stock,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              data['message'] ??
                  'Stock updated successfully',
          'product': data['product'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ??
                'Unable to update stock',
      };
    } catch (e) {
      return {
        'success': false,
        'message':
            'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // DELETE PRODUCT API
  // =====================================================

  static Future<Map<String, dynamic>> deleteProduct({
    required int productId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse(
          '$baseUrl/api/products/$productId',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'product': data['product'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ??
                'Unable to delete product',
      };
    } catch (e) {
      return {
        'success': false,
        'message':
            'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // GET ALL CUSTOMERS - ADMIN
  // =====================================================

  static Future<Map<String, dynamic>>
      getAllCustomers() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/users/customers',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'customers':
              data['customers'] ?? [],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ??
                'Unable to fetch customers',
      };
    } catch (e) {
      return {
        'success': false,
        'message':
            'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // DASHBOARD STATS
  // =====================================================

  static Future<Map<String, dynamic>>
      getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/dashboard/stats',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'stats': data['stats'] ?? {},
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ??
                'Unable to fetch dashboard stats',
      };
    } catch (e) {
      return {
        'success': false,
        'message':
            'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // DELIVERY PARTNERS
  // =====================================================

  // GET ALL DELIVERY PARTNERS

  static Future<Map<String, dynamic>>
      getAllDeliveryPartners() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/delivery-partners',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'partners':
              data['partners'] ?? [],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ??
                'Unable to fetch delivery partners',
      };
    } catch (e) {
      return {
        'success': false,
        'message':
            'Unable to connect to server',
      };
    }
  }

  // ADD DELIVERY PARTNER

  static Future<Map<String, dynamic>>
      addDeliveryPartner({
    required String name,
    required String mobile,
    String status = 'Available',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/api/delivery-partners',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'mobile': mobile,
          'status': status,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'partner': data['partner'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ??
                'Unable to add delivery partner',
      };
    } catch (e) {
      return {
        'success': false,
        'message':
            'Unable to connect to server',
      };
    }
  }

  // UPDATE DELIVERY PARTNER

  static Future<Map<String, dynamic>>
      updateDeliveryPartner({
    required int id,
    String? name,
    String? mobile,
    String? status,
    bool? isActive,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(
          '$baseUrl/api/delivery-partners/$id',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          if (name != null) 'name': name,
          if (mobile != null) 'mobile': mobile,
          if (status != null) 'status': status,
          if (isActive != null)
            'is_active': isActive,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'partner': data['partner'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ??
                'Unable to update delivery partner',
      };
    } catch (e) {
      return {
        'success': false,
        'message':
            'Unable to connect to server',
      };
    }
  }

  // DELETE DELIVERY PARTNER

  static Future<Map<String, dynamic>>
      deleteDeliveryPartner(int id) async {
    try {
      final response = await http.delete(
        Uri.parse(
          '$baseUrl/api/delivery-partners/$id',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ??
                'Unable to delete delivery partner',
      };
    } catch (e) {
      return {
        'success': false,
        'message':
            'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // UPDATE DELIVERY PARTNER STATUS
  // =====================================================

  static Future<Map<String, dynamic>>
      updateDeliveryPartnerStatus({
    required int id,
    required String status,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(
          '$baseUrl/api/delivery-partners/$id/status',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': status,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              data['message'] ??
                  'Status updated successfully',
          'partner': data['partner'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ??
                'Unable to update status',
      };
    } catch (e) {
      return {
        'success': false,
        'message':
            'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // TOGGLE DELIVERY PARTNER ACTIVE STATUS
  // =====================================================

  static Future<Map<String, dynamic>>
      toggleDeliveryPartnerActive({
    required int id,
    required bool isActive,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(
          '$baseUrl/api/delivery-partners/$id/active',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'is_active': isActive,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              data['message'] ??
                  'Active status updated',
          'partner': data['partner'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ??
                'Unable to update active status',
      };
    } catch (e) {
      return {
        'success': false,
        'message':
            'Unable to connect to server',
      };
    }
  }

  // =====================================================
  // CATEGORY APIs
  // =====================================================

  // GET ALL CATEGORIES

  static Future<Map<String, dynamic>>
      getAllCategories() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/categories',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'categories':
              data['categories'] ?? [],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ??
                'Unable to fetch categories',
      };
    } catch (e) {
      return {
        'success': false,
        'message':
            'Unable to connect to server',
      };
    }
  }

  // ADD CATEGORY

  static Future<Map<String, dynamic>>
      addCategory({
    required String name,
    String? parentCategory,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/api/categories',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'parent_category':
              parentCategory,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'category':
              data['category'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ??
                'Unable to add category',
      };
    } catch (e) {
      return {
        'success': false,
        'message':
            'Unable to connect to server',
      };
    }
  }

  // UPDATE CATEGORY

  static Future<Map<String, dynamic>>
      updateCategory({
    required int id,
    required String name,
    String? parentCategory,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(
          '$baseUrl/api/categories/$id',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'parent_category':
              parentCategory,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'category':
              data['category'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ??
                'Unable to update category',
      };
    } catch (e) {
      return {
        'success': false,
        'message':
            'Unable to connect to server',
      };
    }
  }

  // DELETE CATEGORY

  static Future<Map<String, dynamic>>
      deleteCategory(
    int id,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse(
          '$baseUrl/api/categories/$id',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ??
                'Unable to delete category',
      };
    } catch (e) {
      return {
        'success': false,
        'message':
            'Unable to connect to server',
      };
    }
  }

  // UPDATE CATEGORY STATUS

  static Future<Map<String, dynamic>>
      updateCategoryStatus({
    required int id,
    required bool isActive,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(
          '$baseUrl/api/categories/$id/status',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'is_active': isActive,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'category':
              data['category'],
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ??
                'Unable to update category status',
      };
    } catch (e) {
      return {
        'success': false,
        'message':
            'Unable to connect to server',
      };
    }
  }
}