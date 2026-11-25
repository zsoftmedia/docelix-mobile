import 'package:docelix_mobileapp/controllers/supplier_details_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/purchase_invoices_model.dart';
import 'package:docelix_mobileapp/models/supplier_ledger_model.dart';
import 'package:docelix_mobileapp/models/supplier_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupplierDetailsScreen extends StatefulWidget {
  const SupplierDetailsScreen({super.key});

  @override
  State<SupplierDetailsScreen> createState() => _SupplierDetailsScreenState();
}

class _SupplierDetailsScreenState extends State<SupplierDetailsScreen> {
  final SupplierDetailsController controller =
      Get.put(SupplierDetailsController());

  static const Color _navyText = Color(0xFF0A2342);
  static const Color _secondaryText = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: Get.back,
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 18,
              color: _navyText,
            ),
          ),
        ),
        title: Obx(() {
          final supplierName = controller.supplier.value?.name ?? 'Supplier';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Supplier Details',
                style: TextStyle(
                  color: _navyText,
                  fontSize: rs.sp(17),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                supplierName,
                style: const TextStyle(
                  color: _secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          );
        }),
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: Obx(() {
        final supplier = controller.supplier.value;

        if (supplier == null) {
          return const Center(
            child: Text(
              'Supplier information not available.',
              style: TextStyle(
                color: _secondaryText,
                fontSize: 15,
              ),
            ),
          );
        }

        return SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: rs.isPhone ? rs.pagePaddingH : 16.0,
                    vertical: rs.s(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ====================================================
                      // 1. HEADER SUPPLIER SUMMARY CARD (TOP CARD)
                      // ====================================================
                      _buildHeaderCard(context, supplier),

                      const SizedBox(height: 16),

                      // ====================================================
                      // 2. FINANCIAL SUMMARY CARD
                      // ====================================================
                      const Text(
                        'Financial Summary',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _navyText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildFinancialSummaryCard(context, supplier),

                      const SizedBox(height: 16),

                      // ====================================================
                      // 3. TAB BAR SEGMENT (Overview, Purchases, Ledger)
                      // ====================================================
                      _buildTabBar(context),

                      const SizedBox(height: 16),

                      // ====================================================
                      // 4. TAB CONTENT BUILDER
                      // ====================================================
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _buildTabContent(
                          context: context,
                          supplier: supplier,
                        ),
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),

      // ======================================================
      // STICKY BOTTOM ACTIONS BAR
      // ======================================================
      bottomNavigationBar: Obx(() {
        if (controller.supplier.value == null) {
          return const SizedBox.shrink();
        }

        return _buildStickyBottomActionBar(context);
      }),
    );
  }

  // ================================================================
  // 1. HEADER SUPPLIER SUMMARY CARD (TOP CARD)
  // ================================================================
  Widget _buildHeaderCard(BuildContext context, SupplierModel supplier) {
    final rs = context.rs;
    final initials = _getSupplierInitials(supplier.name);

    final String fullAddress = [
      supplier.addressLine1,
      supplier.addressLine2,
      supplier.city,
      supplier.postalCode,
      supplier.country,
    ].where((part) => part != null && part.trim().isNotEmpty).join(', ');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs.isPhone ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF007A55),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _navyText,
                      ),
                    ),
                    if ((supplier.contactName ?? '').isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        supplier.contactName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _secondaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: supplier.isActive
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: supplier.isActive
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: supplier.isActive
                            ? const Color(0xFF059669)
                            : const Color(0xFF64748B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      supplier.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: supplier.isActive
                            ? const Color(0xFF059669)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if ((supplier.phone ?? '').isNotEmpty ||
              (supplier.email ?? '').isNotEmpty ||
              fullAddress.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            if ((supplier.phone ?? '').isNotEmpty)
              _contactRow(Icons.phone_outlined, supplier.phone!),
            if ((supplier.email ?? '').isNotEmpty) ...[
              if ((supplier.phone ?? '').isNotEmpty) const SizedBox(height: 6),
              _contactRow(Icons.mail_outline_rounded, supplier.email!),
            ],
            if (fullAddress.isNotEmpty) ...[
              if ((supplier.phone ?? '').isNotEmpty || (supplier.email ?? '').isNotEmpty)
                const SizedBox(height: 6),
              _contactRow(Icons.location_on_outlined, fullAddress),
            ],
          ],

          const SizedBox(height: 18),

          // 3 ACTION BOX BUTTONS ROW (Edit, Export Statement, Share)
          Row(
            children: [
              Expanded(
                child: _actionBoxButton(
                  context: context,
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  onTap: controller.openEditSupplier,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionBoxButton(
                  context: context,
                  icon: Icons.picture_as_pdf_outlined,
                  label: 'Statement',
                  onTap: controller.exportStatement,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionBoxButton(
                  context: context,
                  icon: Icons.refresh_rounded,
                  label: 'Refresh',
                  onTap: () {
                    controller.refreshSupplierData();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: _secondaryText),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              color: _navyText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionBoxButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final rs = context.rs;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: rs.isPhone ? 10 : 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: rs.isPhone ? 18 : 20, color: _navyText),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: rs.isPhone ? 11.5 : 12,
                fontWeight: FontWeight.w600,
                color: _navyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // 2. FINANCIAL SUMMARY CARD
  // ================================================================
  Widget _buildFinancialSummaryCard(BuildContext context, SupplierModel supplier) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryValue(
              'Purchases',
              controller.formatCurrency(supplier.purchasesTotal, null),
              _navyText,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: const Color(0xFFE2E8F0),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _summaryValue(
                'Paid',
                controller.formatCurrency(supplier.paidTotal, null),
                const Color(0xFF059669),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: const Color(0xFFE2E8F0),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _summaryValue(
                'Outstanding',
                controller.formatCurrency(supplier.outstanding, null),
                supplier.outstanding > 0 ? const Color(0xFFDC2626) : _secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryValue(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: _secondaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // 3. TAB BAR SEGMENT (Overview, Purchases, Supplier Ledger)
  // ================================================================
  Widget _buildTabBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(
            controller.tabs.length,
            (index) {
              final bool isSelected = controller.selectedTab.value == index;

              return GestureDetector(
                onTap: () => controller.changeTab(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? colorsList.colorButton : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    controller.tabs[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : _secondaryText,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ================================================================
  // 4. TAB CONTENT BUILDER
  // ================================================================
  Widget _buildTabContent({
    required BuildContext context,
    required SupplierModel supplier,
  }) {
    switch (controller.selectedTab.value) {
      case 0:
        return _buildSupplierDetailsSection(context, supplier);

      case 1:
        if (controller.isLoadingPurchases.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (controller.purchases.isEmpty) {
          return _buildEmptyTab(
            icon: Icons.shopping_bag_outlined,
            title: 'No Purchases Found',
            subtitle: 'There are no purchase records for this supplier.',
          );
        }

        return _buildPurchasesList(context: context);

      case 2:
        if (controller.isLoadingLedger.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (controller.supplierLedger.value == null ||
            controller.supplierLedger.value!.entries.isEmpty) {
          return _buildEmptyTab(
            icon: Icons.receipt_long_outlined,
            title: 'No Supplier Ledger Found',
            subtitle: 'There are no ledger entries available for this supplier.',
          );
        }

        return _buildSupplierLedgerView(
          context: context,
          ledger: controller.supplierLedger.value!,
        );

      default:
        return _buildSupplierDetailsSection(context, supplier);
    }
  }

  // ================================================================
  // OVERVIEW TAB: SUPPLIER DETAILS CARD
  // ================================================================
  Widget _buildSupplierDetailsSection(BuildContext context, SupplierModel supplier) {
    return Container(
      key: const ValueKey('supplier_details_section'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Supplier Details',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _navyText,
            ),
          ),
          const SizedBox(height: 14),

          _detailRow('Supplier ID', '#${supplier.id}'),
          _detailRow('VAT ID', supplier.vatId ?? '—'),
          _detailRow('Tax ID', supplier.taxId ?? '—'),
          _detailRow('IBAN', supplier.iban ?? '—'),
          _detailRow(
            'Payment Terms',
            supplier.paymentTermsDays != null
                ? '${supplier.paymentTermsDays} Days'
                : '—',
          ),
          _detailRow('Website', supplier.website ?? '—'),
          _detailRow('Notes', (supplier.notes ?? '').isNotEmpty ? supplier.notes! : '—', showBorder: false),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool showBorder = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: _secondaryText,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _navyText,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showBorder)
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
      ],
    );
  }

  // ================================================================
  // PURCHASES LIST TAB VIEW (RESPONSIVE GRID FOR TABLETS)
  // ================================================================
  Widget _buildPurchasesList({required BuildContext context}) {
    final rs = context.rs;
    final cols = rs.listColumns;
    final purchases = controller.purchases;

    if (cols > 1) {
      return GridView.builder(
        key: const ValueKey('purchases_list_grid_tab'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: rs.isTablet
              ? (rs.isLandscape ? 2.80 : 2.35)
              : (rs.isLandscape ? 2.4 : 1.6),
        ),
        itemCount: purchases.length,
        itemBuilder: (context, index) {
          return _buildPurchaseCardItem(context, purchases[index], asGridTile: true);
        },
      );
    }

    return Column(
      key: const ValueKey('purchases_list_tab'),
      children: purchases.map((purchase) {
        return _buildPurchaseCardItem(context, purchase, asGridTile: false);
      }).toList(),
    );
  }

  Widget _buildPurchaseCardItem(BuildContext context, PurchaseInvoicesModel purchase, {bool asGridTile = false}) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    final purchaseNo = purchase.purchaseNumber ?? purchase.invoiceNumber ?? '—';
    final suppInvoiceNo = purchase.supplierInvoiceNumber ?? '—';
    final purchaseDate = purchase.invoiceDate ?? '—';
    final dueDate = purchase.dueDate ?? '—';
    final totalStr = controller.formatCurrency(purchase.totalAmount, purchase.currency);
    final outstandingStr = controller.formatCurrency(purchase.outstandingAmount, purchase.currency);

    final paymentStatusStr = (purchase.paymentStatus != null && purchase.paymentStatus!.isNotEmpty)
        ? purchase.paymentStatus!
        : (purchase.status == 'posted' ? 'Paid' : 'Unpaid');

    return Container(
      margin: EdgeInsets.only(bottom: asGridTile ? 0 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Get.toNamed('/PurchaseDetailsScreen', arguments: purchase.id);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isTab ? 14 : rs.s(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            purchaseNo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isTab ? 14 : rs.sp(14),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF063C70),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Supplier Inv: $suppInvoiceNo',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isTab ? 12 : rs.sp(12),
                              color: _secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          totalStr,
                          style: TextStyle(
                            fontSize: isTab ? 14 : rs.sp(14),
                            fontWeight: FontWeight.bold,
                            color: _navyText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            paymentStatusStr.capitalizeFirst ?? paymentStatusStr,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _miniDetail('Date', purchaseDate),
                    _miniDetail('Due Date', dueDate),
                    _miniDetail('Outstanding', outstandingStr, isBold: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniDetail(String label, String value, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            color: _secondaryText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: _navyText,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // SUPPLIER LEDGER TAB VIEW
  // ================================================================
  Widget _buildSupplierLedgerView({
    required BuildContext context,
    required SupplierLedgerModel ledger,
  }) {
    return Column(
      key: const ValueKey('supplier_ledger_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Supplier Balance',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _navyText,
                ),
              ),
              Text(
                controller.formatCurrency(ledger.balance, null),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: ledger.balance > 0 ? const Color(0xFFDC2626) : const Color(0xFF059669),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        const Text(
          'Ledger Entries',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _navyText,
          ),
        ),
        const SizedBox(height: 8),

        ...ledger.entries.map((entry) {
          final isPurchase = entry.type.toLowerCase() == 'purchase';
          final typeColor = isPurchase ? const Color(0xFFDC2626) : const Color(0xFF059669);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _cardBorder),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {
                  if (entry.purchaseId > 0) {
                    Get.toNamed('/PurchaseDetailsScreen', arguments: entry.purchaseId);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isPurchase ? Icons.shopping_bag_outlined : Icons.payments_outlined,
                              color: typeColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.description.isNotEmpty ? entry.description : entry.reference,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: _navyText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Ref: ${entry.reference} • ${entry.date}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: _secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              entry.type.capitalizeFirst ?? entry.type,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: typeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _miniDetail('Debit', controller.formatCurrency(entry.debit, null)),
                          _miniDetail('Credit', controller.formatCurrency(entry.credit, null)),
                          _miniDetail('Balance', controller.formatCurrency(entry.balance, null), isBold: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ================================================================
  // EMPTY TAB PLACEHOLDER
  // ================================================================
  Widget _buildEmptyTab({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      key: ValueKey(title),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2563EB),
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: _navyText,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _secondaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // STICKY BOTTOM ACTION BAR (MATCHING SCREENSHOT)
  // ================================================================
  Widget _buildStickyBottomActionBar(BuildContext context) {
    final rs = context.rs;

    return Container(
      padding: EdgeInsets.fromLTRB(
        rs.isPhone ? 16 : 20,
        12,
        rs.isPhone ? 16 : 20,
        16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: _cardBorder),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // MAIN ACTION BUTTON: EDIT SUPPLIER
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.openEditSupplier,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A2342),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: rs.isPhone ? 12 : 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: Icon(Icons.edit_outlined, size: rs.isPhone ? 15 : 16),
                label: Text(
                  'Edit Supplier',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: rs.isPhone ? 13 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(width: rs.isPhone ? 8 : 10),

            // CIRCULAR EXPORT STATEMENT BUTTON
            _circularActionButton(
              context: context,
              icon: Icons.picture_as_pdf_outlined,
              iconColor: _navyText,
              bgColor: const Color(0xFFF1F5F9),
              onTap: controller.exportStatement,
            ),

            SizedBox(width: rs.isPhone ? 6 : 8),

            // CIRCULAR REFRESH BUTTON
            _circularActionButton(
              context: context,
              icon: Icons.refresh_rounded,
              iconColor: _navyText,
              bgColor: const Color(0xFFF1F5F9),
              onTap: () {
                controller.refreshSupplierData();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _circularActionButton({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    final rs = context.rs;
    final size = rs.isPhone ? 40.0 : 44.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: rs.isPhone ? 18 : 20,
        ),
      ),
    );
  }

  // ================================================================
  // HELPER METHODS
  // ================================================================
  String _getSupplierInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'S';
    if (parts.length == 1) return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}