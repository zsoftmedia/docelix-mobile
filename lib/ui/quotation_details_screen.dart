import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/quotation_details_controller.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuotationDetailsScreen extends StatefulWidget {
  const QuotationDetailsScreen({super.key});

  @override
  State<QuotationDetailsScreen> createState() => _QuotationDetailsScreenState();
}

class _QuotationDetailsScreenState extends State<QuotationDetailsScreen> {
  final QuotationDetailsController controller =
      Get.put(QuotationDetailsController());

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
          final numStr = controller.quotation.value?.offerNumber ?? '';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quotation',
                style: TextStyle(
                  color: colorsList.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
              if (numStr.isNotEmpty)
                Text(
                  numStr,
                  style: TextStyle(
                    color: colorsList.textHintColor,
                    fontSize: width * 0.030,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          );
        }),
        actions: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.close_rounded,
              color: colorsList.iconColor,
              size: 22,
            ),
          ),
          SizedBox(width: width * 0.02),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: Obx(() {
        final item = controller.quotation.value;

        if (item == null) {
          return const Center(
            child: Text(
              'Quotation information not available.',
              style: TextStyle(
                color: colorsList.textHintColor,
                fontSize: 15,
              ),
            ),
          );
        }

        final String statusStr = item.status.toLowerCase().trim();
        Color statusColor;
        if (statusStr == 'accepted') {
          statusColor = const Color(0xFF16A34A);
        } else if (statusStr == 'sent') {
          statusColor = const Color(0xFF2563EB);
        } else if (statusStr == 'rejected') {
          statusColor = const Color(0xFFDC2626);
        } else {
          statusColor = const Color(0xFF64748B);
        }

        final String displayStatus =
            statusStr.isNotEmpty ? statusStr[0].toUpperCase() + statusStr.substring(1) : 'Draft';

        return Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
              Expanded(
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
                      // 1. CUSTOMER HEADER CARD
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.clientName ?? 'Customer',
                                    style: TextStyle(
                                      fontSize: width * 0.045,
                                      fontWeight: FontWeight.normal,
                                      color: colorsList.textColor,
                                    ),
                                  ),
                                  if ((item.clientEmail ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      item.clientEmail!,
                                      style: TextStyle(
                                        fontSize: width * 0.031,
                                        color: colorsList.textHintColor,
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
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    displayStatus,
                                    style: TextStyle(
                                      fontSize: width * 0.027,
                                      color: statusColor,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: height * 0.018),

                      // ====================================================
                      // 2. FINANCIAL & DATE STATS GRID (4 BOXES)
                      // ====================================================

                      Row(
                        children: [
                          Expanded(
                            child: _statBox(
                              'Date',
                              _formatDate(item.issueDate),
                              width,
                            ),
                          ),
                          SizedBox(width: width * 0.025),
                          Expanded(
                            child: _statBox(
                              'Valid until',
                              item.validUntil != null ? _formatDate(item.validUntil) : '—',
                              width,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: height * 0.012),

                      Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => _statBox(
                                'Total',
                                controller.formatCurrency(controller.totalAmount),
                                width,
                              ),
                            ),
                          ),
                          SizedBox(width: width * 0.025),
                          Expanded(
                            child: _statBox(
                              'Accepted',
                              item.acceptedAt != null ? _formatDate(item.acceptedAt) : '—',
                              width,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: height * 0.018),

                      // ====================================================
                      // 3. CUSTOMER ADDRESS CARD
                      // ====================================================

                      Container(
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
                              'Customer address',
                              style: TextStyle(
                                fontSize: width * 0.038,
                                fontWeight: FontWeight.normal,
                                color: colorsList.textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              (item.clientAddress ?? '').isNotEmpty
                                  ? item.clientAddress!
                                  : '—',
                              style: TextStyle(
                                fontSize: width * 0.032,
                                color: colorsList.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: height * 0.022),

                      // ====================================================
                      // 4. ITEMS TABLE CARD
                      // ====================================================

                      Container(
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
                              'Items',
                              style: TextStyle(
                                fontSize: width * 0.040,
                                fontWeight: FontWeight.normal,
                                color: colorsList.textColor,
                              ),
                            ),
                            const SizedBox(height: 14),

                            Obx(() {
                              if (controller.isLoadingItems.value && controller.offerItems.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              if (controller.offerItems.isEmpty) {
                                return const Text(
                                  'No items in this quotation.',
                                  style: TextStyle(
                                    color: colorsList.textHintColor,
                                    fontSize: 13,
                                  ),
                                );
                              }

                              return Column(
                                children: [
                                  // TABLE HEADER
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            'DESCRIPTION',
                                            style: TextStyle(
                                              fontSize: width * 0.025,
                                              color: colorsList.textHintColor,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: width * 0.10,
                                          child: Text(
                                            'QTY',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: width * 0.025,
                                              color: colorsList.textHintColor,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: width * 0.18,
                                          child: Text(
                                            'UNIT',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              fontSize: width * 0.025,
                                              color: colorsList.textHintColor,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: width * 0.12,
                                          child: Text(
                                            'VAT',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              fontSize: width * 0.025,
                                              color: colorsList.textHintColor,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: width * 0.20,
                                          child: Text(
                                            'TOTAL',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              fontSize: width * 0.025,
                                              color: colorsList.textHintColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  // ITEM ROWS
                                  ...controller.offerItems.map((line) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 6,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              line.description,
                                              style: TextStyle(
                                                fontSize: width * 0.030,
                                                color: colorsList.textColor,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: width * 0.10,
                                            child: Text(
                                              _formatNum(line.quantity),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: width * 0.030,
                                                color: colorsList.textColor,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: width * 0.18,
                                            child: Text(
                                              controller.formatCurrency(line.unitPrice),
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                fontSize: width * 0.030,
                                                color: colorsList.textColor,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: width * 0.12,
                                            child: Text(
                                              '${_formatNum(line.vatRate)}%',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                fontSize: width * 0.030,
                                                color: colorsList.textColor,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: width * 0.20,
                                            child: Text(
                                              controller.formatCurrency(line.total),
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                fontSize: width * 0.030,
                                                color: colorsList.textColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),

                                  const Divider(height: 16, color: Color(0xFFE2E8F0)),

                                  // TOTAL ROW
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 6,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                            fontSize: width * 0.034,
                                            color: colorsList.textColor,
                                          ),
                                        ),
                                        Obx(
                                          () => Text(
                                            controller.formatCurrency(controller.totalAmount),
                                            style: TextStyle(
                                              fontSize: width * 0.036,
                                              color: colorsList.textColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ==========================================================
              // BOTTOM ACTIONS BAR
              // ==========================================================

              Container(
                padding: EdgeInsets.fromLTRB(
                  width * 0.045,
                  height * 0.012,
                  width * 0.045,
                  height * 0.02,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFE5EAF0)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          AppSnackbar.info(
                            title: 'Send Quotation',
                            message: 'Send quotation feature is being prepared.',
                          );
                        },
                        icon: const Icon(Icons.send_outlined, size: 18),
                        label: const Text(
                          'Send',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorsList.primaryBlue,
                          side: const BorderSide(color: colorsList.primaryBlue),
                          minimumSize: Size(0, height * 0.055),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showMoreMenuSheet(context);
                        },
                        icon: const Icon(Icons.more_horiz_rounded, size: 20),
                        label: const Text(
                          'More',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorsList.colorButton,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: Size(0, height * 0.055),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // DELETING OVERLAY
              Obx(() {
                if (!controller.isDeleting.value) {
                  return const SizedBox.shrink();
                }

                return Container(
                  color: Colors.black.withValues(alpha: 0.45),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: colorsList.primaryBlue,
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Deleting quotation...',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colorsList.textColor,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Please wait a moment',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorsList.textHintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        }),
      );
    }

  // ================================================================
  // MORE MENU BOTTOM SHEET
  // ================================================================

  void _showMoreMenuSheet(BuildContext context) {
    Get.bottomSheet(
      backgroundColor: Colors.transparent,
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'More Options',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _moreOptionTile(
              title: 'Download document',
              subtitle: 'View or print quotation document',
              icon: Icons.file_download_outlined,
              iconColor: const Color(0xFF0284C7),
              onTap: () {
                Get.back();
                controller.downloadQuotationDocument();
              },
            ),
            const SizedBox(height: 8),
            _moreOptionTile(
              title: 'Edit quotation',
              subtitle: 'Modify quotation details or items',
              icon: Icons.edit_outlined,
              iconColor: colorsList.primaryBlue,
              onTap: () async {
                Get.back();
                final currentOffer = controller.quotation.value;
                if (currentOffer != null) {
                  final result = await Get.toNamed('/EditQuotationScreen', arguments: currentOffer);
                  if (result == true) {
                    controller.getOfferItems();
                  }
                }
              },
            ),
            const SizedBox(height: 8),
            _moreOptionTile(
              title: 'Delete quotation',
              subtitle: 'Permanently remove this quotation',
              icon: Icons.delete_outline_rounded,
              iconColor: const Color(0xFFDC2626),
              onTap: () {
                Get.back();
                controller.deleteQuotation();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _moreOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // HELPER WIDGETS
  // ================================================================

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