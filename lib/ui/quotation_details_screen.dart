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

        return SafeArea(
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
                        onPressed: () {},
                        icon: const Icon(Icons.download_outlined, size: 16),
                        label: const Text(
                          'Download',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorsList.textColor,
                          side: const BorderSide(color: Color(0xFFD0D5DD)),
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.send_outlined, size: 16),
                        label: const Text(
                          'Send',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorsList.primaryBlue,
                          side: const BorderSide(color: colorsList.primaryBlue),
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text(
                          'Edit',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorsList.textColor,
                          side: const BorderSide(color: Color(0xFFD0D5DD)),
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.delete_outline_rounded, size: 16),
                        label: const Text(
                          'Delete',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
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