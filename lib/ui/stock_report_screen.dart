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
    final isTab = rs.isTablet;

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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorsList.iconColor,
            size: 20,
          ),
        ),
        title: Obx(() {
          if (controller.isSearching.value) {
            return TextField(
              autofocus: true,
              onChanged: controller.onSearchChanged,
              style: TextStyle(
                color: colorsList.textColor,
                fontSize: isTab ? 14 : rs.sp(14),
              ),
              decoration: const InputDecoration(
                hintText: 'Search product, SKU or category...',
                border: InputBorder.none,
                isDense: true,
              ),
            );
          }

          return const Text(
            'Stock in & out report',
            style: TextStyle(
              color: colorsList.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
        actions: [
          Obx(() {
            if (controller.isSearching.value) {
              return IconButton(
                onPressed: controller.closeSearch,
                icon: const Icon(
                  Icons.close_rounded,
                  color: colorsList.iconColor,
                  size: 22,
                ),
              );
            }

            return IconButton(
              onPressed: controller.openSearch,
              icon: const Icon(
                Icons.search_rounded,
                color: colorsList.iconColor,
                size: 22,
              ),
            );
          }),
          IconButton(
            onPressed: controller.exportReportPdf,
            icon: const Icon(
              Icons.picture_as_pdf_outlined,
              color: colorsList.colorButton,
              size: 22,
            ),
            tooltip: 'Export PDF',
          ),
          const SizedBox(width: 8),
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
                horizontal: rs.pagePaddingH,
                vertical: 10,
              ),
              color: Colors.white,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: rs.sheetMaxWidth),
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

                final rows = controller.filteredRows;
                final cols = rs.listColumns;

                return RefreshIndicator(
                  onRefresh: controller.fetchStockReport,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(rs.pagePaddingH),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: rs.sheetMaxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // STATS SUMMARY GRID (4 BOXES)
                            Row(
                              children: [
                                Expanded(
                                  child: _summaryStatBox(
                                    context,
                                    'STOCK ITEMS',
                                    '${controller.totalItems}',
                                    const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _summaryStatBox(
                                    context,
                                    'MOVEMENTS',
                                    '${controller.totalMovements}',
                                    const Color(0xFF1E293B),
                                  ),
                                ),
                                if (isTab) ...[
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _summaryStatBox(
                                      context,
                                      'LOW STOCK',
                                      '${controller.lowStockCount}',
                                      const Color(0xFFD97706),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _summaryStatBox(
                                      context,
                                      'OUT OF STOCK',
                                      '${controller.outOfStockCount}',
                                      const Color(0xFFDC2626),
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            if (!isTab) ...[
                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  Expanded(
                                    child: _summaryStatBox(
                                      context,
                                      'LOW STOCK',
                                      '${controller.lowStockCount}',
                                      const Color(0xFFD97706),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _summaryStatBox(
                                      context,
                                      'OUT OF STOCK',
                                      '${controller.outOfStockCount}',
                                      const Color(0xFFDC2626),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 16),

                            if (rows.isEmpty)
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
                            else if (cols > 1)
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: rs.isLandscape ? 1.85 : 1.40,
                                ),
                                itemCount: rows.length,
                                itemBuilder: (context, index) {
                                  return _buildReportCard(
                                    context: context,
                                    row: rows[index],
                                    asGridTile: true,
                                  );
                                },
                              )
                            else
                              ...rows.map((row) {
                                return _buildReportCard(
                                  context: context,
                                  row: row,
                                  asGridTile: false,
                                );
                              }),
                          ],
                        ),
                      ),
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
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _summaryStatBox(BuildContext context, String label, String value, Color textColor) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Container(
      padding: EdgeInsets.all(isTab ? 14 : rs.s(14)),
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
              fontSize: isTab ? 10 : rs.sp(10),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isTab ? 20 : rs.sp(20),
              fontWeight: FontWeight.bold,
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
    required BuildContext context,
    required StockReportRowModel row,
    bool asGridTile = false,
  }) {
    final rs = context.rs;
    final isTab = rs.isTablet;

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
      margin: EdgeInsets.only(bottom: asGridTile ? 0 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EAF1)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTab ? 14 : rs.s(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isTab ? 15 : rs.sp(15),
                          fontWeight: FontWeight.bold,
                          color: colorsList.textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        row.articleNumber,
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
                          fontSize: isTab ? 11 : rs.sp(11),
                          fontWeight: FontWeight.w600,
                          color: statusFg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF0F4F8)),
            const SizedBox(height: 10),

            // DETAILS ROW: OPENING | IN | OUT | CLOSING
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statColumn(context, 'Opening', '${_formatNum(row.opening)} ${row.unitCode}'),
                _statColumn(context, 'Stock in', row.qtyIn > 0 ? '+${_formatNum(row.qtyIn)} ${row.unitCode}' : '—'),
                _statColumn(context, 'Stock out', row.qtyOut > 0 ? '-${_formatNum(row.qtyOut)} ${row.unitCode}' : '—'),
                _statColumn(context, 'Closing balance', '${_formatNum(row.closing)} ${row.unitCode}', isBold: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statColumn(BuildContext context, String label, String value, {bool isBold = false}) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTab ? 10 : rs.sp(10),
            color: colorsList.textHintColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isTab ? 12.5 : rs.sp(12.5),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
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