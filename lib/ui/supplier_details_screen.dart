import 'package:docelix_mobileapp/controllers/supplier_details_controller.dart';
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

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
              Text(
                'Supplier Details',
                style: TextStyle(
                  color: colorsList.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                supplierName,
                style: TextStyle(
                  color: colorsList.textHintColor,
                  fontSize: width * 0.030,
                  fontWeight: FontWeight.w400,
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              width * 0.045,
              height * 0.018,
              width * 0.045,
              height * 0.04,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ====================================================
                // 1. HEADER SUPPLIER CARD
                // ====================================================
                _buildHeaderCard(supplier, width, height),

                SizedBox(height: height * 0.018),

                // ====================================================
                // 2. FINANCIAL SUMMARY CARD
                // ====================================================
                _sectionTitle('Financial Summary', width),
                SizedBox(height: height * 0.008),
                _buildFinancialSummaryCard(supplier, width),

                SizedBox(height: height * 0.022),

                // ====================================================
                // 3. TAB BAR (Positioned below Financial Summary)
                // ====================================================
                _buildTabBar(width, height),

                SizedBox(height: height * 0.018),

                // ====================================================
                // 4. TAB CONTENT
                // ====================================================
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildTabContent(
                    supplier: supplier,
                    width: width,
                    height: height,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ================================================================
  // 1. HEADER SUPPLIER CARD
  // ================================================================

  Widget _buildHeaderCard(
    SupplierModel supplier,
    double width,
    double height,
  ) {
    final String fullAddress = [
      supplier.addressLine1,
      supplier.addressLine2,
      supplier.city,
      supplier.postalCode,
      supplier.country,
    ].where((part) => part != null && part.trim().isNotEmpty).join(', ');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.045),
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
                width: width * 0.12,
                height: width * 0.12,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.business_outlined,
                  color: const Color(0xFF2E7D32),
                  size: width * 0.065,
                ),
              ),
              SizedBox(width: width * 0.035),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: colorsList.textColor,
                      ),
                    ),
                    if ((supplier.contactName ?? '').isNotEmpty) ...[
                      SizedBox(height: height * 0.004),
                      Text(
                        supplier.contactName!,
                        style: TextStyle(
                          fontSize: width * 0.032,
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
                    fontSize: width * 0.026,
                    color: supplier.isActive
                        ? const Color(0xFF2E7D32)
                        : colorsList.secondaryText,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          if ((supplier.email ?? '').isNotEmpty ||
              (supplier.phone ?? '').isNotEmpty ||
              fullAddress.isNotEmpty) ...[
            SizedBox(height: height * 0.015),
            const Divider(height: 1, color: Color(0xFFEBF0F5)),
            SizedBox(height: height * 0.015),
            if ((supplier.phone ?? '').isNotEmpty)
              _infoRow(
                Icons.phone_outlined,
                supplier.phone!,
                width,
              ),
            if ((supplier.email ?? '').isNotEmpty) ...[
              if ((supplier.phone ?? '').isNotEmpty)
                SizedBox(height: height * 0.008),
              _infoRow(
                Icons.mail_outline_rounded,
                supplier.email!,
                width,
              ),
            ],
            if (fullAddress.isNotEmpty) ...[
              if ((supplier.phone ?? '').isNotEmpty ||
                  (supplier.email ?? '').isNotEmpty)
                SizedBox(height: height * 0.008),
              _infoRow(
                Icons.location_on_outlined,
                fullAddress,
                width,
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

  Widget _buildFinancialSummaryCard(SupplierModel supplier, double width) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.040),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EAF1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryValue(
              'Purchases',
              controller.formatCurrency(supplier.purchasesTotal, null),
              colorsList.textColor,
              width,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: const Color(0xFFE5EAF0),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: width * 0.03),
              child: _summaryValue(
                'Paid',
                controller.formatCurrency(supplier.paidTotal, null),
                const Color(0xFF12A150),
                width,
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
              padding: EdgeInsets.only(left: width * 0.03),
              child: _summaryValue(
                'Outstanding',
                controller.formatCurrency(supplier.outstanding, null),
                const Color(0xFFD64545),
                width,
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

  Widget _buildTabBar(double width, double height) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.012),
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
                  margin: EdgeInsets.only(right: width * 0.015),
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.038,
                    vertical: height * 0.010,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorsList.primaryBlue
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    controller.tabs[index],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : colorsList.secondaryText,
                      fontSize: width * 0.031,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
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
    required SupplierModel supplier,
    required double width,
    required double height,
  }) {
    switch (controller.selectedTab.value) {
      case 0:
        return _buildSupplierDetailsSection(supplier, width);

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
            width: width,
            height: height,
          );
        }

        return _buildPurchasesList(width: width, height: height);

      case 2:
        return _buildEmptyTab(
          icon: Icons.payments_outlined,
          title: 'No Payments Found',
          subtitle: 'There are no payment transactions for this supplier.',
          width: width,
          height: height,
        );

      case 3:
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
            width: width,
            height: height,
          );
        }

        return _buildSupplierLedgerView(
          ledger: controller.supplierLedger.value!,
          width: width,
          height: height,
        );

      default:
        return _buildSupplierDetailsSection(supplier, width);
    }
  }

  // ================================================================
  // PURCHASES LIST TAB VIEW (MATCHES WEB TABLE FIELDS)
  // ================================================================

  Widget _buildPurchasesList({
    required double width,
    required double height,
  }) {
    return Column(
      key: const ValueKey('purchases_list_tab'),
      children: controller.purchases.map((purchase) {
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
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE4EAF1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
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
                padding: EdgeInsets.all(width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                style: TextStyle(
                                  fontSize: width * 0.038,
                                  fontWeight: FontWeight.normal,
                                  color: const Color(0xFF063C70),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Supplier Inv: $suppInvoiceNo',
                                style: TextStyle(
                                  fontSize: width * 0.030,
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
                                fontSize: width * 0.038,
                                fontWeight: FontWeight.normal,
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
                                          fontSize: width * 0.025,
                                          fontWeight: FontWeight.normal,
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
                                          fontSize: width * 0.025,
                                          fontWeight: FontWeight.normal,
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

                    SizedBox(height: height * 0.012),
                    const Divider(height: 1, color: Color(0xFFF0F4F8)),
                    SizedBox(height: height * 0.010),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _miniDetail('Date', purchaseDate, width),
                        _miniDetail('Due Date', dueDate, width),
                        _miniDetail('Outstanding', outstandingStr, width, isBold: true),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ================================================================
  // SUPPLIER LEDGER TAB VIEW
  // ================================================================

  Widget _buildSupplierLedgerView({
    required SupplierLedgerModel ledger,
    required double width,
    required double height,
  }) {
    return Column(
      key: const ValueKey('supplier_ledger_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Balance Summary Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(width * 0.040),
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
                  fontSize: width * 0.04,
                  fontWeight: FontWeight.normal,
                  color: colorsList.textColor,
                ),
              ),
              Text(
                controller.formatCurrency(ledger.balance, null),
                style: TextStyle(
                  fontSize: width * 0.040,
                  fontWeight: FontWeight.normal,
                  color: ledger.balance > 0
                      ? const Color(0xFFD64545)
                      : const Color(0xFF12A150),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: height * 0.018),

        _sectionTitle('Ledger Entries', width),

        SizedBox(height: height * 0.010),

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
                  color: Colors.black.withOpacity(0.02),
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
                  padding: EdgeInsets.all(width * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(
                    children: [
                      Container(
                        width: width * 0.10,
                        height: width * 0.10,
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isPurchase
                              ? Icons.shopping_bag_outlined
                              : Icons.payments_outlined,
                          color: typeColor,
                          size: width * 0.052,
                        ),
                      ),
                      SizedBox(width: width * 0.03),
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
                                fontSize: width * 0.036,
                                fontWeight: FontWeight.normal,
                                color: colorsList.textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ref: ${entry.reference} • ${entry.date}',
                              style: TextStyle(
                                fontSize: width * 0.028,
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
                          color: typeColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          entry.type.capitalizeFirst ?? entry.type,
                          style: TextStyle(
                            fontSize: width * 0.026,
                            fontWeight: FontWeight.normal,
                            color: typeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.012),
                  const Divider(height: 1, color: Color(0xFFF0F4F8)),
                  SizedBox(height: height * 0.010),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _miniDetail(
                        'Debit',
                        controller.formatCurrency(entry.debit, null),
                        width,
                      ),
                      _miniDetail(
                        'Credit',
                        controller.formatCurrency(entry.credit, null),
                        width,
                      ),
                      _miniDetail(
                        'Balance',
                        controller.formatCurrency(entry.balance, null),
                        width,
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

  Widget _buildSupplierDetailsSection(SupplierModel supplier, double width) {
    return Column(
      key: const ValueKey('supplier_details_section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Supplier Details', width),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(width * 0.045),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE4EAF1)),
          ),
          child: Column(
            children: [
              _detailRow('Supplier ID', '#${supplier.id}', width),
              _detailRow('VAT ID', supplier.vatId ?? '—', width),
              _detailRow('Tax ID', supplier.taxId ?? '—', width),
              _detailRow('IBAN', supplier.iban ?? '—', width),
              _detailRow(
                'Payment Terms',
                supplier.paymentTermsDays != null
                    ? '${supplier.paymentTermsDays} Days'
                    : '—',
                width,
              ),
              _detailRow('Website', supplier.website ?? '—', width),
              if ((supplier.notes ?? '').isNotEmpty)
                _detailRow('Notes', supplier.notes!, width, showBorder: false)
              else
                _detailRow('Notes', '—', width, showBorder: false),
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
    required IconData icon,
    required String title,
    required String subtitle,
    required double width,
    required double height,
  }) {
    return Container(
      key: ValueKey(title),
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: height * 0.06,
        horizontal: width * 0.06,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4EAF1)),
      ),
      child: Column(
        children: [
          Container(
            width: width * 0.16,
            height: width * 0.16,
            decoration: BoxDecoration(
              color: colorsList.primaryBlue.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: colorsList.primaryBlue,
              size: width * 0.08,
            ),
          ),
          SizedBox(height: height * 0.02),
          Text(
            title,
            style: TextStyle(
              color: colorsList.textColor,
              fontSize: width * 0.038,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: height * 0.008),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorsList.textHintColor,
              fontSize: width * 0.028,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // HELPER WIDGETS
  // ================================================================

  Widget _sectionTitle(String title, double width) {
    return Text(
      title,
      style: TextStyle(
        color: colorsList.textColor,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  Widget _infoRow(IconData icon, String value, double width) {
    return Row(
      children: [
        Icon(icon, size: width * 0.042, color: colorsList.secondaryText),
        SizedBox(width: width * 0.025),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: width * 0.031,
              color: colorsList.textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryValue(
    String label,
    String value,
    Color valueColor,
    double width,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: width * 0.026,
            color: colorsList.secondaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _miniDetail(String label, String value, double width, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: width * 0.026,
            color: colorsList.textHintColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: width * 0.030,
            fontWeight: FontWeight.normal,
            color: colorsList.textColor,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(
    String label,
    String value,
    double width, {
    bool showBorder = true,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: width * 0.028),
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
              fontSize: width * 0.031,
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
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: colorsList.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}