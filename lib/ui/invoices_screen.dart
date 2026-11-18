import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/invoices_controller.dart';
import 'package:docelix_mobileapp/controllers/quotation_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/invoices_model.dart';
import 'package:docelix_mobileapp/models/quotation_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({
    super.key,
    this.initialTab = 0,
    this.isEmbedded = false,
  });

  final int initialTab;
  final bool isEmbedded;

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final InvoicesController invoicesController = Get.put(InvoicesController());
  final QuotationController quotationController = Get.put(QuotationController());

  late int _mainTab; // 0 = Invoices, 1 = Quotation

  @override
  void initState() {
    super.initState();
    _mainTab = widget.initialTab;
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
                    /*Container(
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
                    ),*/
                    Expanded(
                      child: Text(
                        'Sales',
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

              // ======================================================
              // 2. MAIN 2-TAB SEGMENT (INVOICES | QUOTATIONS)
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
                      // Tab 0: Invoices
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
                              'Invoices',
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
                      // Tab 1: Quotations
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
                              'Quotations',
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
              // 3. TAB BODY (INVOICES OR QUOTATIONS)
              // ======================================================
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _mainTab == 0
                      ? _buildInvoicesBody(rs)
                      : _buildQuotationBody(rs),
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
            final result = await Get.toNamed(
              '/CreateInvoiceScreen',
              arguments: 'Create Invoices Screen',
            );
            if (result != null) {
              invoicesController.refreshInvoices();
            }
          } else {
            final result = await Get.toNamed('/CreateQuotationScreen');
            if (result == true) {
              quotationController.refreshQuotations();
            }
          }
        },
        backgroundColor: colorsList.colorButton,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          _mainTab == 0 ? 'Add Invoice' : 'Create Quotation',
          style: TextStyle(
            fontSize: rs.sp(15),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // INVOICES TAB BODY
  // ================================================================
  Widget _buildInvoicesBody(ResponsiveMetrics rs) {
    return Column(
      key: const ValueKey('InvoicesTab'),
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
              final selectedIndex = invoicesController.selectedStatusTabIndex.value;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(
                    InvoicesController.statusTabs.length,
                    (index) {
                      final isSelected = selectedIndex == index;
                      final tabLabel = InvoicesController.statusTabs[index];

                      return GestureDetector(
                        onTap: () => invoicesController.selectStatusTab(index),
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
                'Invoices',
                style: TextStyle(
                  color: const Color(0xFF0A2342),
                  fontSize: rs.sp(20),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: rs.s(2)),
              Text(
                'Manage, track, and organize your sales invoices.',
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
                    onChanged: invoicesController.searchInvoices,
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
                  if (invoicesController.searchQuery.value.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                      onPressed: () => invoicesController.closeSearch(),
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

        // Invoices List
        Expanded(
          child: Obx(() {
            if (invoicesController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (invoicesController.filteredInvoices.isEmpty) {
              return RefreshIndicator(
                onRefresh: invoicesController.refreshInvoices,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: rs.s(100)),
                    Center(
                      child: Text(
                        'No invoices found.',
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
            final invoices = invoicesController.filteredInvoices;

            if (cols <= 1) {
              return RefreshIndicator(
                onRefresh: invoicesController.refreshInvoices,
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
              onRefresh: invoicesController.refreshInvoices,
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
                      ? (rs.isLandscape ? 1.6 : 1.25)
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
  // QUOTATION TAB BODY
  // ================================================================
  Widget _buildQuotationBody(ResponsiveMetrics rs) {
    return Column(
      key: const ValueKey('QuotationTab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Subtitle Section
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quotations',
                style: TextStyle(
                  color: const Color(0xFF0A2342),
                  fontSize: rs.sp(20),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: rs.s(2)),
              Text(
                'Manage, track, and send quotations to customers.',
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
                    onChanged: quotationController.onSearchChanged,
                    style: TextStyle(
                      color: const Color(0xFF0A2342),
                      fontSize: rs.sp(13),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search quotation here...',
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
                  if (quotationController.searchQuery.value.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                      onPressed: () => quotationController.closeSearch(),
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

        // Quotations List
        Expanded(
          child: Obx(() {
            if (quotationController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (quotationController.filteredQuotations.isEmpty) {
              return RefreshIndicator(
                onRefresh: quotationController.refreshQuotations,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: rs.s(100)),
                    Center(
                      child: Text(
                        quotationController.searchQuery.value.isNotEmpty
                            ? 'No matching quotations found.'
                            : 'No quotations available.',
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
            final quotations = quotationController.filteredQuotations;

            if (cols <= 1) {
              return RefreshIndicator(
                onRefresh: quotationController.refreshQuotations,
                child: ListView.builder(
                  padding: EdgeInsets.only(
                    top: rs.s(4),
                    left: rs.pagePaddingH,
                    right: rs.pagePaddingH,
                    bottom: rs.s(96),
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: quotations.length,
                  itemBuilder: (context, index) {
                    return _buildQuotationCard(
                      item: quotations[index],
                      context: context,
                      asGridTile: false,
                    );
                  },
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: quotationController.refreshQuotations,
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
                      ? (rs.isLandscape ? 1.45 : 1.05)
                      : (rs.isLandscape ? 2.6 : 1.8),
                ),
                itemCount: quotations.length,
                itemBuilder: (context, index) {
                  return _buildQuotationCard(
                    item: quotations[index],
                    context: context,
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
  // INVOICE HELPER WIDGETS
  // ================================================================
  Widget _invoiceTile({
    required BuildContext context,
    required InvoicesModel invoice,
    required bool asGridTile,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final result = await Get.toNamed(
          '/InvoicesDetailsScreen',
          arguments: invoice,
        );

        if (result == true) {
          await invoicesController.refreshInvoices();
        }
      },
      child: _invoiceCard(
        context: context,
        invoice: invoice,
        asGridTile: asGridTile,
      ),
    );
  }

  void _showInvoiceActions(BuildContext context, InvoicesModel invoice) {
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
                  title: const Text('View Invoice Details'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Get.toNamed('/InvoicesDetailsScreen', arguments: invoice);
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
    required InvoicesModel invoice,
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
    } else if (status == 'pending' || status == 'unpaid' || status == 'draft') {
      pillBg = const Color(0xFFFFFBEB);
      pillBorder = const Color(0xFFFDE68A);
      pillText = const Color(0xFFD97706);
    } else if (status == 'overdue') {
      pillBg = const Color(0xFFFEF2F2);
      pillBorder = const Color(0xFFFECACA);
      pillText = const Color(0xFFDC2626);
    } else {
      pillBg = const Color(0xFFF8FAFC);
      pillBorder = const Color(0xFFE2E8F0);
      pillText = const Color(0xFF64748B);
    }

    final String displayStatus = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1)
        : 'Paid';

    final String formattedNet = invoicesController.formatCurrency(
      invoice.grossAmount,
      invoice.currencyCode,
    );

    final String formattedTotal = invoicesController.formatCurrency(
      invoice.grossAmount,
      invoice.currencyCode,
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
                  invoice.invoiceNumber.isNotEmpty
                      ? invoice.invoiceNumber
                      : 'Invoice #${invoice.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF0A2342),
                    fontSize: isTab ? 15 : rs.sp(17),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTab ? 8 : rs.s(12),
                  vertical: isTab ? 3 : rs.s(4),
                ),
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: pillBorder),
                ),
                child: Text(
                  displayStatus,
                  style: TextStyle(
                    color: pillText,
                    fontSize: isTab ? 11 : rs.sp(12),
                    fontWeight: FontWeight.w600,
                  ),
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
                    Text(
                      'CUSTOMER',
                      style: TextStyle(
                        fontSize: isTab ? 10 : rs.sp(10),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: isTab ? 2 : rs.s(2)),
                    Text(
                      invoice.clientId > 0
                          ? 'Client #${invoice.clientId}'
                          : 'no9r',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isTab ? 12 : rs.sp(13),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0A2342),
                      ),
                    ),
                    SizedBox(height: isTab ? 6 : rs.s(10)),
                    Text(
                      'DUE DATE',
                      style: TextStyle(
                        fontSize: isTab ? 10 : rs.sp(10),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: isTab ? 2 : rs.s(2)),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: Color(0xFF16A34A),
                        ),
                        SizedBox(width: isTab ? 3 : rs.s(4)),
                        Expanded(
                          child: Text(
                            invoice.dueDate?.isNotEmpty == true
                                ? invoice.dueDate!
                                : '—',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isTab ? 12 : rs.sp(13),
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DATE',
                      style: TextStyle(
                        fontSize: isTab ? 10 : rs.sp(10),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: isTab ? 2 : rs.s(2)),
                    Text(
                      invoice.issueDate.isNotEmpty
                          ? invoice.issueDate
                          : '29.09.2026',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isTab ? 12 : rs.sp(13),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0A2342),
                      ),
                    ),
                    SizedBox(height: isTab ? 6 : rs.s(10)),
                    Text(
                      'REMINDERS',
                      style: TextStyle(
                        fontSize: isTab ? 10 : rs.sp(10),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: isTab ? 2 : rs.s(2)),
                    Text(
                      invoice.reminderCount > 0
                          ? '${invoice.reminderCount}'
                          : '—',
                      style: TextStyle(
                        fontSize: isTab ? 12 : rs.sp(13),
                        color: const Color(0xFF475569),
                      ),
                    ),
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
                    'Net',
                    style: TextStyle(
                      fontSize: isTab ? 10 : rs.sp(10),
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  SizedBox(height: isTab ? 2 : rs.s(2)),
                  Text(
                    formattedNet,
                    style: TextStyle(
                      fontSize: isTab ? 12 : rs.sp(13),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0A2342),
                    ),
                  ),
                ],
              ),
              SizedBox(width: isTab ? 8 : rs.s(12)),
              Container(
                width: 1,
                height: isTab ? 18 : rs.s(24),
                color: const Color(0xFFE2E8F0),
              ),
              SizedBox(width: isTab ? 8 : rs.s(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VAT (0%)',
                    style: TextStyle(
                      fontSize: isTab ? 10 : rs.sp(10),
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  SizedBox(height: isTab ? 2 : rs.s(2)),
                  Text(
                    '${invoicesController.getCurrencySymbol(invoice.currencyCode)}0.00',
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
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: isTab ? 2 : rs.s(2)),
                  Text(
                    formattedTotal,
                    style: TextStyle(
                      fontSize: isTab ? 14 : rs.sp(15),
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

  // ================================================================
  // QUOTATION HELPER WIDGETS
  // ================================================================
  void _showQuotationActions(BuildContext context, QuotationModel item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colorsList.colorWhite,
      builder: (ctx) => ResponsiveSheetBody(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            color: colorsList.colorWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                      Text(
                        item.offerNumber.isNotEmpty ? item.offerNumber : 'Quotation #${item.id}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
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
                  leading: const Icon(Icons.visibility_outlined, color: Color(0xFF2563EB)),
                  title: const Text('View Quotation Details'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Get.toNamed('/QuotationDetailsScreen', arguments: item);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuotationCard({
    required QuotationModel item,
    required BuildContext context,
    bool asGridTile = false,
  }) {
    final rs = context.rs;
    final isTab = rs.isTablet;
    final String statusStr = item.status.toLowerCase().trim();
    Color pillBg;
    Color pillBorder;
    Color pillText;

    if (statusStr == 'accepted') {
      pillBg = const Color(0xFFECFDF5);
      pillBorder = const Color(0xFFA7F3D0);
      pillText = const Color(0xFF059669);
    } else if (statusStr == 'sent') {
      pillBg = const Color(0xFFEFF6FF);
      pillBorder = const Color(0xFFBFDBFE);
      pillText = const Color(0xFF2563EB);
    } else if (statusStr == 'rejected') {
      pillBg = const Color(0xFFFEF2F2);
      pillBorder = const Color(0xFFFECACA);
      pillText = const Color(0xFFDC2626);
    } else {
      pillBg = const Color(0xFFF1F5F9);
      pillBorder = const Color(0xFFE2E8F0);
      pillText = const Color(0xFF64748B);
    }

    final String displayStatus =
        statusStr.isNotEmpty ? statusStr[0].toUpperCase() + statusStr.substring(1) : 'Draft';

    final String dateStr = _formatDate(item.issueDate);
    final String validUntilStr = _formatDate(item.validUntil);
    final String acceptedStr = _formatDate(item.acceptedAt);

    return Container(
      margin: EdgeInsets.only(bottom: asGridTile ? 0 : rs.s(14)),
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
            Get.toNamed(
              '/QuotationDetailsScreen',
              arguments: item,
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isTab ? 14 : rs.s(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.offerNumber.isNotEmpty ? item.offerNumber : 'OFFER-#${item.id}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isTab ? 15 : rs.sp(16),
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF0A2342),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTab ? 8 : rs.s(12),
                        vertical: isTab ? 3 : rs.s(4),
                      ),
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: pillBorder),
                      ),
                      child: Text(
                        displayStatus,
                        style: TextStyle(
                          fontSize: isTab ? 11 : rs.sp(12),
                          fontWeight: FontWeight.normal,
                          color: pillText,
                        ),
                      ),
                    ),
                    SizedBox(width: isTab ? 2 : rs.s(4)),
                    IconButton(
                      onPressed: () {
                        _showQuotationActions(context, item);
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
                          _statField(context, 'CUSTOMER', item.clientName ?? '—', isTab: isTab),
                          SizedBox(height: isTab ? 6 : rs.s(10)),
                          _statField(context, 'VALID UNTIL', validUntilStr, isTab: isTab),
                          SizedBox(height: isTab ? 6 : rs.s(10)),
                          _statField(context, 'SIGNATURE', '—', isTab: isTab),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _statField(context, 'DATE', dateStr, isTab: isTab),
                          SizedBox(height: isTab ? 6 : rs.s(10)),
                          _statField(context, 'ACCEPTED', acceptedStr, isTab: isTab),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: isTab ? 10 : rs.sp(10),
                        fontWeight: FontWeight.normal,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '${item.totalAmount.toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontSize: isTab ? 14 : rs.sp(16),
                        fontWeight: FontWeight.normal,
                        color: const Color(0xFF0A2342),
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

  Widget _statField(BuildContext context, String label, String value, {bool isTab = false}) {
    final rs = context.rs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTab ? 9.5 : rs.sp(10),
            fontWeight: FontWeight.normal,
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
            fontSize: isTab ? 12 : rs.sp(13),
            fontWeight: FontWeight.normal,
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
      final day = parsed.day.toString().padLeft(2, '0');
      final month = parsed.month.toString().padLeft(2, '0');
      return '$day.$month.${parsed.year}';
    } catch (_) {
      return dateStr;
    }
  }
}