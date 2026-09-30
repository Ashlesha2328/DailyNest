import 'package:flutter/material.dart';

class AdminUser {
  final String name;
  final String email;
  final String mobile;
  final int orders;
  final String joinedDate;
  bool active;

  AdminUser({
    required this.name,
    required this.email,
    required this.mobile,
    required this.orders,
    required this.joinedDate,
    this.active = true,
  });
}

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  static const Color primaryColor = Color(0xFF159A93);

  final TextEditingController searchController =
      TextEditingController();

  final List<AdminUser> users = [
    AdminUser(
      name: 'Customer 1',
      email: 'customer1@gmail.com',
      mobile: '+91 98765 43210',
      orders: 8,
      joinedDate: '15 Aug 2026',
    ),
    AdminUser(
      name: 'Customer 2',
      email: 'customer2@gmail.com',
      mobile: '+91 98765 43211',
      orders: 5,
      joinedDate: '18 Aug 2026',
    ),
    AdminUser(
      name: 'Customer 3',
      email: 'customer3@gmail.com',
      mobile: '+91 98765 43212',
      orders: 12,
      joinedDate: '20 Aug 2026',
    ),
    AdminUser(
      name: 'Customer 4',
      email: 'customer4@gmail.com',
      mobile: '+91 98765 43213',
      orders: 3,
      joinedDate: '24 Aug 2026',
    ),
    AdminUser(
      name: 'Customer 5',
      email: 'customer5@gmail.com',
      mobile: '+91 98765 43214',
      orders: 7,
      joinedDate: '28 Aug 2026',
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<AdminUser> get filteredUsers {
    final query = searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      return users;
    }

    return users.where((user) {
      return user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.mobile.toLowerCase().contains(query);
    }).toList();
  }

  void showUserDetails(AdminUser user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundColor:
                        const Color(0xFFE8F7F5),
                    child: Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const Divider(height: 30),

              _detailRow(
                Icons.email_outlined,
                'Email',
                user.email,
              ),

              _detailRow(
                Icons.phone_outlined,
                'Mobile',
                user.mobile,
              ),

              _detailRow(
                Icons.shopping_bag_outlined,
                'Total Orders',
                '${user.orders}',
              ),

              _detailRow(
                Icons.calendar_today_outlined,
                'Joined',
                user.joinedDate,
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Text(
                    'Account Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  Switch(
                    value: user.active,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setState(() {
                        user.active = value;
                      });

                      Navigator.pop(context);

                      ScaffoldMessenger.of(this.context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? '${user.name} activated'
                                : '${user.name} deactivated',
                          ),
                        ),
                      );
                    },
                  ),

                  Text(
                    user.active ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: user.active
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            color: primaryColor,
            size: 21,
          ),

          const SizedBox(width: 12),

          SizedBox(
            width: 90,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedUsers = filteredUsers;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,

        title: const Text(
          'Manage Users',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
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
                hintText: 'Search name, email or mobile...',
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                Text(
                  '${displayedUsers.length} Users',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                Text(
                  'Total: ${users.length}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: displayedUsers.isEmpty
                ? const Center(
                    child: Text(
                      'No users found',
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
                      20,
                    ),
                    itemCount: displayedUsers.length,

                    itemBuilder: (context, index) {
                      final user = displayedUsers[index];

                      return Card(
                        color: Colors.white,
                        elevation: 1,
                        margin: const EdgeInsets.only(
                          bottom: 12,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),

                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(16),

                          onTap: () {
                            showUserDetails(user);
                          },

                          child: Padding(
                            padding: const EdgeInsets.all(15),

                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 27,
                                  backgroundColor:
                                      const Color(0xFFE8F7F5),

                                  child: Text(
                                    user.name
                                        .substring(0, 1)
                                        .toUpperCase(),

                                    style: const TextStyle(
                                      color: primaryColor,
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 13),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name,
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        user.email,
                                        style:
                                            const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        user.mobile,
                                        style:
                                            const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Row(
                                        children: [
                                          Text(
                                            '${user.orders} Orders',
                                            style:
                                                const TextStyle(
                                              color:
                                                  primaryColor,
                                              fontWeight:
                                                  FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          Container(
                                            padding:
                                                const EdgeInsets
                                                    .symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration:
                                                BoxDecoration(
                                              color: user.active
                                                  ? Colors.green
                                                      .withOpacity(
                                                      0.10,
                                                    )
                                                  : Colors.red
                                                      .withOpacity(
                                                      0.10,
                                                    ),
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                12,
                                              ),
                                            ),
                                            child: Text(
                                              user.active
                                                  ? 'Active'
                                                  : 'Inactive',
                                              style: TextStyle(
                                                color: user.active
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
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