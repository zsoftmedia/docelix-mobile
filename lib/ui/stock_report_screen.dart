import 'package:docelix_mobileapp/controllers/stock_report_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/stock_report_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StockReportScreen extends StatefulWidget {
  const StockReportScreen({super.key});

  @override
  State<StockReportScreen> createState() => _StockReportScreenState();
}

class _StockReportScreenState extends State<StockReportScreen> {
  final StockReportController controller = Get.put(StockReportController());

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,

      // ==========================================================
      // APP BAR WITH SEARCH & EXPORT
      // ==========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            if (controller.isSearching.value) {
              controller.closeSearch();
            } else {
              Get.back();
            }
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorsList.iconColor,
            size: rs.s(20),
          ),
        ),
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
                hintText: 'Search product, SKU or category...',
                border: InputBorder.none,
                isDense: true,
              ),
            );
          }

          return Text(
            'Stock in & out report',
            style: TextStyle(
              color: colorsList.textColor,
              fontSize: rs.sp(18),
              fontWeight: FontWeight.normal,
            ),
          );
        }),
        actions: [
          Obx(() {
            if (controller.isSearching.value) {
              return IconButton(
                onPressed: controller.closeSearch,
                icon: Icon(
                  Icons.close_rounded,
                  color: colorsList.iconColor,
                  size: width * 0.06,
                ),
              );
            }

            return IconButton(
              onPressed: controller.openSearch,
              icon: Icon(
                Icons.search_rounded,
                color: colorsList.iconColor,
                size: width * 0.06,
              ),
            );
          }),
          IconButton(
            onPressed: controller.exportReportPdf,
            icon: Icon(
              Icons.picture_as_pdf_outlined,
              color: colorsList.primaryBlue,
              size: width * 0.06,
            ),
            tooltip: 'Export PDF',
          ),
          SizedBox(width: width * 0.02),
        ],
      ),

      // ==========================================================
      // BODY (FILTERS + STATS + REPORT ROWS)
      // ==========================================================

      body: SafeArea(
        child: Column(
          children: [
            // ======================================================
            // 1. FILTER CONTROLS BAR (PRESET + DATE RANGE)
            // ======================================================
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: 10,
              ),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      // PRESET PERIOD DROPDOWN
                      Expanded(
                        flex: 4,
                        child: Obx(
                          () => Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: controller.selectedPreset.value,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                    size: 18, color: Color(0xFF64748B)),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1E293B),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'this_month', child: Text('This month')),
                                  DropdownMenuItem(
                                      value: 'last_month', child: Text('Last month')),
                                  DropdownMenuItem(
                                      value: 'this_year', child: Text('This year')),
                                  DropdownMenuItem(
                                      value: 'custom', child: Text('Custom')),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    controller.selectPresetPeriod(val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // FROM DATE PICKER
                      Expanded(
                        flex: 3,
                        child: Obx(
                          () => InkWell(
                            onTap: () => controller.pickFromDate(context),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDateUI(controller.fromDate.value),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    size: 15,
                                    color: Color(0xFF64748B),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // TO DATE PICKER
                      Expanded(
                        flex: 3,
                        child: Obx(
                          () => InkWell(
                            onTap: () => controller.pickToDate(context),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDateUI(controller.toDate.value),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    size: 15,
                                    color: Color(0xFF64748B),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // STATUS CHIPS (ALL STOCK, LOW STOCK, OUT OF STOCK)
                  Obx(
                    () => Row(
                      children: [
                        _filterChip('All stock', 'all', controller),
                        const SizedBox(width: 8),
                        _filterChip('Low stock', 'low', controller),
                        const SizedBox(width: 8),
                        _filterChip('Out of stock', 'out', controller),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // ======================================================
            // 2. REPORT CONTENT LIST
            // ======================================================
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.filteredRows.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.value.isNotEmpty &&
                    controller.filteredRows.isEmpty) {
                  return Center(
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(
                        color: colorsList.red,
                        fontSize: rs.sp(14),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchStockReport,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(width * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // STATS SUMMARY GRID (4 BOXES)
                        Row(
                          children: [
                            Expanded(
                              child: _summaryStatBox(
                                'STOCK ITEMS',
                                '${controller.totalItems}',
                                const Color(0xFF1E293B),
                                width,
                              ),
                            ),
                            SizedBox(width: width * 0.025),
                            Expanded(
                              child: _summaryStatBox(
                                'MOVEMENTS',
                                '${controller.totalMovements}',
                                const Color(0xFF1E293B),
                                width,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: width * 0.025),

                        Row(
                          children: [
                            Expanded(
                              child: _summaryStatBox(
                                'LOW STOCK',
                                '${controller.lowStockCount}',
                                const Color(0xFFD97706),
                                width,
                              ),
                            ),
                            SizedBox(width: width * 0.025),
                            Expanded(
                              child: _summaryStatBox(
                                'OUT OF STOCK',
                                '${controller.outOfStockCount}',
                                const Color(0xFFDC2626),
                                width,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: width * 0.04),

                        if (controller.filteredRows.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text(
                                'No stock report items found for selected period.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorsList.textHintColor,
                                ),
                              ),
                            ),
                          )
                        else
                          ...controller.filteredRows.map((row) {
                            return _buildReportCard(row: row, width: width);
                          }).toList(),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // FILTER CHIP WIDGET
  // ================================================================

  Widget _filterChip(String label, String value, StockReportController ctrl) {
    final bool isSelected = ctrl.stockFilter.value == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => ctrl.setFilter(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // SUMMARY STAT BOX
  // ================================================================

  Widget _summaryStatBox(String label, String value, Color textColor, double width) {
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
              fontSize: width * 0.025,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: width * 0.048,
              fontWeight: FontWeight.normal,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // STOCK REPORT ROW CARD
  // ================================================================

  Widget _buildReportCard({
    required StockReportRowModel row,
    required double width,
  }) {
    final String statusStr = row.status.toLowerCase().trim();
    Color statusBg;
    Color statusFg;
    String statusLabel;

    if (statusStr == 'out' || row.closing <= 0) {
      statusBg = const Color(0xFFFEE2E2);
      statusFg = const Color(0xFFDC2626);
      statusLabel = 'Out of stock';
    } else if (statusStr == 'low' || row.closing <= row.minStock) {
      statusBg = const Color(0xFFFEF3C7);
      statusFg = const Color(0xFFD97706);
      statusLabel = 'Low stock';
    } else {
      statusBg = const Color(0xFFDCFCE7);
      statusFg = const Color(0xFF16A34A);
      statusLabel = 'In stock';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EAF1)),
      ),
      child: Padding(
        padding: EdgeInsets.all(width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP ROW: PRODUCT NAME + CODE + STATUS BADGE
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.articleName,
                        style: TextStyle(
                          fontSize: width * 0.038,
                          fontWeight: FontWeight.normal,
                          color: colorsList.textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        row.articleNumber,
                        style: TextStyle(
                          fontSize: width * 0.029,
                          color: colorsList.textHintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(color: statusFg, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: width * 0.026,
                          fontWeight: FontWeight.normal,
                          color: statusFg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: width * 0.025),
            const Divider(height: 1, color: Color(0xFFF0F4F8)),
            SizedBox(height: width * 0.025),

            // DETAILS ROW: OPENING | IN | OUT | CLOSING
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statColumn('Opening', '${_formatNum(row.opening)} ${row.unitCode}', width),
                _statColumn('Stock in', row.qtyIn > 0 ? '+${_formatNum(row.qtyIn)} ${row.unitCode}' : '—', width),
                _statColumn('Stock out', row.qtyOut > 0 ? '-${_formatNum(row.qtyOut)} ${row.unitCode}' : '—', width),
                _statColumn('Closing balance', '${_formatNum(row.closing)} ${row.unitCode}', width, isBold: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statColumn(String label, String value, double width, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: width * 0.025, color: colorsList.textHintColor),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: width * 0.029,
            fontWeight: FontWeight.normal,
            color: isBold ? const Color(0xFF063C70) : colorsList.textColor,
          ),
        ),
      ],
    );
  }

  String _formatDateUI(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d.$m.${date.year}';
  }

  String _formatNum(double num) {
    if (num == num.roundToDouble()) {
      return num.toInt().toString();
    }
    return num.toStringAsFixed(2);
  }
}