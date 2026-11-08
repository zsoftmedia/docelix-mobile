import 'package:docelix_mobileapp/controllers/quotation_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/quotation_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuotationScreen extends StatefulWidget {
  const QuotationScreen({super.key});

  @override
  State<QuotationScreen> createState() => _QuotationScreenState();
}

class _QuotationScreenState extends State<QuotationScreen> {
  final QuotationController controller = Get.put(QuotationController());

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
        backgroundColor: colorsList.backgroundColor,
        elevation: 0,
        leading: Obx(() {
          final bool searching = controller.isSearching.value;
          return IconButton(
            onPressed: () {
              if (searching) {
                controller.closeSearch();
              } else {
                Get.back();
              }
            },
            icon: Icon(
              searching ? Icons.close_rounded : Icons.arrow_back_ios_new_rounded,
              color: colorsList.iconColor,
              size: width * 0.05,
            ),
          );
        }),
        title: Obx(() {
          if (controller.isSearching.value) {
            return TextField(
              autofocus: true,
              onChanged: controller.onSearchChanged,
              style: TextStyle(
                color: colorsList.textColor,
                fontSize: width * 0.04,
              ),
              decoration: const InputDecoration(
                hintText: 'Search quotation # or client...',
                border: InputBorder.none,
                isDense: true,
              ),
            );
          }

          return Text(
            'Quotations',
            style: TextStyle(
              color: colorsList.textColor,
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          );
        }),
        actions: [
          Obx(() {
            if (controller.isSearching.value) return const SizedBox.shrink();

            return Row(
              children: [
                IconButton(
                  onPressed: controller.openSearch,
                  icon: Icon(
                    Icons.search_rounded,
                    color: colorsList.iconColor,
                    size: width * 0.065,
                  ),
                ),
                /*IconButton(
                  onPressed: () async {
                    final result = await Get.toNamed('/CreateQuotationScreen');
                    if (result == true) {
                      controller.refreshQuotations();
                    }
                  },
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: colorsList.primaryBlue,
                    size: 24,
                  ),
                ),*/
              ],
            );
          }),
          SizedBox(width: width * 0.02),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.toNamed('/CreateQuotationScreen');
          if (result == true) {
            controller.refreshQuotations();
          }
        },
        backgroundColor: colorsList.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Create Offer',
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        child: Column(
          children: [
            // ======================================================
            // HEADER BAR
            // ======================================================

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.045,
                vertical: height * 0.012,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Offers',
                    style: TextStyle(
                      color: colorsList.textColor,
                      fontSize: width * 0.040,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Obx(
                    () => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: height * 0.006,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE4EAF1)),
                      ),
                      child: Text(
                        '${controller.filteredQuotations.length} Offers',
                        style: TextStyle(
                          color: colorsList.textColor,
                          fontSize: width * 0.028,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ======================================================
            // QUOTATION LIST
            // ======================================================

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (controller.filteredQuotations.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: controller.refreshQuotations,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: height * 0.15),
                        Center(
                          child: Text(
                            controller.searchQuery.value.isNotEmpty
                                ? 'No matching quotations found.'
                                : 'No quotations available.',
                            style: const TextStyle(
                              color: colorsList.textHintColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshQuotations,
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      left: width * 0.045,
                      right: width * 0.045,
                      bottom: height * 0.05,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: controller.filteredQuotations.length,
                    itemBuilder: (context, index) {
                      final item = controller.filteredQuotations[index];
                      return _buildQuotationCard(
                        item: item,
                        width: width,
                        height: height,
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuotationActions(BuildContext context, QuotationModel item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colorsList.colorWhite,
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
                  title: const Text('View Quotation Details'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Get.toNamed('/QuotationDetailsScreen', arguments: item);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // QUOTATION CARD WIDGET
  // ================================================================

  Widget _buildQuotationCard({
    required QuotationModel item,
    required double width,
    required double height,
  }) {
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
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TOP HEADER ROW (OFFER NUMBER + STATUS BADGE + MORE MENU)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.offerNumber.isNotEmpty ? item.offerNumber : 'OFFER-#${item.id}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF0A2342),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: pillBorder),
                      ),
                      child: Text(
                        displayStatus,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: pillText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
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

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),

                // 2. MIDDLE DETAILS 2X3 GRID
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT COLUMN (CUSTOMER, VALID UNTIL, SIGNATURE)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _statField('CUSTOMER', item.clientName ?? '—'),
                          const SizedBox(height: 10),
                          _statField('VALID UNTIL', validUntilStr),
                          const SizedBox(height: 10),
                          _statField('SIGNATURE', '—'),
                        ],
                      ),
                    ),

                    // RIGHT COLUMN (DATE, ACCEPTED)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _statField('DATE', dateStr),
                          const SizedBox(height: 10),
                          _statField('ACCEPTED', acceptedStr),
                        ],
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),

                // 3. BOTTOM AMOUNTS ROW (TOTAL)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '${item.totalAmount.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF0A2342),
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

  Widget _statField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.normal,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.normal,
            color: Color(0xFF0A2342),
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