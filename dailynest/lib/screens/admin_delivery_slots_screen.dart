import 'package:flutter/material.dart';

class DeliverySlot {
  String time;
  int capacity;
  int booked;
  bool active;

  DeliverySlot({
    required this.time,
    required this.capacity,
    required this.booked,
    required this.active,
  });
}

class AdminDeliverySlotsScreen extends StatefulWidget {
  const AdminDeliverySlotsScreen({super.key});

  @override
  State<AdminDeliverySlotsScreen> createState() =>
      _AdminDeliverySlotsScreenState();
}

class _AdminDeliverySlotsScreenState
    extends State<AdminDeliverySlotsScreen> {
  static const Color primaryColor = Color(0xFF159A93);

  final TextEditingController searchController = TextEditingController();

  final List<DeliverySlot> slots = [
    DeliverySlot(
      time: '06:00 AM - 08:00 AM',
      capacity: 30,
      booked: 18,
      active: true,
    ),
    DeliverySlot(
      time: '08:00 AM - 10:00 AM',
      capacity: 30,
      booked: 24,
      active: true,
    ),
    DeliverySlot(
      time: '10:00 AM - 12:00 PM',
      capacity: 25,
      booked: 12,
      active: true,
    ),
    DeliverySlot(
      time: '04:00 PM - 06:00 PM',
      capacity: 25,
      booked: 8,
      active: true,
    ),
    DeliverySlot(
      time: '06:00 PM - 08:00 PM',
      capacity: 20,
      booked: 5,
      active: false,
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<DeliverySlot> get filteredSlots {
    final query = searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      return slots;
    }

    return slots.where((slot) {
      return slot.time.toLowerCase().contains(query);
    }).toList();
  }

  void showSlotDialog({DeliverySlot? slot}) {
    final timeController = TextEditingController(
      text: slot?.time ?? '',
    );

    final capacityController = TextEditingController(
      text: slot?.capacity.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            slot == null ? 'Add Delivery Slot' : 'Edit Delivery Slot',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: 'Time Slot',
                    hintText: 'Example: 06:00 AM - 08:00 AM',
                    prefixIcon: Icon(
                      Icons.access_time_outlined,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: capacityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Maximum Capacity',
                    hintText: 'Example: 30',
                    prefixIcon: Icon(
                      Icons.people_outline,
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
                final time = timeController.text.trim();
                final capacity = int.tryParse(
                  capacityController.text.trim(),
                );

                if (time.isEmpty || capacity == null || capacity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter valid slot details',
                      ),
                    ),
                  );
                  return;
                }

                setState(() {
                  if (slot == null) {
                    slots.add(
                      DeliverySlot(
                        time: time,
                        capacity: capacity,
                        booked: 0,
                        active: true,
                      ),
                    );
                  } else {
                    slot.time = time;
                    slot.capacity = capacity;

                    if (slot.booked > capacity) {
                      slot.booked = capacity;
                    }
                  }
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      slot == null
                          ? 'Delivery slot added successfully'
                          : 'Delivery slot updated successfully',
                    ),
                  ),
                );
              },
              child: Text(
                slot == null ? 'Add Slot' : 'Update',
              ),
            ),
          ],
        );
      },
    );
  }

  void deleteSlot(DeliverySlot slot) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Delivery Slot',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${slot.time}"?',
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
                  slots.remove(slot);
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Delivery slot deleted successfully',
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

  Color availabilityColor(DeliverySlot slot) {
    final remaining = slot.capacity - slot.booked;

    if (remaining <= 5) {
      return Colors.red;
    }

    if (remaining <= 10) {
      return Colors.orange;
    }

    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final displayedSlots = filteredSlots;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          'Delivery Slots',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showSlotDialog();
            },
            icon: const Icon(Icons.add),
            tooltip: 'Add Delivery Slot',
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          showSlotDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Slot'),
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
                hintText: 'Search delivery slots...',
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${displayedSlots.length} Delivery Slots',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'Total: ${slots.length}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: displayedSlots.isEmpty
                ? const Center(
                    child: Text(
                      'No delivery slots found',
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
                    itemCount: displayedSlots.length,
                    itemBuilder: (context, index) {
                      final slot = displayedSlots[index];

                      final remaining =
                          slot.capacity - slot.booked;

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
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 52,
                                    width: 52,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F7F5),
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.access_time_outlined,
                                      color: primaryColor,
                                      size: 27,
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          slot.time,
                                          style: const TextStyle(
                                            fontWeight:
                                                FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),

                                        const SizedBox(height: 5),

                                        Text(
                                          'Capacity: ${slot.capacity} orders',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Switch(
                                    value: slot.active,
                                    activeThumbColor: primaryColor,
                                    onChanged: (value) {
                                      setState(() {
                                        slot.active = value;
                                      });
                                    },
                                  ),

                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        showSlotDialog(
                                          slot: slot,
                                        );
                                      }

                                      if (value == 'delete') {
                                        deleteSlot(slot);
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

                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Booked: ${slot.booked}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  Text(
                                    'Available: $remaining',
                                    style: TextStyle(
                                      color: availabilityColor(slot),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              LinearProgressIndicator(
                                value: slot.capacity == 0
                                    ? 0
                                    : slot.booked / slot.capacity,
                                minHeight: 7,
                                borderRadius:
                                    BorderRadius.circular(10),
                                color: availabilityColor(slot),
                                backgroundColor:
                                    Colors.grey.shade200,
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