import 'package:docelix_mobileapp/controllers/purchase_invoices_controller.dart';
import 'package:docelix_mobileapp/controllers/supplier_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/purchase_invoices_model.dart';
import 'package:docelix_mobileapp/models/supplier_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PurchaseInvoicesScreen extends StatefulWidget {
  const PurchaseInvoicesScreen({
    super.key,
    this.initialTab = 0,
    this.isEmbedded = false,
  });

  final int initialTab;
  final bool isEmbedded;

  @override
  State<PurchaseInvoicesScreen> createState() => _PurchaseInvoicesScreenState();
}

class _PurchaseInvoicesScreenState extends State<PurchaseInvoicesScreen> {
  final PurchaseInvoicesController incomingInvoicesController =
      Get.put(PurchaseInvoicesController());

  late final SupplierController supplierController;
  late final ScrollController _supplierScrollController;

  late int _mainTab; // 0 = Purchase Invoices, 1 = Suppliers

  @override
  void initState() {
    super.initState();
    _mainTab = widget.initialTab;

    supplierController = Get.isRegistered<SupplierController>()
        ? Get.find<SupplierController>()
        : Get.put(SupplierController());

    _supplierScrollController = ScrollController()..addListener(_onSupplierScroll);
  }

  void _onSupplierScroll() {
    if (!_supplierScrollController.hasClients) return;
    if (_supplierScrollController.position.pixels >=
        _supplierScrollController.position.maxScrollExtent - 200) {
      supplierController.loadMore();
    }
  }

