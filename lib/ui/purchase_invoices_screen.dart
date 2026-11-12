import 'package:docelix_mobileapp/controllers/purchase_invoices_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/purchase_invoices_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PurchaseInvoicesScreen extends StatefulWidget {
  const PurchaseInvoicesScreen({super.key});

  @override
  State<PurchaseInvoicesScreen> createState() => _PurchaseInvoicesScreenState();
}

class _PurchaseInvoicesScreenState extends State<PurchaseInvoicesScreen> {
  final PurchaseInvoicesController incomingInvoicesController =
      Get.put(PurchaseInvoicesController());

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
                        'Purchase Invoices',
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
              // 2. STATUS TABS SEGMENT
              // ======================================================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                child: Container(
                  height: rs.s(42),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
                                  horizontal: rs.s(16),
                                  vertical: rs.s(6),
                                ),
                                margin: EdgeInsets.only(right: rs.s(4)),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorsList.colorButton
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
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

              SizedBox(height: rs.s(16)),

              // ======================================================
              // 3. TITLE & SUBTITLE SECTION
              // ======================================================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Purchase Invoices',
                      style: TextStyle(
                        color: const Color(0xFF0A2342),
                        fontSize: rs.sp(22),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: rs.s(2)),
                    Text(
                      'Upload, track, and organize your supplier & incoming invoices.',
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
              // 4. SEARCH BAR
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

              // ======================================================
              // 5. INVOICES LIST
              // ======================================================
              Expanded(
                child: Obx(() {
                  if (incomingInvoicesController.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (incomingInvoicesController.filteredInvoices.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: incomingInvoicesController.refreshInvoices,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: rs.s(120)),
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
                        childAspectRatio: rs.isLandscape ? 2.6 : 1.8,
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
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddInvoiceBottomSheet(context),
        backgroundColor: colorsList.colorButton,
        foregroundColor: colorsList.colorWhite,
        elevation: 4,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: Text(
          'Add Invoice',
          style: TextStyle(
            fontSize: rs.sp(15),
            fontWeight: FontWeight.w700,
            color: colorsList.colorWhite,
          ),
        ),
      ),
    );
  }

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
  }) {
    final rs = context.rs;
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
      margin: EdgeInsets.only(bottom: rs.s(14)),
      padding: EdgeInsets.all(rs.s(16)),
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
        children: [
          // 1. TOP HEADER ROW (PURCHASE NUMBER + INVOICE TYPE PILL + MORE MENU)
          Row(
            children: [
              Expanded(
                child: Text(
                  invoice.purchaseNumber?.isNotEmpty == true
                      ? invoice.purchaseNumber!
                      : (invoice.invoiceNumber?.isNotEmpty == true
                          ? invoice.invoiceNumber!
                          : 'PUR-#${invoice.id}'),
                  style: TextStyle(
                    color: const Color(0xFF0A2342),
                    fontSize: rs.sp(16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: rs.s(10),
                  vertical: rs.s(4),
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
                    SizedBox(width: rs.s(5)),
                    Text(
                      displayStatus,
                      style: TextStyle(
                        color: pillText,
                        fontSize: rs.sp(11),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: rs.s(4)),
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

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // 2. MIDDLE DETAILS 2X3 GRID
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT COLUMN (SUPPLIER, DATE, ACCOUNT)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statField('SUPPLIER', invoice.supplierName ?? '—', isItalic: true),
                    SizedBox(height: rs.s(10)),
                    _statField('DATE', formattedDate),
                    SizedBox(height: rs.s(10)),
                    _statField('ACCOUNT', invoice.expenseAccountCode ?? invoice.expenseCategory ?? '—'),
                  ],
                ),
              ),

              // RIGHT COLUMN (SUPPLIER INV NO, DUE DATE)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statField('SUPPLIER INV NO.', invoice.supplierInvoiceNumber ?? '—'),
                    SizedBox(height: rs.s(10)),
                    _statField('DUE DATE', formattedDueDate),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // 3. BOTTOM AMOUNTS ROW (PAID | TOTAL)
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PAID',
                    style: TextStyle(
                      fontSize: rs.sp(10),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: rs.s(2)),
                  Text(
                    '${incomingInvoicesController.getCurrencySymbol(invoice.currency)}0.00',
                    style: TextStyle(
                      fontSize: rs.sp(13),
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
                      fontSize: rs.sp(10),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: rs.s(2)),
                  Text(
                    formattedTotal,
                    style: TextStyle(
                      fontSize: rs.sp(16),
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

  Widget _statField(String label, String value, {bool isItalic = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
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
}