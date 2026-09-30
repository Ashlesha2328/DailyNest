import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  State<DeliveryAddressScreen> createState() =>
      _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState
    extends State<DeliveryAddressScreen> {
  static const Color primaryColor = Color(0xFF159A93);

  // =====================================================
  // CONTROLLERS
  // =====================================================

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final houseController = TextEditingController();
  final areaController = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();

  // =====================================================
  // VARIABLES
  // =====================================================

  String selectedAddressType = 'Home';

  bool isDefaultAddress = true;

  bool isLoading = false;

  // =====================================================
  // TEST USER ID
  // =====================================================

  // Currently using user ID 2 for testing.
  // Later we will connect this with logged-in user.
  static const int userId = 2;

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    houseController.dispose();
    areaController.dispose();
    cityController.dispose();
    pincodeController.dispose();

    super.dispose();
  }

  // =====================================================
  // SAVE ADDRESS
  // =====================================================

  Future<void> saveAddress() async {
    final name = nameController.text.trim();
    final mobile = mobileController.text.trim();
    final house = houseController.text.trim();
    final area = areaController.text.trim();
    final city = cityController.text.trim();
    final pincode = pincodeController.text.trim();

    // ===================================================
    // REQUIRED FIELD VALIDATION
    // ===================================================

    if (name.isEmpty ||
        mobile.isEmpty ||
        house.isEmpty ||
        area.isEmpty ||
        city.isEmpty ||
        pincode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all address fields',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // ===================================================
    // MOBILE VALIDATION
    // ===================================================

    if (!RegExp(
      r'^[6-9][0-9]{9}$',
    ).hasMatch(mobile)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid 10-digit mobile number',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // ===================================================
    // PINCODE VALIDATION
    // ===================================================

    if (!RegExp(
      r'^[0-9]{6}$',
    ).hasMatch(pincode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid 6-digit pincode',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // ===================================================
    // START LOADING
    // ===================================================

    setState(() {
      isLoading = true;
    });

    try {
      // =================================================
      // CALL BACKEND API
      // =================================================

      final result = await ApiService.addAddress(
        userId: userId,
        fullName: name,
        mobile: mobile,
        houseFlatBuilding: house,
        areaLocality: area,
        city: city,
        pincode: pincode,
        addressType: selectedAddressType,
        isDefault: isDefaultAddress,
      );

      if (!mounted) return;

      // =================================================
      // STOP LOADING
      // =================================================

      setState(() {
        isLoading = false;
      });

      // =================================================
      // SUCCESS
      // =================================================

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Address saved successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Go back after successful save
        Navigator.pop(context);
      }

      // =================================================
      // API ERROR
      // =================================================

      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ??
                  'Unable to save address',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // =================================================
      // CONNECTION ERROR
      // =================================================

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to connect to server. '
            'Please make sure backend is running.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =====================================================
  // FIELD DECORATION
  // =====================================================

  InputDecoration fieldDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 2,
        ),
      ),
    );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // =================================================
      // APP BAR
      // =================================================

      appBar: AppBar(
        title: const Text(
          'Delivery Address',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),

      // =================================================
      // BODY
      // =================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // =========================================
              // TITLE
              // =========================================

              const Text(
                'Add Delivery Address',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Enter your address details for delivery.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 25),

              // =========================================
              // FULL NAME
              // =========================================

              const Text(
                'Full Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: nameController,
                keyboardType: TextInputType.name,
                decoration: fieldDecoration(
                  hint: 'Enter full name',
                  icon: Icons.person_outline,
                ),
              ),

              const SizedBox(height: 18),

              // =========================================
              // MOBILE
              // =========================================

              const Text(
                'Mobile Number',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: fieldDecoration(
                  hint: 'Enter 10-digit mobile number',
                  icon: Icons.phone_outlined,
                ).copyWith(
                  counterText: '',
                ),
              ),

              const SizedBox(height: 18),

              // =========================================
              // HOUSE / FLAT
              // =========================================

              const Text(
                'House / Flat / Building',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: houseController,
                decoration: fieldDecoration(
                  hint:
                      'Example: Flat 202, ABC Apartment',
                  icon: Icons.home_outlined,
                ),
              ),

              const SizedBox(height: 18),

              // =========================================
              // AREA
              // =========================================

              const Text(
                'Area / Locality',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: areaController,
                decoration: fieldDecoration(
                  hint: 'Enter area or locality',
                  icon: Icons.location_on_outlined,
                ),
              ),

              const SizedBox(height: 18),

              // =========================================
              // CITY
              // =========================================

              const Text(
                'City',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: cityController,
                decoration: fieldDecoration(
                  hint: 'Enter city',
                  icon: Icons.location_city_outlined,
                ),
              ),

              const SizedBox(height: 18),

              // =========================================
              // PINCODE
              // =========================================

              const Text(
                'Pincode',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: pincodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: fieldDecoration(
                  hint: 'Enter 6-digit pincode',
                  icon:
                      Icons.markunread_mailbox_outlined,
                ).copyWith(
                  counterText: '',
                ),
              ),

              const SizedBox(height: 22),

              // =========================================
              // ADDRESS TYPE
              // =========================================

              const Text(
                'Address Type',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Home'),
                    selected:
                        selectedAddressType == 'Home',
                    selectedColor:
                        primaryColor.withOpacity(0.15),
                    onSelected: (_) {
                      setState(() {
                        selectedAddressType = 'Home';
                      });
                    },
                  ),

                  const SizedBox(width: 10),

                  ChoiceChip(
                    label: const Text('Work'),
                    selected:
                        selectedAddressType == 'Work',
                    selectedColor:
                        primaryColor.withOpacity(0.15),
                    onSelected: (_) {
                      setState(() {
                        selectedAddressType = 'Work';
                      });
                    },
                  ),

                  const SizedBox(width: 10),

                  ChoiceChip(
                    label: const Text('Other'),
                    selected:
                        selectedAddressType == 'Other',
                    selectedColor:
                        primaryColor.withOpacity(0.15),
                    onSelected: (_) {
                      setState(() {
                        selectedAddressType = 'Other';
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // =========================================
              // DEFAULT ADDRESS
              // =========================================

              SwitchListTile(
                contentPadding: EdgeInsets.zero,

                title: const Text(
                  'Set as default address',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                value: isDefaultAddress,

                activeColor: primaryColor,

                onChanged: (value) {
                  setState(() {
                    isDefaultAddress = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // =========================================
              // SAVE ADDRESS BUTTON
              // =========================================

              SizedBox(
                width: double.infinity,
                height: 54,

                child: ElevatedButton(
                  onPressed:
                      isLoading ? null : saveAddress,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        primaryColor.withOpacity(0.6),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),

                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child:
                              CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Save Address',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}