  @override
  void dispose() {
    _supplierScrollController
      ..removeListener(_onSupplierScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      body: SafeArea(
        child: ResponsivePage(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ======================================================
              // 1. TOP HEADER BAR
              // ======================================================
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: rs.pagePaddingH,
                  vertical: rs.s(12),
                ),
                child: Row(
                  children: [
                    if (!widget.isEmbedded) ...[
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
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        'Purchases',
                        textAlign: widget.isEmbedded ? TextAlign.start : TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF0A2342),
                          fontSize: rs.sp(20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!widget.isEmbedded) const SizedBox(width: 40),
                  ],
                ),
              ),

              // ======================================================
              // 2. MAIN 2-TAB SEGMENT (PURCHASE INVOICES | SUPPLIERS)
              // ======================================================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                child: Container(
                  height: rs.s(44),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      // Tab 0: Purchase Invoices
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _mainTab = 0;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _mainTab == 0
                                  ? colorsList.colorButton
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Purchase Invoices',
                              style: TextStyle(
                                color: _mainTab == 0
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                                fontSize: rs.sp(13),
                                fontWeight: _mainTab == 0
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Tab 1: Suppliers
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _mainTab = 1;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _mainTab == 1
                                  ? colorsList.colorButton
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Suppliers',
                              style: TextStyle(
                                color: _mainTab == 1
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                                fontSize: rs.sp(13),
                                fontWeight: _mainTab == 1
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: rs.s(14)),

              // ======================================================
              // 3. TAB BODY (PURCHASE INVOICES OR SUPPLIERS)
              // ======================================================
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _mainTab == 0
                      ? _buildPurchaseInvoicesBody(rs)
                      : _buildSuppliersBody(rs),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_mainTab == 0) {
            _showAddInvoiceBottomSheet(context);
          } else {
            final result = await Get.toNamed('/AddSupplierScreen');
            if (result == true) {
              supplierController.refreshSuppliers();
            }
          }
        },
        backgroundColor: colorsList.colorButton,
        foregroundColor: colorsList.colorWhite,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          _mainTab == 0 ? 'Add Invoice' : 'Add Supplier',
          style: TextStyle(
            fontSize: rs.sp(15),
            fontWeight: FontWeight.w700,
            color: colorsList.colorWhite,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // PURCHASE INVOICES TAB BODY
  // ================================================================
  Widget _buildPurchaseInvoicesBody(ResponsiveMetrics rs) {
    return Column(
      key: const ValueKey('PurchaseInvoicesTab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Filter Tabs Segment
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
          child: Container(
            height: rs.s(40),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Obx(() {
              final selectedIndex = incomingInvoicesController.selectedStatusTabIndex.value;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(
                    PurchaseInvoicesController.statusTabs.length,
                    (index) {
                      final isSelected = selectedIndex == index;
                      final tabLabel = PurchaseInvoicesController.statusTabs[index];

                      return GestureDetector(
                        onTap: () => incomingInvoicesController.selectStatusTab(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: EdgeInsets.symmetric(
                            horizontal: rs.s(14),
                            vertical: rs.s(4),
                          ),
                          margin: EdgeInsets.only(right: rs.s(4)),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorsList.colorButton
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tabLabel,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                              fontSize: rs.sp(12),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ),

        SizedBox(height: rs.s(12)),

        // Title & Subtitle Section
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Purchase Invoices',
                style: TextStyle(
                  color: const Color(0xFF0A2342),
                  fontSize: rs.sp(20),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: rs.s(2)),
              Text(
                'Upload supplier invoices, receipts and credit notes review the draft, then post it to the ledger.',
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: rs.sp(12),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: rs.s(12)),

        // Search Bar
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
                    onChanged: incomingInvoicesController.searchIncomingInvoices,
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
                  if (incomingInvoicesController.searchQuery.value.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                      onPressed: () => incomingInvoicesController.closeSearch(),
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

        // Purchase Invoices List
        Expanded(
          child: Obx(() {
            if (incomingInvoicesController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (incomingInvoicesController.filteredInvoices.isEmpty) {
              return RefreshIndicator(
                onRefresh: incomingInvoicesController.refreshInvoices,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: rs.s(100)),
                    Center(
                      child: Text(
                        'No purchase invoices found.',
                        style: TextStyle(
                          color: colorsList.textHintColor,
                          fontSize: rs.sp(15),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final cols = rs.listColumns;
            final invoices = incomingInvoicesController.filteredInvoices;

            if (cols <= 1) {
              return RefreshIndicator(
                onRefresh: incomingInvoicesController.refreshInvoices,
                child: ListView.builder(
                  padding: EdgeInsets.only(
                    top: rs.s(4),
                    left: rs.pagePaddingH,
                    right: rs.pagePaddingH,
                    bottom: rs.s(96),
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    return _invoiceTile(
                      context: context,
                      invoice: invoices[index],
                      asGridTile: false,
                    );
                  },
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: incomingInvoicesController.refreshInvoices,
              child: GridView.builder(
                padding: EdgeInsets.only(
                  left: rs.pagePaddingH,
                  right: rs.pagePaddingH,
                  bottom: rs.s(96),
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: rs.s(12),
                  mainAxisSpacing: rs.s(12),
                  childAspectRatio: rs.isTablet
                      ? (rs.isLandscape ? 1.45 : 1.02)
                      : (rs.isLandscape ? 2.6 : 1.8),
                ),
                itemCount: invoices.length,
                itemBuilder: (context, index) {
                  return _invoiceTile(
                    context: context,
                    invoice: invoices[index],
                    asGridTile: true,
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  // ================================================================
  // SUPPLIERS TAB BODY
  // ================================================================
  Widget _buildSuppliersBody(ResponsiveMetrics rs) {
    const primaryColor = colorsList.colorButton;

    return Column(
      key: const ValueKey('SuppliersTab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Subtitle Section
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Suppliers',
                style: TextStyle(
                  color: const Color(0xFF0A2342),
                  fontSize: rs.sp(20),
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

        SizedBox(height: rs.s(12)),

        // Search Bar
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
                    onChanged: supplierController.onSearchChanged,
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
                  if (supplierController.searchQuery.value.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                      onPressed: () => supplierController.clearSearch(),
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

        // Suppliers List
        Expanded(
          child: Obx(() {
            if (supplierController.isLoading.value && supplierController.suppliers.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            }

            if (supplierController.errorMessage.value.isNotEmpty &&
                supplierController.suppliers.isEmpty) {
              return _buildSupplierErrorState();
            }

            if (supplierController.filteredSuppliers.isEmpty) {
              return _buildSupplierEmptyState();
            }

            return RefreshIndicator(
              onRefresh: supplierController.refreshSuppliers,
              color: primaryColor,
              child: ListView.builder(
                controller: _supplierScrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  left: rs.pagePaddingH,
                  right: rs.pagePaddingH,
                  bottom: rs.s(96),
                ),
                itemCount: supplierController.filteredSuppliers.length +
                    (supplierController.isLoadingMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= supplierController.filteredSuppliers.length) {
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

                  final supplier = supplierController.filteredSuppliers[index];
                  return _buildSupplierCard(supplier, context);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  // ================================================================
  // PURCHASE INVOICE HELPER METHODS & WIDGETS
  // ================================================================
  void _showAddInvoiceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ResponsiveSheetBody(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Purchase Document',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A2342),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_note_rounded, color: Color(0xFF2563EB)),
                  ),
                  title: const Text(
                    'Enter manually',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A2342),
                    ),
                  ),
                  subtitle: const Text(
                    'Enter purchase invoice, receipt, or credit note details manually.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final result = await Get.toNamed(
                      '/CreatePurchaseInvoiceManualScreen',
                      arguments: 'Create Purchase Invoice manually Screen',
                    );

                    if (result == true) {
                      await incomingInvoicesController.refreshInvoices();
                    }
                  },
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.upload_file_rounded, color: Color(0xFF059669)),
                  ),
                  title: const Text(
                    'Upload documents',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A2342),
                    ),
                  ),
                  subtitle: const Text(
                    'Upload supplier invoices or receipts for AI OCR processing.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final result = await Get.toNamed(
                      '/CreateIncomingInvoicesScreen',
                      arguments: 'Create Incoming Invoices Screen',
                    );

                    if (result == true) {
                      await incomingInvoicesController.refreshInvoices();
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _invoiceTile({
    required BuildContext context,
    required PurchaseInvoicesModel invoice,
    required bool asGridTile,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final result = await Get.toNamed(
          '/IncomingInvoicesDetailsScreen',
          arguments: invoice,
        );

        if (result == true) {
          await incomingInvoicesController.refreshInvoices();
        }
      },
      child: _invoiceCard(
        context: context,
        invoice: invoice,
        asGridTile: asGridTile,
      ),
    );
  }

  void _showInvoiceActions(BuildContext context, PurchaseInvoicesModel invoice) {
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
                  title: const Text('View Purchase Invoice Details'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Get.toNamed('/IncomingInvoicesDetailsScreen', arguments: invoice);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _invoiceCard({
    required BuildContext context,
    required PurchaseInvoicesModel invoice,
    bool asGridTile = false,
  }) {
    final rs = context.rs;
    final isTab = rs.isTablet;
    final String status = invoice.status.toLowerCase().trim();

    Color pillBg;
    Color pillBorder;
    Color pillText;

    if (status == 'paid') {
      pillBg = const Color(0xFFECFDF5);
      pillBorder = const Color(0xFFA7F3D0);
      pillText = const Color(0xFF059669);
    } else if (status == 'posted') {
      pillBg = const Color(0xFFEFF6FF);
      pillBorder = const Color(0xFFBFDBFE);
      pillText = const Color(0xFF2563EB);
    } else if (status == 'overdue' || status == 'rejected') {
      pillBg = const Color(0xFFFEF2F2);
      pillBorder = const Color(0xFFFECACA);
      pillText = const Color(0xFFDC2626);
    } else {
      pillBg = const Color(0xFFF1F5F9);
      pillBorder = const Color(0xFFE2E8F0);
      pillText = const Color(0xFF64748B);
    }

    final String displayStatus = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1)
        : 'Draft';

    final String formattedDate = _formatDate(invoice.invoiceDate);
    final String formattedDueDate = _formatDate(invoice.dueDate);

    final String formattedTotal = incomingInvoicesController.formatCurrency(
      invoice.totalAmount,
      invoice.currency,
    );

    return Container(
      margin: EdgeInsets.only(bottom: asGridTile ? 0 : rs.s(14)),
      padding: EdgeInsets.all(isTab ? 14 : rs.s(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorsList.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  invoice.purchaseNumber?.isNotEmpty == true
                      ? invoice.purchaseNumber!
                      : (invoice.invoiceNumber?.isNotEmpty == true
                          ? invoice.invoiceNumber!
                          : 'PUR-#${invoice.id}'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF0A2342),
                    fontSize: isTab ? 15 : rs.sp(16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTab ? 8 : rs.s(10),
                  vertical: isTab ? 3 : rs.s(4),
                ),
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: pillBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: pillText,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: isTab ? 3 : rs.s(5)),
                    Text(
                      displayStatus,
                      style: TextStyle(
                        color: pillText,
                        fontSize: isTab ? 11 : rs.sp(11),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isTab ? 2 : rs.s(4)),
              IconButton(
                onPressed: () {
                  _showInvoiceActions(context, invoice);
                },
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

          Padding(
            padding: EdgeInsets.symmetric(vertical: isTab ? 8 : 12),
            child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statField('SUPPLIER', invoice.supplierName ?? '—', isItalic: true, isTab: isTab),
                    SizedBox(height: isTab ? 6 : rs.s(10)),
                    _statField('DATE', formattedDate, isTab: isTab),
                    SizedBox(height: isTab ? 6 : rs.s(10)),
                    _statField('ACCOUNT', invoice.expenseAccountCode ?? invoice.expenseCategory ?? '—', isTab: isTab),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statField('SUPPLIER INV NO.', invoice.supplierInvoiceNumber ?? '—', isTab: isTab),
                    SizedBox(height: isTab ? 6 : rs.s(10)),
                    _statField('DUE DATE', formattedDueDate, isTab: isTab),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: isTab ? 8 : 12),
            child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PAID',
                    style: TextStyle(
                      fontSize: isTab ? 10 : rs.sp(10),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: isTab ? 2 : rs.s(2)),
                  Text(
                    '${incomingInvoicesController.getCurrencySymbol(invoice.currency)}0.00',
                    style: TextStyle(
                      fontSize: isTab ? 12 : rs.sp(13),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0A2342),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TOTAL',
                    style: TextStyle(
                      fontSize: isTab ? 10 : rs.sp(10),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: isTab ? 2 : rs.s(2)),
                  Text(
                    formattedTotal,
                    style: TextStyle(
                      fontSize: isTab ? 15 : rs.sp(16),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0A2342),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statField(String label, String value, {bool isItalic = false, bool isTab = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTab ? 9.5 : 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            color: const Color(0xFF0A2342),
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '—';
    try {
      final parsed = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
    } catch (_) {
      return dateStr;
    }
  }

  // ================================================================
  // SUPPLIER HELPER METHODS & WIDGETS
  // ================================================================
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
    final initials = _getSupplierInitials(supplier.name);
    final contactStr = _getSupplierContactString(supplier);

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

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _statSupplierField(context, 'CONTACT', contactStr),
                          SizedBox(height: rs.s(10)),
                          _statSupplierField(context, 'CITY', supplier.city?.trim().isNotEmpty == true ? supplier.city! : '—'),
                          SizedBox(height: rs.s(10)),
                          _statSupplierField(context, 'TOTAL PURCHASES', '€${supplier.purchasesTotal.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _statSupplierField(context, 'TOTAL PAID', '€${supplier.paidTotal.toStringAsFixed(2)}'),
                          SizedBox(height: rs.s(10)),
                          _statSupplierField(context, 'OUTSTANDING', '€${supplier.outstanding.toStringAsFixed(2)}'),
                          SizedBox(height: rs.s(10)),
                          _statSupplierField(context, 'LAST PURCHASE', _formatSupplierDate(supplier.lastPurchaseDate)),
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

  Widget _statSupplierField(BuildContext context, String label, String value) {
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

  String _getSupplierInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'S';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _getSupplierContactString(SupplierModel supplier) {
    final email = supplier.email?.trim() ?? '';
    final phone = supplier.phone?.trim() ?? '';

    if (email.isNotEmpty && phone.isNotEmpty) {
      return '$email · $phone';
    }
    if (email.isNotEmpty) return email;
    if (phone.isNotEmpty) return phone;
    return '—';
  }

  String _formatSupplierDate(DateTime? date) {
    if (date == null) return '—';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildSupplierErrorState() {
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
              supplierController.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF616161),
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => supplierController.fetchSuppliers(refresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierEmptyState() {
    final isSearching = supplierController.searchQuery.value.trim().isNotEmpty;

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