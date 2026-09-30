import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminCustomersScreen
    extends StatefulWidget {
  const AdminCustomersScreen({
    super.key,
  });

  @override
  State<AdminCustomersScreen> createState() =>
      _AdminCustomersScreenState();
}

class _AdminCustomersScreenState
    extends State<AdminCustomersScreen> {
  static const Color primaryColor =
      Color(0xFF159A93);

  final TextEditingController
      searchController =
      TextEditingController();

  List<dynamic> customers = [];

  bool isLoading = true;
  String errorMessage = '';

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();
    loadCustomers();
  }

  // =========================================================
  // LOAD CUSTOMERS
  // =========================================================

  Future<void> loadCustomers() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final result =
        await ApiService.getAllCustomers();

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        customers =
            result['customers'] ?? [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        errorMessage =
            result['message'] ??
                'Unable to load customers';
      });
    }
  }

  // =========================================================
  // FILTER CUSTOMERS
  // =========================================================

  List<dynamic> get filteredCustomers {
    final query =
        searchController.text
            .trim()
            .toLowerCase();

    if (query.isEmpty) {
      return customers;
    }

    return customers.where(
      (customer) {
        final name =
            customer['name']
                    ?.toString()
                    .toLowerCase() ??
                '';

        final email =
            customer['email']
                    ?.toString()
                    .toLowerCase() ??
                '';

        final mobile =
            customer['mobile']
                    ?.toString()
                    .toLowerCase() ??
                '';

        return name.contains(query) ||
            email.contains(query) ||
            mobile.contains(query);
      },
    ).toList();
  }

  // =========================================================
  // FORMAT DATE
  // =========================================================

  String formatDate(dynamic value) {
    if (value == null) {
      return '-';
    }

    try {
      final date =
          DateTime.parse(
        value.toString(),
      );

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (e) {
      return value.toString();
    }
  }

  // =========================================================
  // CUSTOMER DETAILS
  // =========================================================

  void showCustomerDetails(
    Map<String, dynamic> customer,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Customer Details',
            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          content:
              SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                _detailRow(
                  'Customer ID',
                  customer['id']
                      .toString(),
                  Icons
                      .person_outline,
                ),

                const Divider(),

                _detailRow(
                  'Name',
                  customer['name']
                          ?.toString() ??
                      '-',
                  Icons.person,
                ),

                const Divider(),

                _detailRow(
                  'Email',
                  customer['email']
                          ?.toString() ??
                      '-',
                  Icons.email_outlined,
                ),

                const Divider(),

                _detailRow(
                  'Mobile',
                  customer['mobile']
                          ?.toString() ??
                      '-',
                  Icons.phone_outlined,
                ),

                const Divider(),

                _detailRow(
                  'Joined',
                  formatDate(
                    customer[
                        'created_at'],
                  ),
                  Icons
                      .calendar_today_outlined,
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // DETAIL ROW
  // =========================================================

  Widget _detailRow(
    String title,
    String value,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        Icon(
          icon,
          color: primaryColor,
          size: 22,
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              Text(
                title,
                style:
                    const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              Text(
                value,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // CUSTOMER AVATAR
  // =========================================================

  Widget customerAvatar(
    String name,
  ) {
    String letter = 'C';

    if (name.trim().isNotEmpty) {
      letter =
          name.trim()[0].toUpperCase();
    }

    return CircleAvatar(
      radius: 28,
      backgroundColor:
          const Color(0xFFE8F7F5),
      child: Text(
        letter,
        style:
            const TextStyle(
          color: primaryColor,
          fontSize: 21,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final displayedCustomers =
        filteredCustomers;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F9F9),

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        backgroundColor:
            Colors.white,
        foregroundColor:
            Colors.black87,
        elevation: 0,

        title: const Text(
          'Manage Customers',
          style:
              TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed:
                isLoading
                    ? null
                    : loadCustomers,
            icon:
                const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(
                color:
                    primaryColor,
              ),
            )

          : errorMessage.isNotEmpty

              ? Center(
                  child: Padding(
                    padding:
                        const EdgeInsets
                            .all(24),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [

                        const Icon(
                          Icons
                              .error_outline,
                          color:
                              Colors.red,
                          size: 55,
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        Text(
                          errorMessage,
                          textAlign:
                              TextAlign
                                  .center,
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        ElevatedButton(
                          onPressed:
                              loadCustomers,
                          child:
                              const Text(
                            'Retry',
                          ),
                        ),
                      ],
                    ),
                  ),
                )

              : Column(
                  children: [

                    // =================================================
                    // SEARCH
                    // =================================================

                    Padding(
                      padding:
                          const EdgeInsets
                              .all(16),
                      child:
                          TextField(
                        controller:
                            searchController,

                        onChanged:
                            (_) {
                          setState(() {});
                        },

                        decoration:
                            InputDecoration(
                          hintText:
                              'Search customers...',

                          prefixIcon:
                              const Icon(
                            Icons.search,
                            color:
                                primaryColor,
                          ),

                          suffixIcon:
                              searchController
                                      .text
                                      .isNotEmpty
                                  ? IconButton(
                                      onPressed:
                                          () {
                                        searchController
                                            .clear();

                                        setState(
                                            () {});
                                      },
                                      icon:
                                          const Icon(
                                        Icons.clear,
                                      ),
                                    )
                                  : null,

                          filled: true,

                          fillColor:
                              Colors.white,

                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                            borderSide:
                                BorderSide
                                    .none,
                          ),
                        ),
                      ),
                    ),

                    // =================================================
                    // COUNT
                    // =================================================

                    Padding(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [

                          Text(
                            '${displayedCustomers.length} Customers',
                            style:
                                const TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            'Total: ${customers.length}',
                            style:
                                const TextStyle(
                              color:
                                  Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // =================================================
                    // CUSTOMER LIST
                    // =================================================

                    Expanded(
                      child:
                          displayedCustomers
                                  .isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [

                                      Icon(
                                        Icons
                                            .people_outline,
                                        size:
                                            65,
                                        color:
                                            Colors.grey,
                                      ),

                                      SizedBox(
                                        height:
                                            12,
                                      ),

                                      Text(
                                        'No customers found',
                                        style:
                                            TextStyle(
                                          fontSize:
                                              18,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  color:
                                      primaryColor,

                                  onRefresh:
                                      loadCustomers,

                                  child:
                                      ListView.builder(
                                    padding:
                                        const EdgeInsets
                                            .fromLTRB(
                                      16,
                                      5,
                                      16,
                                      30,
                                    ),

                                    itemCount:
                                        displayedCustomers
                                            .length,

                                    itemBuilder:
                                        (
                                      context,
                                      index,
                                    ) {
                                      final customer =
                                          Map<String, dynamic>.from(
                                        displayedCustomers[
                                            index],
                                      );

                                      final String name =
                                          customer[
                                                      'name']
                                                  ?.toString() ??
                                              'Customer';

                                      final String email =
                                          customer[
                                                      'email']
                                                  ?.toString() ??
                                              '-';

                                      final String mobile =
                                          customer[
                                                      'mobile']
                                                  ?.toString() ??
                                              '-';

                                      return Card(
                                        color:
                                            Colors.white,

                                        margin:
                                            const EdgeInsets
                                                .only(
                                          bottom:
                                              12,
                                        ),

                                        elevation:
                                            1,

                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            16,
                                          ),
                                        ),

                                        child:
                                            InkWell(
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            16,
                                          ),

                                          onTap:
                                              () {
                                            showCustomerDetails(
                                              customer,
                                            );
                                          },

                                          child:
                                              Padding(
                                            padding:
                                                const EdgeInsets
                                                    .all(
                                              14,
                                            ),

                                            child:
                                                Row(
                                              children: [

                                                customerAvatar(
                                                  name,
                                                ),

                                                const SizedBox(
                                                  width:
                                                      14,
                                                ),

                                                Expanded(
                                                  child:
                                                      Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [

                                                      Text(
                                                        name,
                                                        maxLines:
                                                            1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        style:
                                                            const TextStyle(
                                                          fontSize:
                                                              16,
                                                          fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                        ),
                                                      ),

                                                      const SizedBox(
                                                        height:
                                                            5,
                                                      ),

                                                      Text(
                                                        email,
                                                        maxLines:
                                                            1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        style:
                                                            const TextStyle(
                                                          color:
                                                              Colors.grey,
                                                          fontSize:
                                                              13,
                                                        ),
                                                      ),

                                                      const SizedBox(
                                                        height:
                                                            4,
                                                      ),

                                                      Text(
                                                        mobile,
                                                        style:
                                                            const TextStyle(
                                                          color:
                                                              Colors.grey,
                                                          fontSize:
                                                              13,
                                                        ),
                                                      ),

                                                      const SizedBox(
                                                        height:
                                                            5,
                                                      ),

                                                      Text(
                                                        'Joined: ${formatDate(customer['created_at'])}',
                                                        style:
                                                            const TextStyle(
                                                          color:
                                                              primaryColor,
                                                          fontSize:
                                                              12,
                                                          fontWeight:
                                                              FontWeight
                                                                  .w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                const Icon(
                                                  Icons
                                                      .chevron_right,
                                                  color:
                                                      Colors.grey,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                    ),
                  ],
                ),
    );
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}