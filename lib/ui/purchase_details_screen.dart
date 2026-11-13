import 'package:docelix_mobileapp/controllers/purchase_details_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/purchase_details_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PurchaseDetailsScreen extends StatefulWidget {
  const PurchaseDetailsScreen({super.key});

  @override
  State<PurchaseDetailsScreen> createState() => _PurchaseDetailsScreenState();
}

class _PurchaseDetailsScreenState extends State<PurchaseDetailsScreen> {
  final PurchaseDetailsController controller =
      Get.put(PurchaseDetailsController());

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

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
          final pNum = controller.purchase.value?.purchaseNumber ?? 'Purchase Details';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Purchase Details',
                style: TextStyle(
                  color: colorsList.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                pNum,
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
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final item = controller.purchase.value;

        if (item == null) {
          return const Center(
            child: Text(
              'Purchase information not available.',
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
                    // 1. TOP HEADER & STATUS BADGES CARD
                    // ====================================================
                    _buildHeaderCard(context, item),

                    const SizedBox(height: 12),

                    // ====================================================
                    // 2. SUPPLIER & DOCUMENT INFO CARD
                    // ====================================================
                    _buildSupplierAndDocCard(context, item),

                    const SizedBox(height: 12),

                    // ====================================================
                    // 3. TAX & TOTALS CARD
                    // ====================================================
                    _buildTotalsCard(context, item),

                    const SizedBox(height: 12),

                    // ====================================================
                    // 4. HISTORY CARD
                    // ====================================================
                    _buildHistoryCard(context, item),

                    const SizedBox(height: 12),

                    // ====================================================
                    // 5. PURCHASED ITEMS / SERVICES CARD
                    // ====================================================
                    _buildLineItemsCard(context, item),

                    const SizedBox(height: 12),

                    // ====================================================
                    // 6. PAYMENTS CARD
                    // ====================================================
                    _buildPaymentsCard(context, item),

                    const SizedBox(height: 12),

                    // ====================================================
                    // 7. LEDGER ENTRIES CARD
                    // ====================================================
                    _buildLedgerEntriesCard(context, item),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ================================================================
  // 1. TOP HEADER & STATUS BADGES
  // ================================================================

  Widget _buildHeaderCard(BuildContext context, PurchaseDetailsModel item) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    final String statusStr = item.status.isNotEmpty ? item.status : 'Draft';
    final String payStatusStr = item.paymentStatus?.isNotEmpty == true
        ? item.paymentStatus!
        : (item.status == 'posted' ? 'Paid' : 'Unpaid');

    final String supplierText = item.supplier?.name.isNotEmpty == true
        ? item.supplier!.name
        : (item.supplierName ?? 'Supplier');

    final String subtitleText =
        '$supplierText${item.supplierInvoiceNumber != null && item.supplierInvoiceNumber!.isNotEmpty ? ' · ${item.supplierInvoiceNumber}' : ''}';

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
            children: [
              Expanded(
                child: Text(
                  item.purchaseNumber.isNotEmpty ? item.purchaseNumber : 'PURCHASE',
                  style: TextStyle(
                    fontSize: isTab ? 18 : rs.sp(18),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF063C70),
                  ),
                ),
              ),
              _badge(statusStr, const Color(0xFF16A34A)),
              const SizedBox(width: 6),
              _badge(payStatusStr, const Color(0xFF16A34A)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitleText,
            style: TextStyle(
              fontSize: isTab ? 13 : rs.sp(13),
              color: colorsList.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // 2. SUPPLIER & DOCUMENT DETAILS CARD
  // ================================================================

  Widget _buildSupplierAndDocCard(BuildContext context, PurchaseDetailsModel item) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    final supplierName = item.supplier?.name.isNotEmpty == true
        ? item.supplier!.name
        : (item.supplierName ?? '—');

    final docType = item.documentType?.isNotEmpty == true
        ? (item.documentType![0].toUpperCase() + item.documentType!.substring(1))
        : 'Invoice';

    final purchaseType = item.purchaseType?.isNotEmpty == true
        ? (item.purchaseType == 'expense' ? 'Operating expense' : item.purchaseType!)
        : 'Operating expense';

    final payMethod = item.paymentMethod?.isNotEmpty == true
        ? (item.paymentMethod![0].toUpperCase() + item.paymentMethod!.substring(1))
        : 'Bank';

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
            children: [
              Expanded(child: _gridItem(context, 'Supplier', supplierName, isPrimary: true)),
              Expanded(child: _gridItem(context, 'Document', docType)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _gridItem(context, 'Supplier invoice number',
                      item.supplierInvoiceNumber ?? '—')),
              Expanded(
                  child: _gridItem(context, 'Supplier invoice date',
                      _formatDate(item.supplierInvoiceDate))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _gridItem(
                      context, 'Purchase date', _formatDate(item.purchaseDate))),
              Expanded(
                  child: _gridItem(context, 'Due date', _formatDate(item.dueDate))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _gridItem(context, 'Purchase type', purchaseType)),
              Expanded(child: _gridItem(context, 'Payment method', payMethod)),
            ],
          ),
          const SizedBox(height: 12),
          _gridItem(context, 'Reference', item.reference ?? '—'),
        ],
      ),
    );
  }

  // ================================================================
  // 3. TAX & TOTALS CARD
  // ================================================================

  Widget _buildTotalsCard(BuildContext context, PurchaseDetailsModel item) {
    final rs = context.rs;
    final isTab = rs.isTablet;

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
          Text(
            'Tax & totals',
            style: TextStyle(
              fontSize: isTab ? 15 : rs.sp(15),
              fontWeight: FontWeight.bold,
              color: colorsList.textColor,
            ),
          ),
          const SizedBox(height: 12),
          _totalRow(context, 'Subtotal', controller.formatCurrency(item.subtotal, item.currency)),
          _totalRow(context, 'Tax', controller.formatCurrency(item.taxTotal, item.currency)),
          const Divider(height: 16, color: Color(0xFFF0F4F8)),
          _totalRow(context, 'Grand total', controller.formatCurrency(item.total, item.currency), isBold: true),
          _totalRow(context, 'Amount paid', controller.formatCurrency(item.amountPaid, item.currency)),
          _totalRow(
            context,
            'Outstanding balance',
            controller.formatCurrency(item.outstanding, item.currency),
            valueColor: const Color(0xFF16A34A),
            isBold: true,
          ),
        ],
      ),
    );
  }

  // ================================================================
  // 4. HISTORY CARD
  // ================================================================

  Widget _buildHistoryCard(BuildContext context, PurchaseDetailsModel item) {
    final rs = context.rs;
    final isTab = rs.isTablet;

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
          Text(
            'History',
            style: TextStyle(
              fontSize: isTab ? 15 : rs.sp(15),
              fontWeight: FontWeight.bold,
              color: colorsList.textColor,
            ),
          ),
          const SizedBox(height: 10),
          _historyRow(context, 'Created', _formatDate(item.createdAt)),
          _historyRow(context, 'Approved', _formatDate(item.approvedAt)),
          _historyRow(context, 'Posted to ledger', _formatDate(item.postedAt)),
        ],
      ),
    );
  }

  // ================================================================
  // 5. PURCHASED ITEMS / SERVICES CARD
  // ================================================================

  Widget _buildLineItemsCard(BuildContext context, PurchaseDetailsModel item) {
    final rs = context.rs;
    final isTab = rs.isTablet;

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
          Text(
            'Purchased items / services',
            style: TextStyle(
              fontSize: isTab ? 15 : rs.sp(15),
              fontWeight: FontWeight.bold,
              color: colorsList.textColor,
            ),
          ),
          const SizedBox(height: 12),

          if (item.lines.isEmpty)
            const Text(
              'No items added.',
              style: TextStyle(color: colorsList.textHintColor, fontSize: 13),
            )
          else
            ...item.lines.map((line) {
              final String accountText =
                  '${line.accountCode} · ${line.accountName}'.trim();

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            line.description.isNotEmpty ? line.description : 'Item',
                            style: TextStyle(
                              fontSize: isTab ? 13 : rs.sp(13),
                              fontWeight: FontWeight.bold,
                              color: colorsList.textColor,
                            ),
                          ),
                        ),
                        Text(
                          controller.formatCurrency(line.totalAmount, item.currency),
                          style: TextStyle(
                            fontSize: isTab ? 13 : rs.sp(13),
                            fontWeight: FontWeight.bold,
                            color: colorsList.textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      accountText.isNotEmpty ? accountText : '5000 · Operating Expenses',
                      style: TextStyle(
                        fontSize: isTab ? 11 : rs.sp(11),
                        color: colorsList.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _miniItemStat(context, 'Qty', _formatNum(line.quantity)),
                        _miniItemStat(
                          context,
                          'Unit price',
                          controller.formatCurrency(line.unitPrice, item.currency),
                        ),
                        _miniItemStat(context, 'Tax %', '${_formatNum(line.taxRate)}%'),
                        _miniItemStat(
                          context,
                          'Net',
                          controller.formatCurrency(line.netAmount, item.currency),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ================================================================
  // 6. PAYMENTS CARD
  // ================================================================

  Widget _buildPaymentsCard(BuildContext context, PurchaseDetailsModel item) {
    final rs = context.rs;
    final isTab = rs.isTablet;

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
          Text(
            'Payments',
            style: TextStyle(
              fontSize: isTab ? 15 : rs.sp(15),
              fontWeight: FontWeight.bold,
              color: colorsList.textColor,
            ),
          ),
          const SizedBox(height: 12),

          if (item.payments.isEmpty)
            const Text(
              'No payments recorded.',
              style: TextStyle(color: colorsList.textHintColor, fontSize: 13),
            )
          else
            ...item.payments.map((payment) {
              final payMethodStr = payment.method.isNotEmpty
                  ? payment.method[0].toUpperCase() + payment.method.substring(1)
                  : 'Bank';

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Color(0xFF16A34A),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDate(payment.paymentDate),
                            style: TextStyle(
                              fontSize: isTab ? 13 : rs.sp(13),
                              fontWeight: FontWeight.bold,
                              color: colorsList.textColor,
                            ),
                          ),
                          Text(
                            'Paid via $payMethodStr ${payment.reference != null ? '• ${payment.reference}' : ''}',
                            style: TextStyle(
                              fontSize: isTab ? 11 : rs.sp(11),
                              color: colorsList.textHintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      controller.formatCurrency(payment.amount, item.currency),
                      style: TextStyle(
                        fontSize: isTab ? 13 : rs.sp(13),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ================================================================
  // 7. LEDGER ENTRIES CARD
  // ================================================================

  Widget _buildLedgerEntriesCard(BuildContext context, PurchaseDetailsModel item) {
    final rs = context.rs;
    final isTab = rs.isTablet;

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
          Text(
            'Ledger entries',
            style: TextStyle(
              fontSize: isTab ? 15 : rs.sp(15),
              fontWeight: FontWeight.bold,
              color: colorsList.textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Journal entries created by posting, payments and voids.',
            style: TextStyle(
              fontSize: isTab ? 11 : rs.sp(11),
              color: colorsList.textHintColor,
            ),
          ),
          const SizedBox(height: 12),

          if (item.journal.isEmpty)
            const Text(
              'No ledger entries found.',
              style: TextStyle(color: colorsList.textHintColor, fontSize: 13),
            )
          else
            ...item.journal.map((entry) {
              final entryType = entry.sourceType == 'purchase_payment'
                  ? 'Payment'
                  : 'Posting';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$entryType · ${_formatDate(entry.entryDate)}',
                          style: TextStyle(
                            fontSize: isTab ? 13 : rs.sp(13),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF063C70),
                          ),
                        ),
                        Text(
                          'Entry #${entry.id}',
                          style: TextStyle(
                            fontSize: isTab ? 11 : rs.sp(11),
                            color: colorsList.textHintColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 8),

                    ...entry.lines.map((line) {
                      final accText =
                          '${line.accountCode} · ${line.accountName}'.trim();

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Text(
                                accText.isNotEmpty ? accText : 'Account',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isTab ? 12 : rs.sp(12),
                                  fontWeight: FontWeight.w500,
                                  color: colorsList.textColor,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: isTab ? 80 : 65,
                              child: Text(
                                line.debit > 0
                                    ? controller.formatCurrency(line.debit, item.currency)
                                    : '—',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: isTab ? 12 : rs.sp(12),
                                  color: colorsList.textColor,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: isTab ? 80 : 65,
                              child: Text(
                                line.credit > 0
                                    ? controller.formatCurrency(line.credit, item.currency)
                                    : '—',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: isTab ? 12 : rs.sp(12),
                                  color: colorsList.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ================================================================
  // HELPER WIDGETS
  // ================================================================

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            text.capitalizeFirst ?? text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridItem(BuildContext context, String label, String value, {bool isPrimary = false}) {
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
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: isTab ? 13 : rs.sp(13),
            fontWeight: FontWeight.bold,
            color: isPrimary ? const Color(0xFF063C70) : colorsList.textColor,
          ),
        ),
      ],
    );
  }

  Widget _totalRow(BuildContext context, String label, String value, {Color? valueColor, bool isBold = false}) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTab ? 13 : rs.sp(13),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? colorsList.textColor : colorsList.textHintColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTab ? (isBold ? 15 : 13) : rs.sp(isBold ? 15 : 13),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? colorsList.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyRow(BuildContext context, String label, String value) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTab ? 12 : rs.sp(12),
              color: colorsList.textHintColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTab ? 12 : rs.sp(12),
              fontWeight: FontWeight.w500,
              color: colorsList.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniItemStat(BuildContext context, String label, String value) {
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
            fontWeight: FontWeight.w500,
            color: colorsList.textColor,
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

  String _formatNum(double num) {
    if (num == num.roundToDouble()) {
      return num.toInt().toString();
    }
    return num.toStringAsFixed(2);
  }
}