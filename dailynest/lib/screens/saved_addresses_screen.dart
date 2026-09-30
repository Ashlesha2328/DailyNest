import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'delivery_address.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() =>
      _SavedAddressesScreenState();
}

class _SavedAddressesScreenState
    extends State<SavedAddressesScreen> {
  // Testing user ID
  final int userId = 2;

  List<dynamic> addresses = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAddresses();
  }

  // =====================================================
  // FETCH ADDRESSES
  // =====================================================

  Future<void> fetchAddresses() async {
    setState(() {
      isLoading = true;
    });

    final result = await ApiService.getAddresses(
      userId: userId,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        addresses = result['addresses'] ?? [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'Unable to fetch addresses',
          ),
        ),
      );
    }
  }

  // =====================================================
  // DELETE ADDRESS
  // =====================================================

  Future<void> deleteAddress(int addressId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Address'),
          content: const Text(
            'Are you sure you want to delete this address?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final result = await ApiService.deleteAddress(
      addressId: addressId,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address deleted successfully'),
        ),
      );

      fetchAddresses();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'Unable to delete address',
          ),
        ),
      );
    }
  }

  // =====================================================
  // SET DEFAULT ADDRESS
  // =====================================================

  Future<void> setDefaultAddress(int addressId) async {
    final result = await ApiService.setDefaultAddress(
      addressId: addressId,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Default address updated'),
        ),
      );

      fetchAddresses();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ??
                'Unable to update default address',
          ),
        ),
      );
    }
  }

  // =====================================================
  // ADD NEW ADDRESS
  // =====================================================

  Future<void> addNewAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const DeliveryAddressScreen(),
      ),
    );

    // Refresh after returning
    fetchAddresses();
  }

  // =====================================================
  // ADDRESS CARD
  // =====================================================

  Widget addressCard(dynamic address) {
    final int addressId =
        int.tryParse(address['id'].toString()) ?? 0;

    final bool isDefault =
        address['is_default'] == true;

    final String addressType =
        address['address_type'] ?? 'Home';

    final String fullName =
        address['full_name'] ?? '';

    final String mobile =
        address['mobile'] ?? '';

    final String house =
        address['house_flat_building'] ?? '';

    final String area =
        address['area_locality'] ?? '';

    final String city =
        address['city'] ?? '';

    final String pincode =
        address['pincode'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDefault
              ? Colors.green
              : Colors.grey.shade300,
          width: isDefault ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          // TOP ROW
          Row(
            children: [

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius:
                      BorderRadius.circular(6),
                ),
                child: Text(
                  addressType,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              if (isDefault)
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius:
                        BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Default',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const Spacer(),

              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                onPressed: () {
                  deleteAddress(addressId);
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          // NAME
          Text(
            fullName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          // MOBILE
          Text(
            mobile,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 8),

          // ADDRESS
          Text(
            '$house, $area, $city - $pincode',
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          // DEFAULT BUTTON
          if (!isDefault)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  setDefaultAddress(addressId);
                },
                child: const Text(
                  'Set as Default',
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      appBar: AppBar(
        title: const Text(
          'Saved Addresses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: fetchAddresses,
              child: addresses.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 100),

                        Icon(
                          Icons.location_on_outlined,
                          size: 70,
                          color: Colors.grey.shade400,
                        ),

                        const SizedBox(height: 15),

                        Center(
                          child: Text(
                            'No saved addresses',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Center(
                          child: Text(
                            'Add an address for faster checkout',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [

                        // ADDRESS COUNT
                        Text(
                          '${addresses.length} Saved Address${addresses.length == 1 ? '' : 'es'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ADDRESS CARDS
                        ...addresses.map(
                          (address) =>
                              addressCard(address),
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
            ),

      // ADD NEW ADDRESS
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            12,
          ),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: addNewAddress,
              icon: const Icon(Icons.add),
              label: const Text(
                'Add New Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}