import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminDeliveryPartnersScreen extends StatefulWidget {
  const AdminDeliveryPartnersScreen({super.key});

  @override
  State<AdminDeliveryPartnersScreen> createState() =>
      _AdminDeliveryPartnersScreenState();
}

class _AdminDeliveryPartnersScreenState
    extends State<AdminDeliveryPartnersScreen> {
  static const Color primaryColor = Color(0xFF159A93);

  final TextEditingController searchController =
      TextEditingController();

  List<DeliveryPartner> deliveryPartners = [];

  String searchText = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadDeliveryPartners();

    searchController.addListener(() {
      setState(() {
        searchText = searchController.text;
      });
    });
  }

  // =====================================================
  // LOAD DELIVERY PARTNERS
  // =====================================================

  Future<void> loadDeliveryPartners() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    final result =
        await ApiService.getAllDeliveryPartners();

    if (!mounted) return;

    if (result['success'] == true) {
      final List data =
          result['partners'] ?? [];

      setState(() {
        deliveryPartners = data
            .map(
              (item) =>
                  DeliveryPartner.fromJson(item),
            )
            .toList();

        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ??
                'Unable to load delivery partners',
          ),
        ),
      );
    }
  }

  // =====================================================
  // FILTER
  // =====================================================

  List<DeliveryPartner> get filteredPartners {
    if (searchText.trim().isEmpty) {
      return deliveryPartners;
    }

    final query =
        searchText.toLowerCase().trim();

    return deliveryPartners.where((partner) {
      return partner.name
              .toLowerCase()
              .contains(query) ||
          partner.mobile.contains(query) ||
          partner.status
              .toLowerCase()
              .contains(query);
    }).toList();
  }

  // =====================================================
  // ADD DELIVERY PARTNER
  // =====================================================

  void showAddDeliveryPartnerDialog() {
    final nameController =
        TextEditingController();

    final mobileController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Add Delivery Partner',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(
                    Icons.person_outline,
                  ),
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: mobileController,
                keyboardType:
                    TextInputType.phone,
                maxLength: 10,
                decoration:
                    const InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                  ),
                  border:
                      OutlineInputBorder(),
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
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
                final name =
                    nameController.text.trim();

                final mobile =
                    mobileController.text.trim();

                if (name.isEmpty ||
                    !RegExp(
                      r'^[6-9][0-9]{9}$',
                    ).hasMatch(mobile)) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter valid name and mobile number',
                      ),
                    ),
                  );

                  return;
                }

                Navigator.pop(dialogContext);

                final result =
                    await ApiService
                        .addDeliveryPartner(
                  name: name,
                  mobile: mobile,
                );

                if (!mounted) return;

                if (result['success'] == true) {
                  await loadDeliveryPartners();

                  if (!mounted) return;

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Delivery partner added successfully',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        result['message'] ??
                            'Unable to add delivery partner',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // EDIT DELIVERY PARTNER
  // =====================================================

  void showEditDialog(
      DeliveryPartner partner) {
    final nameController =
        TextEditingController(
      text: partner.name,
    );

    final mobileController =
        TextEditingController(
      text: partner.mobile,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Edit Delivery Partner',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(
                    Icons.person_outline,
                  ),
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: mobileController,
                keyboardType:
                    TextInputType.phone,
                maxLength: 10,
                decoration:
                    const InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                  ),
                  border:
                      OutlineInputBorder(),
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
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
                final name =
                    nameController.text.trim();

                final mobile =
                    mobileController.text.trim();

                if (name.isEmpty ||
                    !RegExp(
                      r'^[6-9][0-9]{9}$',
                    ).hasMatch(mobile)) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter valid details',
                      ),
                    ),
                  );

                  return;
                }

                Navigator.pop(dialogContext);

                final result =
                    await ApiService
                        .updateDeliveryPartner(
                  id: partner.id,
                  name: name,
                  mobile: mobile,
                );

                if (!mounted) return;

                if (result['success'] == true) {
                  await loadDeliveryPartners();

                  if (!mounted) return;

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Delivery partner updated',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        result['message'] ??
                            'Unable to update delivery partner',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // DELETE DELIVERY PARTNER
  // =====================================================

  void deletePartner(
      DeliveryPartner partner) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Delivery Partner?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete ${partner.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);

                final result =
                    await ApiService
                        .deleteDeliveryPartner(
                  partner.id,
                );

                if (!mounted) return;

                if (result['success'] == true) {
                  await loadDeliveryPartners();

                  if (!mounted) return;

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Delivery partner deleted',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        result['message'] ??
                            'Unable to delete delivery partner',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // CHANGE STATUS
  // =====================================================

  void changeStatus(
      DeliveryPartner partner) {
    final statuses = [
      'Available',
      'Busy',
      'Offline',
    ];

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Change Delivery Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              ...statuses.map(
                (status) {
                  return ListTile(
                    leading: Icon(
                      status == 'Available'
                          ? Icons.check_circle
                          : status == 'Busy'
                              ? Icons.access_time
                              : Icons.cancel,
                      color:
                          status == 'Available'
                              ? Colors.green
                              : status == 'Busy'
                                  ? Colors.orange
                                  : Colors.grey,
                    ),

                    title: Text(status),

                    trailing:
                        partner.status ==
                                status
                            ? const Icon(
                                Icons.check,
                                color:
                                    primaryColor,
                              )
                            : null,

                    onTap: () async {
                      Navigator.pop(
                        sheetContext,
                      );

                      final result =
                          await ApiService
                              .updateDeliveryPartner(
                        id: partner.id,
                        status: status,
                      );

                      if (!mounted) return;

                      if (result['success'] ==
                          true) {
                        await loadDeliveryPartners();
                      } else {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          SnackBar(
                            content: Text(
                              result['message'] ??
                                  'Unable to change status',
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // =====================================================
  // TOGGLE ACTIVE / INACTIVE
  // =====================================================

  Future<void> toggleActive(
      DeliveryPartner partner) async {
    final result =
        await ApiService
            .updateDeliveryPartner(
      id: partner.id,
      isActive: !partner.isActive,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      await loadDeliveryPartners();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ??
                'Unable to change active status',
          ),
        ),
      );
    }
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final availableCount =
        deliveryPartners
            .where(
              (p) =>
                  p.status ==
                  'Available',
            )
            .length;

    final busyCount =
        deliveryPartners
            .where(
              (p) =>
                  p.status == 'Busy',
            )
            .length;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F9F9),

      appBar: AppBar(
        backgroundColor:
            Colors.white,
        elevation: 0,

        title: const Text(
          'Delivery Partners',
          style: TextStyle(
            color: Colors.black87,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.black87,
            ),
            onPressed:
                loadDeliveryPartners,
          ),
        ],
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor:
            primaryColor,
        foregroundColor:
            Colors.white,
        onPressed:
            showAddDeliveryPartnerDialog,
        icon: const Icon(Icons.add),
        label:
            const Text('Add Partner'),
      ),

      body: Column(
        children: [
          // =================================================
          // SEARCH
          // =================================================

          Padding(
            padding:
                const EdgeInsets.all(16),
            child: TextField(
              controller:
                  searchController,
              decoration:
                  InputDecoration(
                hintText:
                    'Search delivery partner...',
                prefixIcon:
                    const Icon(
                  Icons.search,
                ),
                suffixIcon:
                    searchText.isNotEmpty
                        ? IconButton(
                            icon:
                                const Icon(
                              Icons.clear,
                            ),
                            onPressed: () {
                              searchController
                                  .clear();
                            },
                          )
                        : null,
                filled: true,
                fillColor:
                    Colors.white,
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),
          ),

          // =================================================
          // SUMMARY
          // =================================================

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                _summaryCard(
                  title: 'Total',
                  value:
                      deliveryPartners
                          .length
                          .toString(),
                  icon:
                      Icons.people_outline,
                ),

                const SizedBox(
                  width: 10,
                ),

                _summaryCard(
                  title: 'Available',
                  value:
                      availableCount
                          .toString(),
                  icon:
                      Icons.check_circle_outline,
                ),

                const SizedBox(
                  width: 10,
                ),

                _summaryCard(
                  title: 'Busy',
                  value:
                      busyCount
                          .toString(),
                  icon:
                      Icons.access_time_outlined,
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          // =================================================
          // LIST
          // =================================================

          Expanded(
            child: isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(
                      color:
                          primaryColor,
                    ),
                  )
                : filteredPartners
                        .isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Icon(
                              Icons
                                  .person_off_outlined,
                              size: 55,
                              color:
                                  Colors.grey,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'No delivery partners found',
                              style:
                                  TextStyle(
                                color:
                                    Colors.grey,
                                fontSize:
                                    16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets
                                .fromLTRB(
                          16,
                          5,
                          16,
                          90,
                        ),
                        itemCount:
                            filteredPartners
                                .length,
                        itemBuilder:
                            (context,
                                index) {
                          return _partnerCard(
                            filteredPartners[
                                index],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // SUMMARY CARD
  // =====================================================

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        elevation: 1,
        color: Colors.white,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
        ),
        child: Padding(
          padding:
              const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(
                icon,
                color:
                    primaryColor,
                size: 25,
              ),

              const SizedBox(
                height: 5,
              ),

              Text(
                value,
                style:
                    const TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 12,
                  color:
                      Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // PARTNER CARD
  // =====================================================

  Widget _partnerCard(
      DeliveryPartner partner) {
    Color statusColor;

    if (partner.status ==
        'Available') {
      statusColor =
          Colors.green;
    } else if (partner.status ==
        'Busy') {
      statusColor =
          Colors.orange;
    } else {
      statusColor =
          Colors.grey;
    }

    return Card(
      color: Colors.white,
      elevation: 1,
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(14),
        child: Row(
          children: [
            // AVATAR

            CircleAvatar(
              radius: 28,
              backgroundColor:
                  const Color(
                0xFFE8F7F5,
              ),
              child: Text(
                partner.name.isNotEmpty
                    ? partner.name
                        .substring(
                          0,
                          1,
                        )
                        .toUpperCase()
                    : '?',
                style:
                    const TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                  color:
                      primaryColor,
                ),
              ),
            ),

            const SizedBox(
              width: 14,
            ),

            // DETAILS

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    partner.name,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    partner.mobile,
                    style:
                        const TextStyle(
                      color:
                          Colors.grey,
                    ),
                  ),

                  const SizedBox(
                    height: 7,
                  ),

                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration:
                            BoxDecoration(
                          color: statusColor
                              .withOpacity(
                            0.12,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                        ),
                        child: Text(
                          partner.status,
                          style:
                              TextStyle(
                            color:
                                statusColor,
                            fontSize:
                                12,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Text(
                        '${partner.assignedOrders} Orders',
                        style:
                            const TextStyle(
                          fontSize: 12,
                          color:
                              Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Row(
                    children: [
                      Icon(
                        partner.isActive
                            ? Icons
                                .check_circle
                            : Icons
                                .cancel,
                        size: 14,
                        color:
                            partner.isActive
                                ? Colors.green
                                : Colors.red,
                      ),

                      const SizedBox(
                        width: 4,
                      ),

                      Text(
                        partner.isActive
                            ? 'Active'
                            : 'Inactive',
                        style:
                            TextStyle(
                          fontSize: 12,
                          color: partner
                                  .isActive
                              ? Colors.green
                              : Colors.red,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // MENU

            PopupMenuButton<
                String>(
              onSelected:
                  (value) {
                if (value ==
                    'edit') {
                  showEditDialog(
                    partner,
                  );
                }

                if (value ==
                    'status') {
                  changeStatus(
                    partner,
                  );
                }

                if (value ==
                    'toggle') {
                  toggleActive(
                    partner,
                  );
                }

                if (value ==
                    'delete') {
                  deletePartner(
                    partner,
                  );
                }
              },
              itemBuilder:
                  (context) {
                return [
                  const PopupMenuItem(
                    value: 'edit',
                    child:
                        ListTile(
                      leading:
                          Icon(
                        Icons
                            .edit_outlined,
                      ),
                      title:
                          Text(
                        'Edit',
                      ),
                    ),
                  ),

                  const PopupMenuItem(
                    value: 'status',
                    child:
                        ListTile(
                      leading:
                          Icon(
                        Icons.sync,
                      ),
                      title:
                          Text(
                        'Change Status',
                      ),
                    ),
                  ),

                  PopupMenuItem(
                    value:
                        'toggle',
                    child:
                        ListTile(
                      leading:
                          Icon(
                        partner
                                .isActive
                            ? Icons
                                .toggle_off_outlined
                            : Icons
                                .toggle_on_outlined,
                      ),
                      title:
                          Text(
                        partner.isActive
                            ? 'Deactivate'
                            : 'Activate',
                      ),
                    ),
                  ),

                  const PopupMenuItem(
                    value:
                        'delete',
                    child:
                        ListTile(
                      leading:
                          Icon(
                        Icons
                            .delete_outline,
                        color:
                            Colors.red,
                      ),
                      title:
                          Text(
                        'Delete',
                        style:
                            TextStyle(
                          color:
                              Colors.red,
                        ),
                      ),
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

// =========================================================
// DELIVERY PARTNER MODEL
// =========================================================

class DeliveryPartner {
  int id;
  String name;
  String mobile;
  String status;
  int assignedOrders;
  bool isActive;

  DeliveryPartner({
    required this.id,
    required this.name,
    required this.mobile,
    required this.status,
    required this.assignedOrders,
    required this.isActive,
  });

  factory DeliveryPartner.fromJson(
      Map<String, dynamic> json) {
    return DeliveryPartner(
      id: int.tryParse(
            json['id'].toString(),
          ) ??
          0,

      name:
          json['name']?.toString() ??
              '',

      mobile:
          json['mobile']?.toString() ??
              '',

      status:
          json['status']?.toString() ??
              'Offline',

      assignedOrders:
          int.tryParse(
                json['assigned_orders']
                        ?.toString() ??
                    '0',
              ) ??
              0,

      isActive:
          json['is_active'] == true,
    );
  }
}