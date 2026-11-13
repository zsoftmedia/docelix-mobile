import 'package:docelix_mobileapp/controllers/stock_adjustment_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/stock_adjustment_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StockAdjustmentScreen extends StatefulWidget {
  const StockAdjustmentScreen({super.key});

  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  final StockAdjustmentController _stockAdjustmentController =
      Get.put(StockAdjustmentController());

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,

      // ==========================================================
      // APP BAR WITH REAL-TIME SEARCH
      // ==========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            if (_stockAdjustmentController.isSearching.value) {
              _stockAdjustmentController.closeSearch();
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
          if (_stockAdjustmentController.isSearching.value) {
            return TextField(
              autofocus: true,
              onChanged: _stockAdjustmentController.onSearchChanged,
              style: TextStyle(
                color: colorsList.textColor,
                fontSize: isTab ? 14 : rs.sp(14),
              ),
              decoration: const InputDecoration(
                hintText: 'Search product, code, or notes...',
                border: InputBorder.none,
                isDense: true,
              ),
            );
          }

          return const Text(
            'Stock Adjustment',
            style: TextStyle(
              color: colorsList.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
        actions: [
          Obx(() {
            if (_stockAdjustmentController.isSearching.value) {
              return IconButton(
                onPressed: _stockAdjustmentController.closeSearch,
                icon: const Icon(
                  Icons.close_rounded,
                  color: colorsList.iconColor,
                  size: 22,
                ),
              );
            }

            return IconButton(
              onPressed: _stockAdjustmentController.openSearch,
              icon: const Icon(
                Icons.search_rounded,
                color: colorsList.iconColor,
                size: 22,
              ),
            );
          }),
          const SizedBox(width: 8),
        ],
      ),

      // ==========================================================
      // BODY (ADJUSTMENTS LIST)
      // ==========================================================

      body: Obx(() {
        if (_stockAdjustmentController.isLoading.value && _stockAdjustmentController.filteredAdjustments.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (_stockAdjustmentController.errorMessage.value.isNotEmpty &&
            _stockAdjustmentController.filteredAdjustments.isEmpty) {
          return Center(
            child: Text(
              _stockAdjustmentController.errorMessage.value,
              style: TextStyle(
                color: colorsList.red,
                fontSize: rs.sp(14),
              ),
            ),
          );
        }

        if (_stockAdjustmentController.filteredAdjustments.isEmpty) {
          return Center(
            child: Text(
              _stockAdjustmentController.searchQuery.value.isNotEmpty
                  ? 'No matching adjustments found.'
                  : 'No stock adjustments recorded.',
              style: TextStyle(
                fontSize: rs.sp(15),
                color: colorsList.textHintColor,
              ),
            ),
          );
        }

        final items = _stockAdjustmentController.filteredAdjustments;
        final cols = rs.listColumns;

        if (cols <= 1) {
          return ResponsivePage(
            padding: EdgeInsets.zero,
            child: RefreshIndicator(
              onRefresh: _stockAdjustmentController.refreshAdjustments,
              child: ListView.builder(
                padding: EdgeInsets.only(
                  left: rs.pagePaddingH,
                  right: rs.pagePaddingH,
                  top: rs.s(12),
                  bottom: rs.s(96),
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildAdjustmentCard(
                    context: context,
                    item: item,
                    asGridTile: false,
                  );
                },
              ),
            ),
          );
        }

        return ResponsivePage(
          padding: EdgeInsets.zero,
          child: RefreshIndicator(
            onRefresh: _stockAdjustmentController.refreshAdjustments,
            child: GridView.builder(
              padding: EdgeInsets.only(
                left: rs.pagePaddingH,
                right: rs.pagePaddingH,
                top: rs.s(12),
                bottom: rs.s(96),
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: rs.s(12),
                mainAxisSpacing: rs.s(12),
                childAspectRatio: rs.isTablet
                    ? (rs.isLandscape ? 1.75 : 1.35)
                    : (rs.isLandscape ? 2.6 : 1.8),
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildAdjustmentCard(
                  context: context,
                  item: item,
                  asGridTile: true,
                );
              },
            ),
          ),
        );
      }),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Get.toNamed(
            '/CreateAdjustStockScreen',
            arguments: 'Create Adjust Stock Screen',
          );

          await _stockAdjustmentController.refreshAdjustments();
        },
        backgroundColor: colorsList.colorButton,
        foregroundColor: colorsList.colorWhite,
        elevation: 4,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: Text(
          'Adjust Stock',
          style: TextStyle(
            fontSize: rs.sp(14),
            fontWeight: FontWeight.bold,
            color: colorsList.colorWhite,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // ADJUSTMENT CARD ITEM (MATCHES WEB TABLE COLUMNS)
  // ================================================================

  Widget _buildAdjustmentCard({
    required BuildContext context,
    required StockAdjustmentModel item,
    bool asGridTile = false,
  }) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    final String productName = item.articleName.isNotEmpty
        ? item.articleName
        : 'Product Item';

    final String articleCode = item.articleNumber.isNotEmpty
        ? item.articleNumber
        : '—';

    final String displayType = item.displayType;
    final bool isPositive = item.quantity >= 0;
    final String qtySign = isPositive ? '+' : '';
    final String qtyText = '$qtySign${_formatNum(item.quantity)} ${item.unitCode}';

    final String notesStr = item.notes?.isNotEmpty == true
        ? item.notes!
        : (item.reason?.isNotEmpty == true ? item.reason! : '—');

    final String dateStr = _formatDate(item.date ?? item.createdAt);

    return Container(
      margin: EdgeInsets.only(bottom: asGridTile ? 0 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EAF1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isTab ? 14 : rs.s(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // TOP ROW: PRODUCT NAME + CODE + TYPE BADGE
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
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
                        articleCode,
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

                // MOVEMENT TYPE BADGE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    displayType,
                    style: TextStyle(
                      fontSize: isTab ? 11 : rs.sp(11),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF0F4F8)),
            const SizedBox(height: 10),

            // MIDDLE ROW: QUANTITY & DATE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: isTab ? 10.5 : rs.sp(10.5),
                        color: colorsList.textHintColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      qtyText,
                      style: TextStyle(
                        fontSize: isTab ? 14 : rs.sp(14),
                        fontWeight: FontWeight.bold,
                        color: isPositive
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Date',
                      style: TextStyle(
                        fontSize: isTab ? 10.5 : rs.sp(10.5),
                        color: colorsList.textHintColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: isTab ? 12.5 : rs.sp(12.5),
                        fontWeight: FontWeight.w500,
                        color: colorsList.textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (notesStr != '—') ...[
              const SizedBox(height: 8),
              Text(
                'Notes / Reason',
                style: TextStyle(
                  fontSize: isTab ? 10.5 : rs.sp(10.5),
                  color: colorsList.textHintColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                notesStr,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isTab ? 12 : rs.sp(12),
                  color: colorsList.secondaryText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '—';
    try {
      final parsed = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${parsed.day.toString().padLeft(2, '0')} ${months[parsed.month - 1]} ${parsed.year}';
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