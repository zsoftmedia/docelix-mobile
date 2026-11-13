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

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorsList.iconColor,
            size: 20,
          ),
        ),
        title: Obx(() {
          final supplierName = controller.supplier.value?.name ?? 'Supplier';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Supplier Details',
                style: TextStyle(
                  color: colorsList.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                supplierName,
                style: const TextStyle(
                  color: colorsList.textHintColor,
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
                color: colorsList.textHintColor,
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
                    horizontal: rs.pagePaddingH,
                    vertical: rs.s(16),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: rs.sheetMaxWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ====================================================
                          // 1. HEADER SUPPLIER CARD
                          // ====================================================
                          _buildHeaderCard(context, supplier),

                          const SizedBox(height: 14),

                          // ====================================================
                          // 2. FINANCIAL SUMMARY CARD
                          // ====================================================
                          _sectionTitle('Financial Summary', isTab),
                          const SizedBox(height: 8),
                          _buildFinancialSummaryCard(context, supplier),

                          const SizedBox(height: 16),

                          // ====================================================
                          // 3. TAB BAR (Positioned below Financial Summary)
                          // ====================================================
                          _buildTabBar(context),

                          const SizedBox(height: 14),

                          // ====================================================
                          // 4. TAB CONTENT
                          // ====================================================
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _buildTabContent(
                              context: context,
                              supplier: supplier,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ======================================================
              // BOTTOM ACTIONS BAR (EDIT & EXPORT STATEMENT)
              // ======================================================

              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  rs.pagePaddingH,
                  12,
                  rs.pagePaddingH,
                  16,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFE5EAF0)),
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: rs.sheetMaxWidth),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: controller.openEditSupplier,
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text(
                              'Edit Supplier',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorsList.textColor,
                              side: const BorderSide(color: Color(0xFFD0D5DD)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.exportStatement,
                            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                            label: const Text(
                              'Export Statement',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorsList.colorButton,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ================================================================
  // 1. HEADER SUPPLIER CARD
  // ================================================================

  Widget _buildHeaderCard(
    BuildContext context,
    SupplierModel supplier,
  ) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    final String fullAddress = [
      supplier.addressLine1,
      supplier.addressLine2,
      supplier.city,
      supplier.postalCode,
      supplier.country,
    ].where((part) => part != null && part.trim().isNotEmpty).join(', ');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTab ? 16 : rs.s(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EAF1)),
      ),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business_outlined,
                  color: Color(0xFF2E7D32),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      style: TextStyle(
                        fontSize: isTab ? 18 : rs.sp(18),
                        fontWeight: FontWeight.bold,
                        color: colorsList.textColor,
                      ),
                    ),
                    if ((supplier.contactName ?? '').isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        supplier.contactName!,
                        style: TextStyle(
                          fontSize: isTab ? 13 : rs.sp(13),
                          color: colorsList.secondaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
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
                    fontSize: isTab ? 11 : rs.sp(11),
                    color: supplier.isActive
                        ? const Color(0xFF2E7D32)
                        : colorsList.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if ((supplier.email ?? '').isNotEmpty ||
              (supplier.phone ?? '').isNotEmpty ||
              fullAddress.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFEBF0F5)),
            const SizedBox(height: 12),
            if ((supplier.phone ?? '').isNotEmpty)
              _infoRow(
                context,
                Icons.phone_outlined,
                supplier.phone!,
              ),
            if ((supplier.email ?? '').isNotEmpty) ...[
              if ((supplier.phone ?? '').isNotEmpty)
                const SizedBox(height: 6),
              _infoRow(
                context,
                Icons.mail_outline_rounded,
                supplier.email!,
              ),
            ],
            if (fullAddress.isNotEmpty) ...[
              if ((supplier.phone ?? '').isNotEmpty ||
                  (supplier.email ?? '').isNotEmpty)
                const SizedBox(height: 6),
              _infoRow(
                context,
                Icons.location_on_outlined,
                fullAddress,
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ================================================================
  // 2. FINANCIAL SUMMARY CARD
  // ================================================================

  Widget _buildFinancialSummaryCard(BuildContext context, SupplierModel supplier) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTab ? 14 : rs.s(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EAF1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryValue(
              context,
              'Purchases',
              controller.formatCurrency(supplier.purchasesTotal, null),
              colorsList.textColor,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: const Color(0xFFE5EAF0),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: _summaryValue(
                context,
                'Paid',
                controller.formatCurrency(supplier.paidTotal, null),
                const Color(0xFF12A150),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: const Color(0xFFE5EAF0),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: _summaryValue(
                context,
                'Outstanding',
                controller.formatCurrency(supplier.outstanding, null),
                const Color(0xFFD64545),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // 3. TAB BAR (Positioned below Financial Summary)
  // ================================================================

  Widget _buildTabBar(BuildContext context) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4EAF1)),
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
                  margin: const EdgeInsets.only(right: 6),
                  padding: EdgeInsets.symmetric(
                    horizontal: isTab ? 18 : 16,
                    vertical: isTab ? 8 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorsList.colorButton
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    controller.tabs[index],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : colorsList.secondaryText,
                      fontSize: isTab ? 13 : rs.sp(13),
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
            context: context,
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
            context: context,
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
  // PURCHASES LIST TAB VIEW (RESPONSIVE GRID FOR TABLETS)
  // ================================================================

  Widget _buildPurchasesList({
    required BuildContext context,
  }) {
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
              ? (rs.isLandscape ? 1.45 : 1.10)
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

    final purchaseNo =
        purchase.purchaseNumber ?? purchase.invoiceNumber ?? '—';
    final suppInvoiceNo = purchase.supplierInvoiceNumber ?? '—';
    final purchaseDate = purchase.invoiceDate ?? '—';
    final dueDate = purchase.dueDate ?? '—';
    final totalStr = controller.formatCurrency(
      purchase.totalAmount,
      purchase.currency,
    );
    final outstandingStr = controller.formatCurrency(
      purchase.outstandingAmount,
      purchase.currency,
    );

    final paymentStatusStr =
        (purchase.paymentStatus != null && purchase.paymentStatus!.isNotEmpty)
            ? purchase.paymentStatus!
            : (purchase.status == 'posted' ? 'Paid' : 'Unpaid');

    final statusStr = purchase.status.isNotEmpty
        ? purchase.status
        : 'Draft';

    return Container(
      margin: EdgeInsets.only(bottom: asGridTile ? 0 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EAF1)),
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
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            Get.toNamed(
              '/PurchaseDetailsScreen',
              arguments: purchase.id,
            );
          },
          borderRadius: BorderRadius.circular(14),
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
                              color: colorsList.textHintColor,
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
                            color: colorsList.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF16A34A),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    paymentStatusStr.capitalizeFirst ?? paymentStatusStr,
                                    style: TextStyle(
                                      fontSize: isTab ? 11 : rs.sp(11),
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF16A34A),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 5),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF16A34A),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    statusStr.capitalizeFirst ?? statusStr,
                                    style: TextStyle(
                                      fontSize: isTab ? 11 : rs.sp(11),
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF16A34A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF0F4F8)),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _miniDetail(context, 'Date', purchaseDate),
                    _miniDetail(context, 'Due Date', dueDate),
                    _miniDetail(context, 'Outstanding', outstandingStr, isBold: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // SUPPLIER LEDGER TAB VIEW
  // ================================================================

  Widget _buildSupplierLedgerView({
    required BuildContext context,
    required SupplierLedgerModel ledger,
  }) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Column(
      key: const ValueKey('supplier_ledger_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Balance Summary Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTab ? 14 : rs.s(14)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE4EAF1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Supplier Balance',
                style: TextStyle(
                  fontSize: isTab ? 14 : rs.sp(14),
                  fontWeight: FontWeight.bold,
                  color: colorsList.textColor,
                ),
              ),
              Text(
                controller.formatCurrency(ledger.balance, null),
                style: TextStyle(
                  fontSize: isTab ? 15 : rs.sp(15),
                  fontWeight: FontWeight.bold,
                  color: ledger.balance > 0
                      ? const Color(0xFFD64545)
                      : const Color(0xFF12A150),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        _sectionTitle('Ledger Entries', isTab),

        const SizedBox(height: 8),

        ...ledger.entries.map((entry) {
          final isPurchase = entry.type.toLowerCase() == 'purchase';
          final typeColor = isPurchase
              ? const Color(0xFFD64545)
              : const Color(0xFF12A150);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE4EAF1)),
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
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () {
                  if (entry.purchaseId > 0) {
                    Get.toNamed(
                      '/PurchaseDetailsScreen',
                      arguments: entry.purchaseId,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: EdgeInsets.all(isTab ? 14 : rs.s(16)),
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
                              isPurchase
                                  ? Icons.shopping_bag_outlined
                                  : Icons.payments_outlined,
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
                                  entry.description.isNotEmpty
                                      ? entry.description
                                      : entry.reference,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: isTab ? 13 : rs.sp(13),
                                    fontWeight: FontWeight.bold,
                                    color: colorsList.textColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Ref: ${entry.reference} • ${entry.date}',
                                  style: TextStyle(
                                    fontSize: isTab ? 11 : rs.sp(11),
                                    color: colorsList.textHintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              entry.type.capitalizeFirst ?? entry.type,
                              style: TextStyle(
                                fontSize: isTab ? 11 : rs.sp(11),
                                fontWeight: FontWeight.w600,
                                color: typeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1, color: Color(0xFFF0F4F8)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _miniDetail(
                            context,
                            'Debit',
                            controller.formatCurrency(entry.debit, null),
                          ),
                          _miniDetail(
                            context,
                            'Credit',
                            controller.formatCurrency(entry.credit, null),
                          ),
                          _miniDetail(
                            context,
                            'Balance',
                            controller.formatCurrency(entry.balance, null),
                            isBold: true,
                          ),
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
  // OVERVIEW TAB: SUPPLIER DETAILS SECTION
  // ================================================================

  Widget _buildSupplierDetailsSection(BuildContext context, SupplierModel supplier) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Column(
      key: const ValueKey('supplier_details_section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Supplier Details', isTab),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTab ? 16 : rs.s(16)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE4EAF1)),
          ),
          child: Column(
            children: [
              _detailRow(context, 'Supplier ID', '#${supplier.id}'),
              _detailRow(context, 'VAT ID', supplier.vatId ?? '—'),
              _detailRow(context, 'Tax ID', supplier.taxId ?? '—'),
              _detailRow(context, 'IBAN', supplier.iban ?? '—'),
              _detailRow(
                context,
                'Payment Terms',
                supplier.paymentTermsDays != null
                    ? '${supplier.paymentTermsDays} Days'
                    : '—',
              ),
              _detailRow(context, 'Website', supplier.website ?? '—'),
              if ((supplier.notes ?? '').isNotEmpty)
                _detailRow(context, 'Notes', supplier.notes!, showBorder: false)
              else
                _detailRow(context, 'Notes', '—', showBorder: false),
            ],
          ),
        ),
      ],
    );
  }

  // ================================================================
  // EMPTY TAB PLACEHOLDER
  // ================================================================

  Widget _buildEmptyTab({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Container(
      key: ValueKey(title),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 36,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4EAF1)),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: colorsList.primaryBlue.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: colorsList.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: colorsList.textColor,
              fontSize: isTab ? 14 : rs.sp(14),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorsList.textHintColor,
              fontSize: isTab ? 12 : rs.sp(12),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // HELPER WIDGETS
  // ================================================================

  Widget _sectionTitle(String title, bool isTab) {
    return Text(
      title,
      style: TextStyle(
        color: colorsList.textColor,
        fontSize: isTab ? 15 : 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String value) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Row(
      children: [
        Icon(icon, size: 16, color: colorsList.secondaryText),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isTab ? 13 : rs.sp(13),
              color: colorsList.textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryValue(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTab ? 11 : rs.sp(11),
            color: colorsList.secondaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: isTab ? 14 : 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _miniDetail(BuildContext context, String label, String value, {bool isBold = false}) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTab ? 10.5 : rs.sp(10.5),
            color: colorsList.textHintColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isTab ? 12.5 : rs.sp(12.5),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: colorsList.textColor,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(
    BuildContext context,
    String label,
    String value, {
    bool showBorder = true,
  }) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Container(
      padding: EdgeInsets.symmetric(vertical: isTab ? 10 : 12),
      decoration: showBorder
          ? const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF0F4F8)),
              ),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTab ? 13 : rs.sp(13),
              color: colorsList.textHintColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isTab ? 13 : 13,
                fontWeight: FontWeight.bold,
                color: colorsList.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}