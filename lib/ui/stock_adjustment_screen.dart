import 'package:docelix_mobileapp/components/app_snackbar.dart';
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
  final StockAdjustmentController controller =
      Get.put(StockAdjustmentController());

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final width = MediaQuery.of(context).size.width;

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
                hintText: 'Search product, code, or notes...',
                border: InputBorder.none,
                isDense: true,
              ),
            );
          }

          return Text(
            'Stock Adjustment',
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
                size: width * 0.065,
              ),
            );
          }),
          SizedBox(width: width * 0.02),
        ],
      ),

      // ==========================================================
      // BODY (ADJUSTMENTS LIST)
      // ==========================================================

      body: Obx(() {
        if (controller.isLoading.value && controller.filteredAdjustments.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.filteredAdjustments.isEmpty) {
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

        if (controller.filteredAdjustments.isEmpty) {
          return Center(
            child: Text(
              controller.searchQuery.value.isNotEmpty
                  ? 'No matching adjustments found.'
                  : 'No stock adjustments recorded.',
              style: TextStyle(
                fontSize: rs.sp(15),
                color: colorsList.textHintColor,
              ),
            ),
          );
        }

        final items = controller.filteredAdjustments;

        return ResponsivePage(
          padding: EdgeInsets.zero,
          child: RefreshIndicator(
            onRefresh: controller.refreshAdjustments,
            child: ListView.builder(
              padding: EdgeInsets.only(
                left: rs.pagePaddingH,
                right: rs.pagePaddingH,
                top: rs.s(12),
                bottom: rs.s(24),
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildAdjustmentCard(
                  item: item,
                  width: width,
                );
              },
            ),
          ),
        );
      }),
    );
  }

  // ================================================================
  // ADJUSTMENT CARD ITEM (MATCHES WEB TABLE COLUMNS)
  // ================================================================

  Widget _buildAdjustmentCard({
    required StockAdjustmentModel item,
    required double width,
  }) {
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
      margin: const EdgeInsets.only(bottom: 12),
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
        padding: EdgeInsets.all(width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                          fontSize: width * 0.038,
                          fontWeight: FontWeight.normal,
                          color: colorsList.textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        articleCode,
                        style: TextStyle(
                          fontSize: width * 0.029,
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
                      fontSize: width * 0.027,
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: width * 0.025),
            const Divider(height: 1, color: Color(0xFFF0F4F8)),
            SizedBox(height: width * 0.025),

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
                        fontSize: width * 0.026,
                        color: colorsList.textHintColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      qtyText,
                      style: TextStyle(
                        fontSize: width * 0.034,
                        fontWeight: FontWeight.normal,
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
                        fontSize: width * 0.026,
                        color: colorsList.textHintColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: width * 0.030,
                        fontWeight: FontWeight.normal,
                        color: colorsList.textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (notesStr != '—') ...[
              SizedBox(height: width * 0.022),
              Text(
                'Notes / Reason',
                style: TextStyle(
                  fontSize: width * 0.026,
                  color: colorsList.textHintColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                notesStr,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: width * 0.030,
                  color: colorsList.secondaryText,
                ),
              ),
            ],

            SizedBox(height: width * 0.025),
            const Divider(height: 1, color: Color(0xFFF0F4F8)),
            SizedBox(height: width * 0.022),

            // ADJUST STOCK BUTTON
            /*Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () {
                  AppSnackbar.info(
                    title: 'Adjust Stock',
                    message: 'Coming Soon!',
                  );
                },
                icon: const Icon(Icons.tune_rounded, size: 16),
                label: const Text(
                  'Adjust Stock',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorsList.primaryBlue,
                  side: const BorderSide(color: colorsList.primaryBlue),
                  minimumSize: const Size(0, 36),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),*/
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