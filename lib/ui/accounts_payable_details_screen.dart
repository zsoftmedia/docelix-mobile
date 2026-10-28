import 'package:docelix_mobileapp/controllers/accounts_payable_details_controller.dart';
import 'package:docelix_mobileapp/models/accounts_payable_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountsPayableDetailsScreen extends StatefulWidget {
  const AccountsPayableDetailsScreen({super.key});

  @override
  State<AccountsPayableDetailsScreen> createState() =>
      _AccountsPayableDetailsScreenState();
}

class _AccountsPayableDetailsScreenState
    extends State<AccountsPayableDetailsScreen> {
  final AccountsPayableDetailsController controller =
      Get.put(AccountsPayableDetailsController());

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
          final billNum = controller.bill.value?.invoiceNumber ?? '';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Payable Bill Details',
                style: TextStyle(
                  color: colorsList.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                billNum.isNotEmpty ? '#$billNum' : 'Bill Details',
                style: TextStyle(
                  color: colorsList.textHintColor,
                  fontSize: width * 0.030,
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
        final bill = controller.bill.value;

        if (bill == null) {
          return const Center(
            child: Text(
              'Payable bill information not available.',
              style: TextStyle(
                color: colorsList.textHintColor,
                fontSize: 15,
              ),
            ),
          );
        }

        final String statusStr = (bill.status ?? '').toLowerCase().trim();
        Color statusColor;
        if (statusStr == 'paid') {
          statusColor = const Color(0xFF16A34A);
        } else if (statusStr == 'overdue') {
          statusColor = const Color(0xFFDC2626);
        } else if (statusStr == 'pending' || statusStr == 'unpaid') {
          statusColor = const Color(0xFF2563EB);
        } else {
          statusColor = const Color(0xFF64748B);
        }

        final String displayStatus = statusStr.isNotEmpty
            ? statusStr[0].toUpperCase() + statusStr.substring(1)
            : 'Pending';

        final String supplierName =
            bill.supplierName?.trim().isNotEmpty == true
                ? bill.supplierName!
                : 'Supplier';

        final String supplierAddress = [
          bill.supplierAddressLine1,
          bill.supplierAddressLine2,
          bill.supplierCity,
          bill.supplierPostal,
          bill.supplierCountry,
        ].where((e) => e != null && e.trim().isNotEmpty).join(', ');

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
                // 1. HEADER SUPPLIER & BILL CARD
                // ====================================================

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(width * 0.045),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE4EAF1)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: width * 0.12,
                        height: width * 0.12,
                        decoration: BoxDecoration(
                          color: colorsList.colorBoxDecoration,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: colorsList.iconColor,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: width * 0.035),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bill.invoiceNumber ?? 'No Bill Number',
                              style: TextStyle(
                                fontSize: width * 0.042,
                                fontWeight: FontWeight.normal,
                                color: colorsList.textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              supplierName,
                              style: TextStyle(
                                fontSize: width * 0.032,
                                color: colorsList.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          displayStatus,
                          style: TextStyle(
                            fontSize: width * 0.028,
                            color: statusColor,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: height * 0.018),

                // ====================================================
                // 2. FINANCIAL SUMMARY GRID (4 BOXES)
                // ====================================================

                _sectionTitle('Financial Summary', width),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: _statBox(
                        'Total Amount',
                        controller.formatCurrency(
                            bill.totalAmount, bill.currency),
                        width,
                      ),
                    ),
                    SizedBox(width: width * 0.025),
                    Expanded(
                      child: _statBox(
                        'Balance Remaining',
                        controller.formatCurrency(
                            bill.remainingAmount, bill.currency),
                        width,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: width * 0.025),

                Row(
                  children: [
                    Expanded(
                      child: _statBox(
                        'Net Amount',
                        controller.formatCurrency(
                            bill.netAmount, bill.currency),
                        width,
                      ),
                    ),
                    SizedBox(width: width * 0.025),
                    Expanded(
                      child: _statBox(
                        'VAT Amount',
                        controller.formatCurrency(
                            bill.vatAmount, bill.currency),
                        width,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: height * 0.022),

                // ====================================================
                // 3. BILL INFORMATION DETAILS CARD
                // ====================================================

                _sectionTitle('Bill Information', width),
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
                      _detailRow('Issue Date', _formatDate(bill.invoiceDate ?? bill.date), width),
                      _detailRow('Due Date', _formatDate(bill.dueDate), width),
                      _detailRow('Expense Category', bill.expenseCategory ?? '—', width),
                      _detailRow('Expense Account', bill.expenseAccountCode ?? '—', width),
                      _detailRow(
                        'VAT Rate',
                        bill.vatRatePercent != null ? '${_formatNum(bill.vatRatePercent!)}%' : '—',
                        width,
                      ),
                      _detailRow('VAT Review Status', bill.vatReviewStatus ?? '—', width),
                      _detailRow('Days Overdue', bill.daysOverdue != null ? '${bill.daysOverdue} days' : '0 days', width),
                      _detailRow('File Name', bill.fileName ?? '—', width, showBorder: supplierAddress.isNotEmpty || (bill.supplierEmail ?? '').isNotEmpty),
                      if (supplierAddress.isNotEmpty)
                        _detailRow('Supplier Address', supplierAddress, width, showBorder: (bill.supplierEmail ?? '').isNotEmpty),
                      if ((bill.supplierEmail ?? '').isNotEmpty)
                        _detailRow('Supplier Email', bill.supplierEmail!, width, showBorder: (bill.supplierPhone ?? '').isNotEmpty),
                      if ((bill.supplierPhone ?? '').isNotEmpty)
                        _detailRow('Supplier Phone', bill.supplierPhone!, width, showBorder: false),
                    ],
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

  Widget _statBox(String label, String value, double width) {
    return Container(
      padding: EdgeInsets.all(width * 0.035),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4EAF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: width * 0.027,
              color: colorsList.textHintColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: width * 0.034,
              fontWeight: FontWeight.normal,
              color: colorsList.textColor,
            ),
          ),
        ],
      ),
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

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '—';
    try {
      final parsed = DateTime.parse(dateStr);
      return '${parsed.day.toString().padLeft(2, '0')}.${parsed.month.toString().padLeft(2, '0')}.${parsed.year}';
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