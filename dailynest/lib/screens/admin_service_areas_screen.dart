import 'package:flutter/material.dart';

class ServiceArea {
  String pincode;
  String area;
  String city;
  int deliveryCharge;
  int minimumOrder;
  bool active;

  ServiceArea({
    required this.pincode,
    required this.area,
    required this.city,
    required this.deliveryCharge,
    required this.minimumOrder,
    required this.active,
  });
}

class AdminServiceAreasScreen extends StatefulWidget {
  const AdminServiceAreasScreen({super.key});

  @override
  State<AdminServiceAreasScreen> createState() =>
      _AdminServiceAreasScreenState();
}

class _AdminServiceAreasScreenState
    extends State<AdminServiceAreasScreen> {
  static const Color primaryColor = Color(0xFF159A93);

  final TextEditingController searchController = TextEditingController();

  final List<ServiceArea> areas = [
    ServiceArea(
      pincode: '411001',
      area: 'Shivajinagar',
      city: 'Pune',
      deliveryCharge: 0,
      minimumOrder: 199,
      active: true,
    ),
    ServiceArea(
      pincode: '411004',
      area: 'Deccan',
      city: 'Pune',
      deliveryCharge: 20,
      minimumOrder: 199,
      active: true,
    ),
    ServiceArea(
      pincode: '411038',
      area: 'Kothrud',
      city: 'Pune',
      deliveryCharge: 25,
      minimumOrder: 249,
      active: true,
    ),
    ServiceArea(
      pincode: '411014',
      area: 'Viman Nagar',
      city: 'Pune',
      deliveryCharge: 30,
      minimumOrder: 299,
      active: true,
    ),
    ServiceArea(
      pincode: '411045',
      area: 'Baner',
      city: 'Pune',
      deliveryCharge: 20,
      minimumOrder: 199,
      active: false,
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<ServiceArea> get filteredAreas {
    final query = searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      return areas;
    }

    return areas.where((area) {
      return area.pincode.contains(query) ||
          area.area.toLowerCase().contains(query) ||
          area.city.toLowerCase().contains(query);
    }).toList();
  }

  void showAreaDialog({ServiceArea? serviceArea}) {
    final pincodeController = TextEditingController(
      text: serviceArea?.pincode ?? '',
    );

    final areaController = TextEditingController(
      text: serviceArea?.area ?? '',
    );

    final cityController = TextEditingController(
      text: serviceArea?.city ?? '',
    );

    final chargeController = TextEditingController(
      text: serviceArea?.deliveryCharge.toString() ?? '',
    );

    final minimumOrderController = TextEditingController(
      text: serviceArea?.minimumOrder.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            serviceArea == null
                ? 'Add Service Area'
                : 'Edit Service Area',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pincodeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'Pincode',
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                    ),
                    counterText: '',
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: areaController,
                  decoration: const InputDecoration(
                    labelText: 'Area',
                    prefixIcon: Icon(
                      Icons.place_outlined,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    prefixIcon: Icon(
                      Icons.location_city_outlined,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: chargeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Charge',
                    hintText: 'Example: 20',
                    prefixIcon: Icon(
                      Icons.currency_rupee,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: minimumOrderController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Minimum Order',
                    hintText: 'Example: 199',
                    prefixIcon: Icon(
                      Icons.shopping_cart_outlined,
                    ),
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
                final pincode =
                    pincodeController.text.trim();

                final area =
                    areaController.text.trim();

                final city =
                    cityController.text.trim();

                final deliveryCharge =
                    int.tryParse(
                  chargeController.text.trim(),
                );

                final minimumOrder =
                    int.tryParse(
                  minimumOrderController.text.trim(),
                );

                if (pincode.length != 6 ||
                    area.isEmpty ||
                    city.isEmpty ||
                    deliveryCharge == null ||
                    minimumOrder == null ||
                    deliveryCharge < 0 ||
                    minimumOrder < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter valid service area details',
                      ),
                    ),
                  );
                  return;
                }

                setState(() {
                  if (serviceArea == null) {
                    areas.add(
                      ServiceArea(
                        pincode: pincode,
                        area: area,
                        city: city,
                        deliveryCharge: deliveryCharge,
                        minimumOrder: minimumOrder,
                        active: true,
                      ),
                    );
                  } else {
                    serviceArea.pincode = pincode;
                    serviceArea.area = area;
                    serviceArea.city = city;
                    serviceArea.deliveryCharge =
                        deliveryCharge;
                    serviceArea.minimumOrder =
                        minimumOrder;
                  }
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      serviceArea == null
                          ? 'Service area added successfully'
                          : 'Service area updated successfully',
                    ),
                  ),
                );
              },

              child: Text(
                serviceArea == null
                    ? 'Add Area'
                    : 'Update',
              ),
            ),
          ],
        );
      },
    );
  }

  void deleteArea(ServiceArea serviceArea) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Service Area',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            'Are you sure you want to delete '
            '"${serviceArea.area}, ${serviceArea.pincode}"?',
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
                  areas.remove(serviceArea);
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Service area deleted successfully',
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
    final displayedAreas = filteredAreas;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,

        title: const Text(
          'Service Areas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              showAreaDialog();
            },
            icon: const Icon(Icons.add),
            tooltip: 'Add Service Area',
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,

        onPressed: () {
          showAreaDialog();
        },

        icon: const Icon(Icons.add_location_alt_outlined),

        label: const Text(
          'Add Area',
        ),
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
                hintText: 'Search pincode, area or city...',

                prefixIcon: const Icon(
                  Icons.search,
                ),

                suffixIcon:
                    searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(
                              Icons.clear,
                            ),
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
                  '${displayedAreas.length} Service Areas',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                Text(
                  'Total: ${areas.length}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: displayedAreas.isEmpty
                ? const Center(
                    child: Text(
                      'No service areas found',
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

                    itemCount: displayedAreas.length,

                    itemBuilder: (context, index) {
                      final serviceArea =
                          displayedAreas[index];

                      return Card(
                        color: Colors.white,

                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),

                        elevation: 1,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),

                        child: Padding(
                          padding:
                              const EdgeInsets.all(15),

                          child: Row(
                            children: [
                              Container(
                                height: 55,
                                width: 55,

                                decoration:
                                    BoxDecoration(
                                  color: const Color(
                                    0xFFE8F7F5,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    14,
                                  ),
                                ),

                                child: const Icon(
                                  Icons.location_on_outlined,
                                  color: primaryColor,
                                  size: 28,
                                ),
                              ),

                              const SizedBox(
                                width: 14,
                              ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      serviceArea.area,
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 4,
                                    ),

                                    Text(
                                      '${serviceArea.city} • '
                                      '${serviceArea.pincode}',
                                      style:
                                          const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 7,
                                    ),

                                    Row(
                                      children: [
                                        Text(
                                          serviceArea
                                                      .deliveryCharge ==
                                                  0
                                              ? 'Free Delivery'
                                              : 'Delivery: ₹${serviceArea.deliveryCharge}',
                                          style:
                                              const TextStyle(
                                            color:
                                                primaryColor,
                                            fontWeight:
                                                FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),

                                        const SizedBox(
                                          width: 12,
                                        ),

                                        Text(
                                          'Min: ₹${serviceArea.minimumOrder}',
                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.grey,
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
                                    value:
                                        serviceArea.active,

                                    activeThumbColor:
                                        primaryColor,

                                    onChanged: (value) {
                                      setState(() {
                                        serviceArea.active =
                                            value;
                                      });
                                    },
                                  ),

                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value ==
                                          'edit') {
                                        showAreaDialog(
                                          serviceArea:
                                              serviceArea,
                                        );
                                      }

                                      if (value ==
                                          'delete') {
                                        deleteArea(
                                          serviceArea,
                                        );
                                      }
                                    },

                                    itemBuilder:
                                        (context) => const [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons
                                                  .edit_outlined,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              'Edit',
                                            ),
                                          ],
                                        ),
                                      ),

                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons
                                                  .delete_outline,
                                              color:
                                                  Colors.red,
                                            ),
                                            SizedBox(
                                              width: 10,
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