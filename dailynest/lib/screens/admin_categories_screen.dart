import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AdminCategory {
  final int id;
  String name;
  String? parentCategory;
  bool active;

  AdminCategory({
    required this.id,
    required this.name,
    this.parentCategory,
    required this.active,
  });

  factory AdminCategory.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminCategory(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      name: json['name']?.toString() ?? '',
      parentCategory:
          json['parent_category']?.toString(),
      active: json['is_active'] == true,
    );
  }
}

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({
    super.key,
  });

  @override
  State<AdminCategoriesScreen> createState() =>
      _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState
    extends State<AdminCategoriesScreen> {
  static const Color primaryColor =
      Color(0xFF159A93);

  final TextEditingController searchController =
      TextEditingController();

  List<AdminCategory> categories = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  // =====================================
  // LOAD CATEGORIES
  // =====================================

  Future<void> loadCategories() async {
    setState(() {
      isLoading = true;
    });

    final result =
        await ApiService.getAllCategories();

    if (!mounted) return;

    if (result['success'] == true) {
      final List data =
          result['categories'] ?? [];

      setState(() {
        categories = data
            .map(
              (item) => AdminCategory.fromJson(
                Map<String, dynamic>.from(item),
              ),
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
                'Unable to load categories',
          ),
        ),
      );
    }
  }

  // =====================================
  // FILTER
  // =====================================

  List<AdminCategory> get filteredCategories {
    final query =
        searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      return categories;
    }

    return categories.where((category) {
      return category.name
              .toLowerCase()
              .contains(query) ||
          (category.parentCategory ?? '')
              .toLowerCase()
              .contains(query);
    }).toList();
  }

  // =====================================
  // ADD CATEGORY
  // =====================================

  Future<void> addCategory({
    required String name,
    String? parentCategory,
  }) async {
    final result =
        await ApiService.addCategory(
      name: name,
      parentCategory: parentCategory,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Category added successfully',
          ),
        ),
      );

      await loadCategories();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ??
                'Unable to add category',
          ),
        ),
      );
    }
  }

  // =====================================
  // EDIT CATEGORY
  // =====================================

  Future<void> editCategory({
    required int id,
    required String name,
    String? parentCategory,
  }) async {
    final result =
        await ApiService.updateCategory(
      id: id,
      name: name,
      parentCategory: parentCategory,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Category updated successfully',
          ),
        ),
      );

      await loadCategories();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ??
                'Unable to update category',
          ),
        ),
      );
    }
  }

  // =====================================
  // DELETE CATEGORY
  // =====================================

  Future<void> deleteCategory(
    AdminCategory category,
  ) async {
    final result =
        await ApiService.deleteCategory(
      category.id,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Category deleted successfully',
          ),
        ),
      );

      await loadCategories();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ??
                'Unable to delete category',
          ),
        ),
      );
    }
  }

  // =====================================
  // UPDATE STATUS
  // =====================================

  Future<void> updateCategoryStatus(
    AdminCategory category,
    bool isActive,
  ) async {
    final oldStatus = category.active;

    setState(() {
      category.active = isActive;
    });

    final result =
        await ApiService.updateCategoryStatus(
      id: category.id,
      isActive: isActive,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isActive
                ? '${category.name} activated'
                : '${category.name} deactivated',
          ),
        ),
      );
    } else {
      setState(() {
        category.active = oldStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ??
                'Unable to update category status',
          ),
        ),
      );
    }
  }

  // =====================================
  // ADD / EDIT DIALOG
  // =====================================

  void showCategoryDialog({
    AdminCategory? category,
  }) {
    final bool isEdit = category != null;

    final nameController =
        TextEditingController(
      text: category?.name ?? '',
    );

    String? selectedParent =
        category?.parentCategory;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            final parentOptions = categories
                .where(
                  (item) =>
                      item.id != category?.id,
                )
                .map((item) => item.name)
                .toSet()
                .toList();

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(18),
              ),

              title: Text(
                isEdit
                    ? 'Edit Category'
                    : 'Add Category',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      textCapitalization:
                          TextCapitalization.words,
                      decoration:
                          InputDecoration(
                        labelText:
                            'Category Name',
                        hintText:
                            'Enter category name',
                        prefixIcon:
                            const Icon(
                          Icons.category_outlined,
                        ),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    DropdownButtonFormField<String?>(
                      value: selectedParent,
                      decoration:
                          InputDecoration(
                        labelText:
                            'Parent Category',
                        prefixIcon:
                            const Icon(
                          Icons.account_tree_outlined,
                        ),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<
                            String?>(
                          value: null,
                          child: Text(
                            'None (Main Category)',
                          ),
                        ),
                        ...parentOptions.map(
                          (parent) =>
                              DropdownMenuItem<
                                  String?>(
                            value: parent,
                            child: Text(parent),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedParent = value;
                        });
                      },
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
                      const Text('Cancel'),
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

                    if (name.isEmpty) {
                      ScaffoldMessenger.of(
                        this.context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter category name',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                    );

                    if (isEdit) {
                      await editCategory(
                        id: category!.id,
                        name: name,
                        parentCategory:
                            selectedParent,
                      );
                    } else {
                      await addCategory(
                        name: name,
                        parentCategory:
                            selectedParent,
                      );
                    }
                  },

                  child: Text(
                    isEdit
                        ? 'Update'
                        : 'Add',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =====================================
  // DELETE CONFIRMATION
  // =====================================

  void showDeleteConfirmation(
    AdminCategory category,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),

          title: const Text(
            'Delete Category?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            'Are you sure you want to delete "${category.name}"?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text('Cancel'),
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
                Navigator.pop(
                  dialogContext,
                );

                await deleteCategory(
                  category,
                );
              },

              child:
                  const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // =====================================
  // DISPOSE
  // =====================================

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // =====================================
  // BUILD
  // =====================================

  @override
  Widget build(BuildContext context) {
    final displayedCategories =
        filteredCategories;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F9F9),

      appBar: AppBar(
        backgroundColor:
            Colors.white,
        foregroundColor:
            Colors.black87,
        elevation: 0,

        title: const Text(
          'Category Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(
              Icons.refresh,
            ),
            onPressed:
                loadCategories,
          ),
        ],
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor:
            primaryColor,
        foregroundColor:
            Colors.white,

        onPressed: () {
          showCategoryDialog();
        },

        icon: const Icon(
          Icons.add,
        ),

        label:
            const Text('Add Category'),
      ),

      body: Column(
        children: [
          // =================================
          // SUMMARY
          // =================================

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              8,
            ),

            child: Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    title: 'Categories',
                    value:
                        '${categories.length}',
                    icon:
                        Icons.category_outlined,
                    color:
                        primaryColor,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: _summaryCard(
                    title: 'Active',
                    value: '${categories.where(
                      (item) =>
                          item.active,
                    ).length}',
                    icon:
                        Icons.check_circle_outline,
                    color:
                        Colors.green,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: _summaryCard(
                    title: 'Inactive',
                    value: '${categories.where(
                      (item) =>
                          !item.active,
                    ).length}',
                    icon:
                        Icons.pause_circle_outline,
                    color:
                        Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // =================================
          // SEARCH
          // =================================

          Padding(
            padding:
                const EdgeInsets.all(16),

            child: TextField(
              controller:
                  searchController,

              onChanged: (_) {
                setState(() {});
              },

              decoration:
                  InputDecoration(
                hintText:
                    'Search categories...',

                prefixIcon:
                    const Icon(
                  Icons.search,
                ),

                suffixIcon:
                    searchController
                            .text
                            .isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController
                                  .clear();

                              setState(() {});
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
                      BorderRadius.circular(
                    14,
                  ),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),
          ),

          // =================================
          // COUNT
          // =================================

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            child: Row(
              children: [
                Text(
                  '${displayedCategories.length} Categories',
                  style:
                      const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const Spacer(),

                Text(
                  'Total: ${categories.length}',
                  style:
                      const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          // =================================
          // LIST
          // =================================

          Expanded(
            child: isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(
                      color:
                          primaryColor,
                    ),
                  )
                : displayedCategories
                        .isEmpty
                    ? const Center(
                        child: Text(
                          'No categories found',
                          style:
                              TextStyle(
                            color:
                                Colors.grey,
                            fontSize:
                                16,
                          ),
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
                            displayedCategories
                                .length,

                        itemBuilder:
                            (
                          context,
                          index,
                        ) {
                          final category =
                              displayedCategories[
                                  index];

                          return _categoryCard(
                            category,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // =====================================
  // CATEGORY CARD
  // =====================================

  Widget _categoryCard(
    AdminCategory category,
  ) {
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
            Container(
              height: 52,
              width: 52,

              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFE8F7F5,
                ),
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),

              child: const Icon(
                Icons.category_outlined,
                color:
                    primaryColor,
                size: 27,
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
                    category.name,
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

                  if (category.parentCategory !=
                          null &&
                      category.parentCategory!
                          .isNotEmpty)
                    Text(
                      'Parent: ${category.parentCategory}',
                      style:
                          const TextStyle(
                        color:
                            Colors.grey,
                        fontSize:
                            13,
                      ),
                    )
                  else
                    const Text(
                      'Main Category',
                      style:
                          TextStyle(
                        color:
                            Colors.grey,
                        fontSize:
                            13,
                      ),
                    ),

                  const SizedBox(
                    height: 7,
                  ),

                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          category.active
                              ? Colors
                                  .green
                                  .withOpacity(
                                  0.10,
                                )
                              : Colors
                                  .orange
                                  .withOpacity(
                                  0.10,
                                ),

                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),

                    child: Text(
                      category.active
                          ? 'Active'
                          : 'Inactive',

                      style: TextStyle(
                        color:
                            category.active
                                ? Colors
                                    .green
                                : Colors
                                    .orange,
                        fontSize:
                            11,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =================================
            // ACTIONS
            // =================================

            Column(
              children: [
                Switch(
                  value:
                      category.active,

                  activeColor:
                      primaryColor,

                  onChanged:
                      (value) {
                    updateCategoryStatus(
                      category,
                      value,
                    );
                  },
                ),

                Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      onPressed: () {
                        showCategoryDialog(
                          category:
                              category,
                        );
                      },
                      icon:
                          const Icon(
                        Icons.edit_outlined,
                        size: 20,
                      ),
                      color:
                          primaryColor,
                    ),

                    IconButton(
                      tooltip: 'Delete',
                      onPressed: () {
                        showDeleteConfirmation(
                          category,
                        );
                      },
                      icon:
                          const Icon(
                        Icons.delete_outline,
                        size: 20,
                      ),
                      color:
                          Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =====================================
  // SUMMARY CARD
  // =====================================

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(12),

      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            value,
            style:
                const TextStyle(
              fontSize: 19,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          Text(
            title,
            style:
                const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}