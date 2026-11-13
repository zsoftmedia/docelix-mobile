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
              // 1. TOP HEADER BAR
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
                        'Quotations',
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

              SizedBox(height: rs.s(8)),

              // ======================================================
              // 2. TITLE & SUBTITLE SECTION
              // ======================================================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quotations',
                      style: TextStyle(
                        color: const Color(0xFF0A2342),
                        fontSize: rs.sp(22),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: rs.s(2)),
                    Text(
                      'Manage, track, and send quotations to customers.',
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
              // 3. SEARCH BAR
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
                          onChanged: controller.onSearchChanged,
                          style: TextStyle(
                            color: const Color(0xFF0A2342),
                            fontSize: rs.sp(13),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Search quotation here...',
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
                        if (controller.searchQuery.value.isNotEmpty) {
                          return IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                            onPressed: () => controller.closeSearch(),
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
              // 4. QUOTATION LIST
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
                          SizedBox(height: rs.s(120)),
                          Center(
                            child: Text(
                              controller.searchQuery.value.isNotEmpty
                                  ? 'No matching quotations found.'
                                  : 'No quotations available.',
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
                  final quotations = controller.filteredQuotations;

                  if (cols <= 1) {
                    return RefreshIndicator(
                      onRefresh: controller.refreshQuotations,
                      child: ListView.builder(
                        padding: EdgeInsets.only(
                          top: rs.s(4),
                          left: rs.pagePaddingH,
                          right: rs.pagePaddingH,
                          bottom: rs.s(96),
                        ),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: quotations.length,
                        itemBuilder: (context, index) {
                          return _buildQuotationCard(
                            item: quotations[index],
                            context: context,
                            asGridTile: false,
                          );
                        },
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.refreshQuotations,
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
                        childAspectRatio: rs.isTablet
                            ? (rs.isLandscape ? 1.45 : 1.05)
                            : (rs.isLandscape ? 2.6 : 1.8),
                      ),
                      itemCount: quotations.length,
                      itemBuilder: (context, index) {
                        return _buildQuotationCard(
                          item: quotations[index],
                          context: context,
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
        onPressed: () async {
          final result = await Get.toNamed('/CreateQuotationScreen');
          if (result == true) {
            controller.refreshQuotations();
          }
        },
        backgroundColor: colorsList.colorButton,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: Text(
          'Create Offer',
          style: TextStyle(
            fontSize: rs.sp(15),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _showQuotationActions(BuildContext context, QuotationModel item) {
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.offerNumber.isNotEmpty ? item.offerNumber : 'Quotation #${item.id}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2342)),
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
                  leading: const Icon(Icons.visibility_outlined, color: Color(0xFF2563EB)),
                  title: const Text('View Quotation Details'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Get.toNamed('/QuotationDetailsScreen', arguments: item);
                  },
                ),
                const SizedBox(height: 12),
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
    required BuildContext context,
    bool asGridTile = false,
  }) {
    final rs = context.rs;
    final isTab = rs.isTablet;
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
      margin: EdgeInsets.only(bottom: asGridTile ? 0 : rs.s(14)),
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
            padding: EdgeInsets.all(isTab ? 14 : rs.s(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. TOP HEADER ROW (OFFER NUMBER + STATUS BADGE + MORE MENU)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.offerNumber.isNotEmpty ? item.offerNumber : 'OFFER-#${item.id}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isTab ? 15 : rs.sp(16),
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFF0A2342),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTab ? 8 : rs.s(12),
                        vertical: isTab ? 3 : rs.s(4),
                      ),
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: pillBorder),
                      ),
                      child: Text(
                        displayStatus,
                        style: TextStyle(
                          fontSize: isTab ? 11 : rs.sp(12),
                          fontWeight: FontWeight.normal,
                          color: pillText,
                        ),
                      ),
                    ),
                    SizedBox(width: isTab ? 2 : rs.s(4)),
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

                Padding(
                  padding: EdgeInsets.symmetric(vertical: isTab ? 8 : 12),
                  child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
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
                          _statField(context, 'CUSTOMER', item.clientName ?? '—', isTab: isTab),
                          SizedBox(height: isTab ? 6 : rs.s(10)),
                          _statField(context, 'VALID UNTIL', validUntilStr, isTab: isTab),
                          SizedBox(height: isTab ? 6 : rs.s(10)),
                          _statField(context, 'SIGNATURE', '—', isTab: isTab),
                        ],
                      ),
                    ),

                    // RIGHT COLUMN (DATE, ACCEPTED)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _statField(context, 'DATE', dateStr, isTab: isTab),
                          SizedBox(height: isTab ? 6 : rs.s(10)),
                          _statField(context, 'ACCEPTED', acceptedStr, isTab: isTab),
                        ],
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: isTab ? 8 : 12),
                  child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),

                // 3. BOTTOM AMOUNTS ROW (TOTAL)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: isTab ? 10 : rs.sp(10),
                        fontWeight: FontWeight.normal,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '${item.totalAmount.toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontSize: isTab ? 14 : rs.sp(16),
                        fontWeight: FontWeight.normal,
                        color: const Color(0xFF0A2342),
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

  Widget _statField(BuildContext context, String label, String value, {bool isTab = false}) {
    final rs = context.rs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTab ? 9.5 : rs.sp(10),
            fontWeight: FontWeight.normal,
            color: const Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: isTab ? 12 : rs.sp(13),
            fontWeight: FontWeight.normal,
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
      final day = parsed.day.toString().padLeft(2, '0');
      final month = parsed.month.toString().padLeft(2, '0');
      return '$day.$month.${parsed.year}';
    } catch (_) {
      return dateStr;
    }
  }
}