import 'package:docelix_mobileapp/controllers/purchase_details_controller.dart';
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
          final pNum = controller.purchase.value?.purchaseNumber ?? 'Purchase Details';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Purchase Details',
                style: TextStyle(
                  color: colorsList.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                pNum,
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
                // 1. TOP HEADER & STATUS BADGES CARD
                // ====================================================
                _buildHeaderCard(item, width),

                SizedBox(height: height * 0.018),

                // ====================================================
                // 2. SUPPLIER & DOCUMENT INFO CARD
                // ====================================================
                _buildSupplierAndDocCard(item, width),

                SizedBox(height: height * 0.018),

                // ====================================================
                // 3. TAX & TOTALS CARD
                // ====================================================
                _buildTotalsCard(item, width),

                SizedBox(height: height * 0.018),

                // ====================================================
                // 4. HISTORY CARD
                // ====================================================
                _buildHistoryCard(item, width),

                SizedBox(height: height * 0.022),

                // ====================================================
                // 5. PURCHASED ITEMS / SERVICES CARD
                // ====================================================
                _buildLineItemsCard(item, width),

                SizedBox(height: height * 0.022),

                // ====================================================
                // 6. PAYMENTS CARD
                // ====================================================
                _buildPaymentsCard(item, width),

                SizedBox(height: height * 0.022),

                // ====================================================
                // 7. LEDGER ENTRIES CARD
                // ====================================================
                _buildLedgerEntriesCard(item, width),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ================================================================
  // 1. TOP HEADER & STATUS BADGES
  // ================================================================

  Widget _buildHeaderCard(PurchaseDetailsModel item, double width) {
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
            children: [
              Expanded(
                child: Text(
                  item.purchaseNumber.isNotEmpty ? item.purchaseNumber : 'PURCHASE',
                  style: TextStyle(
                    fontSize: width * 0.052,
                    fontWeight: FontWeight.w800,
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
              fontSize: width * 0.032,
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

  Widget _buildSupplierAndDocCard(PurchaseDetailsModel item, double width) {
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
            children: [
              Expanded(child: _gridItem('Supplier', supplierName, width, isPrimary: true)),
              Expanded(child: _gridItem('Document', docType, width)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _gridItem('Supplier invoice number',
                      item.supplierInvoiceNumber ?? '—', width)),
              Expanded(
                  child: _gridItem('Supplier invoice date',
                      _formatDate(item.supplierInvoiceDate), width)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _gridItem(
                      'Purchase date', _formatDate(item.purchaseDate), width)),
              Expanded(
                  child: _gridItem('Due date', _formatDate(item.dueDate), width)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _gridItem('Purchase type', purchaseType, width)),
              Expanded(child: _gridItem('Payment method', payMethod, width)),
            ],
          ),
          const SizedBox(height: 14),
          _gridItem('Reference', item.reference ?? '—', width),
        ],
      ),
    );
  }

  // ================================================================
  // 3. TAX & TOTALS CARD
  // ================================================================

  Widget _buildTotalsCard(PurchaseDetailsModel item, double width) {
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
          Text(
            'Tax & totals',
            style: TextStyle(
              fontSize: width * 0.038,
              fontWeight: FontWeight.w700,
              color: colorsList.textColor,
            ),
          ),
          const SizedBox(height: 12),
          _totalRow('Subtotal', controller.formatCurrency(item.subtotal, item.currency), width),
          _totalRow('Tax', controller.formatCurrency(item.taxTotal, item.currency), width),
          const Divider(height: 16, color: Color(0xFFF0F4F8)),
          _totalRow('Grand total', controller.formatCurrency(item.total, item.currency), width, isBold: true),
          _totalRow('Amount paid', controller.formatCurrency(item.amountPaid, item.currency), width),
          _totalRow(
            'Outstanding balance',
            controller.formatCurrency(item.outstanding, item.currency),
            width,
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

  Widget _buildHistoryCard(PurchaseDetailsModel item, double width) {
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
          Text(
            'History',
            style: TextStyle(
              fontSize: width * 0.038,
              fontWeight: FontWeight.w700,
              color: colorsList.textColor,
            ),
          ),
          const SizedBox(height: 12),
          _historyRow('Created', _formatDate(item.createdAt), width),
          _historyRow('Approved', _formatDate(item.approvedAt), width),
          _historyRow('Posted to ledger', _formatDate(item.postedAt), width),
        ],
      ),
    );
  }

  // ================================================================
  // 5. PURCHASED ITEMS / SERVICES CARD
  // ================================================================

  Widget _buildLineItemsCard(PurchaseDetailsModel item, double width) {
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
          Text(
            'Purchased items / services',
            style: TextStyle(
              fontSize: width * 0.038,
              fontWeight: FontWeight.w700,
              color: colorsList.textColor,
            ),
          ),
          const SizedBox(height: 14),

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
                              fontSize: width * 0.036,
                              fontWeight: FontWeight.w700,
                              color: colorsList.textColor,
                            ),
                          ),
                        ),
                        Text(
                          controller.formatCurrency(line.totalAmount, item.currency),
                          style: TextStyle(
                            fontSize: width * 0.036,
                            fontWeight: FontWeight.w700,
                            color: colorsList.textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      accountText.isNotEmpty ? accountText : '5000 · Operating Expenses',
                      style: TextStyle(
                        fontSize: width * 0.028,
                        color: colorsList.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _miniItemStat('Qty', '${_formatNum(line.quantity)}', width),
                        _miniItemStat(
                          'Unit price',
                          controller.formatCurrency(line.unitPrice, item.currency),
                          width,
                        ),
                        _miniItemStat('Tax %', '${_formatNum(line.taxRate)}%', width),
                        _miniItemStat(
                          'Net',
                          controller.formatCurrency(line.netAmount, item.currency),
                          width,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  // ================================================================
  // 6. PAYMENTS CARD
  // ================================================================

  Widget _buildPaymentsCard(PurchaseDetailsModel item, double width) {
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
          Text(
            'Payments',
            style: TextStyle(
              fontSize: width * 0.038,
              fontWeight: FontWeight.w700,
              color: colorsList.textColor,
            ),
          ),
          const SizedBox(height: 14),

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
                      width: width * 0.09,
                      height: width * 0.09,
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
                              fontSize: width * 0.032,
                              fontWeight: FontWeight.w600,
                              color: colorsList.textColor,
                            ),
                          ),
                          Text(
                            'Paid via $payMethodStr ${payment.reference != null ? '• ${payment.reference}' : ''}',
                            style: TextStyle(
                              fontSize: width * 0.028,
                              color: colorsList.textHintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      controller.formatCurrency(payment.amount, item.currency),
                      style: TextStyle(
                        fontSize: width * 0.035,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  // ================================================================
  // 7. LEDGER ENTRIES CARD
  // ================================================================

  Widget _buildLedgerEntriesCard(PurchaseDetailsModel item, double width) {
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
          Text(
            'Ledger entries',
            style: TextStyle(
              fontSize: width * 0.038,
              fontWeight: FontWeight.w700,
              color: colorsList.textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Journal entries created by posting, payments and voids.',
            style: TextStyle(
              fontSize: width * 0.028,
              color: colorsList.textHintColor,
            ),
          ),
          const SizedBox(height: 14),

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
                            fontSize: width * 0.032,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF063C70),
                          ),
                        ),
                        Text(
                          'Entry #${entry.id}',
                          style: TextStyle(
                            fontSize: width * 0.028,
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
                                  fontSize: width * 0.029,
                                  fontWeight: FontWeight.w500,
                                  color: colorsList.textColor,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: width * 0.22,
                              child: Text(
                                line.debit > 0
                                    ? controller.formatCurrency(line.debit, item.currency)
                                    : '—',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: width * 0.029,
                                  color: colorsList.textColor,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: width * 0.22,
                              child: Text(
                                line.credit > 0
                                    ? controller.formatCurrency(line.credit, item.currency)
                                    : '—',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: width * 0.029,
                                  color: colorsList.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            }).toList(),
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
        color: color.withOpacity(0.12),
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

  Widget _gridItem(String label, String value, double width, {bool isPrimary = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: width * 0.027, color: colorsList.textHintColor),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: width * 0.032,
            fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w500,
            color: isPrimary ? const Color(0xFF063C70) : colorsList.textColor,
          ),
        ),
      ],
    );
  }

  Widget _totalRow(String label, String value, double width, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: width * 0.031,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              color: isBold ? colorsList.textColor : colorsList.textHintColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: width * 0.033,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ?? colorsList.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyRow(String label, String value, double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: width * 0.030, color: colorsList.textHintColor),
          ),
          Text(
            value,
            style: TextStyle(fontSize: width * 0.030, color: colorsList.textColor),
          ),
        ],
      ),
    );
  }

  Widget _miniItemStat(String label, String value, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: width * 0.025, color: colorsList.textHintColor)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: width * 0.029, fontWeight: FontWeight.w600, color: colorsList.textColor)),
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
