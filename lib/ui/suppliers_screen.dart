import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:docelix_mobileapp/controllers/supplier_controller.dart';
import 'package:docelix_mobileapp/models/supplier_model.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  late final SupplierController controller;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<SupplierController>()
        ? Get.find<SupplierController>()
        : Get.put(SupplierController());

    _scrollController = ScrollController()
      ..addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = colorsList.colorButton;
    const backgroundColor = Color(0xFFF7F8FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Suppliers',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: Colors.white,
        /*foregroundColor: const Color(0xFF263238),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Get.toNamed('/AddSupplierScreen');
              if (result == true) {
                controller.refreshSuppliers();
              }
            },
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: colorsList.colorButton,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
        ],*/
      ),

      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Obx(
                  () => TextField(
                onChanged: controller.onSearchChanged,
                controller: null,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                decoration: InputDecoration(
                  hintText: 'Search suppliers...',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  suffixIcon: controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                    onPressed: controller.clearSearch,
                    icon: const Icon(Icons.close, size: 20),
                  )
                      : null,
                  filled: true,
                  fillColor: backgroundColor,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.suppliers.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                );
              }

              if (controller.errorMessage.value.isNotEmpty &&
                  controller.suppliers.isEmpty) {
                return _buildErrorState();
              }

              if (controller.filteredSuppliers.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.refreshSuppliers,
                color: primaryColor,
                child: ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredSuppliers.length +
                      (controller.isLoadingMore.value ? 1 : 0),
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index >=
                        controller.filteredSuppliers.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryColor,
                          ),
                        ),
                      );
                    }

                    return _buildSupplierCard(
                      controller.filteredSuppliers[index],
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.toNamed('/AddSupplierScreen');
          if (result == true) {
            controller.refreshSuppliers();
          }
        },
        backgroundColor: colorsList.colorButton,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Supplier',
          style: TextStyle(
              fontWeight: FontWeight.normal
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierCard(SupplierModel supplier) {
    const primaryColor = Color(0xFF2E7D32);
    const secondaryText = Color(0xFF757575);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.toNamed('/SupplierDetailsScreen', arguments: supplier);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.business_outlined,
                      color: primaryColor,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplier.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF263238),
                          ),
                        ),
                        if ((supplier.contactName ?? '').isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            supplier.contactName!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: secondaryText,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: supplier.isActive
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      supplier.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 11,
                        color: supplier.isActive
                            ? primaryColor
                            : secondaryText,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
              if ((supplier.phone ?? '').isNotEmpty ||
                  (supplier.email ?? '').isNotEmpty) ...[
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 12),
                if ((supplier.phone ?? '').isNotEmpty)
                  _infoRow(
                    Icons.phone_outlined,
                    supplier.phone!,
                  ),
                if ((supplier.email ?? '').isNotEmpty) ...[
                  if ((supplier.phone ?? '').isNotEmpty)
                    const SizedBox(height: 8),
                  _infoRow(
                    Icons.mail_outline,
                    supplier.email!,
                  ),
                ],
              ],
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _summaryValue(
                        'Purchases',
                        _formatAmount(supplier.purchasesTotal),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: const Color(0xFFE0E0E0),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryValue(
                        'Outstanding',
                        _formatAmount(supplier.outstanding),
                      ),
                    ),
                  ],
                ),
              ),
              if ((supplier.city ?? '').isNotEmpty ||
                  (supplier.country ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                _infoRow(
                  Icons.location_on_outlined,
                  [
                    supplier.city,
                    supplier.country,
                  ].where((value) => (value ?? '').isNotEmpty).join(', '),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 17, color: const Color(0xFF757575)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF616161),
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF757575),
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF263238),
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 44,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF616161),
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => controller.fetchSuppliers(refresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearching = controller.searchQuery.value.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.people_outline,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              isSearching ? 'No suppliers found' : 'No suppliers available',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF424242),
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isSearching
                  ? 'Try a different name, email, or phone number.'
                  : 'Pull down to refresh the supplier list.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF757575),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}