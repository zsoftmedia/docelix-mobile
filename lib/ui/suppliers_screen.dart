import 'package:docelix_mobileapp/controllers/supplier_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/supplier_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

    _scrollController = ScrollController()..addListener(_onScroll);
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
    final rs = context.rs;
    const primaryColor = colorsList.colorButton;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      body: SafeArea(
        child: ResponsivePage(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ======================================================
              // 1. TOP BAR (BACK BUTTON & TITLE)
              // ======================================================
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: rs.pagePaddingH,
                  vertical: rs.s(12),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2ECF8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF063C70),
                          size: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Suppliers',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF0A2342),
                          fontSize: rs.sp(18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // Balance back button
                  ],
                ),
              ),

              SizedBox(height: rs.s(8)),

              // ======================================================
              // 2. TITLE & SUBTITLE SECTION
              // ======================================================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suppliers',
                      style: TextStyle(
                        color: const Color(0xFF0A2342),
                        fontSize: rs.sp(22),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: rs.s(2)),
                    Text(
                      'Who you buy from, what you have purchased and what is still open.',
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: rs.sp(12),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: rs.s(14)),

              // ======================================================
              // 3. SEARCH BAR
              // ======================================================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                child: Container(
                  height: rs.s(44),
                  padding: EdgeInsets.symmetric(horizontal: rs.s(14)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: colorsList.borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF94A3B8),
                        size: 20,
                      ),
                      SizedBox(width: rs.s(10)),
                      Expanded(
                        child: TextField(
                          onChanged: controller.onSearchChanged,
                          style: TextStyle(
                            color: const Color(0xFF0A2342),
                            fontSize: rs.sp(13),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Search here',
                            hintStyle: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      Obx(() {
                        if (controller.searchQuery.value.isNotEmpty) {
                          return IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                            onPressed: () => controller.clearSearch(),
                          );
                        }
                        return const Icon(
                          Icons.tune_rounded,
                          color: Color(0xFF94A3B8),
                          size: 18,
                        );
                      }),
                    ],
                  ),
                ),
              ),

              SizedBox(height: rs.s(14)),

              // ======================================================
              // 4. SUPPLIER LIST
              // ======================================================
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.suppliers.isEmpty) {
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
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: rs.pagePaddingH,
                        right: rs.pagePaddingH,
                        bottom: rs.s(96),
                      ),
                      itemCount: controller.filteredSuppliers.length +
                          (controller.isLoadingMore.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= controller.filteredSuppliers.length) {
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

                        final supplier = controller.filteredSuppliers[index];
                        return _buildSupplierCard(supplier, context);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.toNamed('/AddSupplierScreen');
          if (result == true) {
            controller.refreshSuppliers();
          }
        },
        backgroundColor: colorsList.colorButton,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: Text(
          'Add Supplier',
          style: TextStyle(
            fontSize: rs.sp(15),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _showSupplierActions(BuildContext context, SupplierModel supplier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ResponsiveSheetBody(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.visibility_outlined, color: Color(0xFF2563EB)),
                  title: const Text('View Supplier Details'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Get.toNamed('/SupplierDetailsScreen', arguments: supplier);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierCard(SupplierModel supplier, BuildContext context) {
    final rs = context.rs;
    final initials = _getInitials(supplier.name);
    final contactStr = _getContactString(supplier);

    return Container(
      margin: EdgeInsets.only(bottom: rs.s(14)),
      decoration: BoxDecoration(
        color: colorsList.colorWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: colorsList.colorWhite,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Get.toNamed('/SupplierDetailsScreen', arguments: supplier);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(rs.s(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TOP HEADER ROW (INITIALS + NAME + STATUS PILL + MORE MENU)
                Row(
                  children: [
                    Container(
                      width: rs.s(38),
                      height: rs.s(38),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0D9488),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: rs.sp(13),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: rs.s(12)),
                    Expanded(
                      child: Text(
                        supplier.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: rs.sp(16),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0A2342),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rs.s(10),
                        vertical: rs.s(4),
                      ),
                      decoration: BoxDecoration(
                        color: supplier.isActive ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: supplier.isActive ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: supplier.isActive ? const Color(0xFF059669) : const Color(0xFF64748B),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: rs.s(5)),
                          Text(
                            supplier.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: rs.sp(11),
                              fontWeight: FontWeight.w600,
                              color: supplier.isActive ? const Color(0xFF059669) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: rs.s(4)),
                    IconButton(
                      onPressed: () => _showSupplierActions(context, supplier),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.more_horiz_rounded,
                        color: Color(0xFF94A3B8),
                        size: 20,
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),

                // 2. MIDDLE DETAILS 2X3 GRID
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT COLUMN (CONTACT, CITY, TOTAL PURCHASES)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _statField(context, 'CONTACT', contactStr),
                          SizedBox(height: rs.s(10)),
                          _statField(context, 'CITY', supplier.city?.trim().isNotEmpty == true ? supplier.city! : '—'),
                          SizedBox(height: rs.s(10)),
                          _statField(context, 'TOTAL PURCHASES', '€${supplier.purchasesTotal.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),

                    // RIGHT COLUMN (TOTAL PAID, OUTSTANDING, LAST PURCHASE)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _statField(context, 'TOTAL PAID', '€${supplier.paidTotal.toStringAsFixed(2)}'),
                          SizedBox(height: rs.s(10)),
                          _statField(context, 'OUTSTANDING', '€${supplier.outstanding.toStringAsFixed(2)}'),
                          SizedBox(height: rs.s(10)),
                          _statField(context, 'LAST PURCHASE', _formatDate(supplier.lastPurchaseDate)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statField(BuildContext context, String label, String value) {
    final rs = context.rs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: rs.sp(10),
            fontWeight: FontWeight.normal,
            color: const Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: rs.s(2)),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: rs.sp(13),
            fontWeight: FontWeight.normal,
            color: const Color(0xFF0A2342),
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'S';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _getContactString(SupplierModel supplier) {
    final email = supplier.email?.trim() ?? '';
    final phone = supplier.phone?.trim() ?? '';

    if (email.isNotEmpty && phone.isNotEmpty) {
      return '$email · $phone';
    }
    if (email.isNotEmpty) return email;
    if (phone.isNotEmpty) return phone;
    return '—';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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