import 'package:docelix_mobileapp/controllers/catalog_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/catalog_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CatalogsScreen extends StatelessWidget {
  CatalogsScreen({super.key});

  final CatalogController controller = Get.put(CatalogController());

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorsList.iconColor,
            size: rs.s(20),
          ),
        ),
        title: Text(
          'Products',
          style: TextStyle(
            color: colorsList.textColor,
            fontSize: rs.sp(18),
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.catalogList.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.catalogList.isEmpty) {
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

        if (controller.catalogList.isEmpty) {
          return Center(
            child: Text(
              'No catalog items found.',
              style: TextStyle(
                fontSize: rs.sp(15),
                color: colorsList.textHintColor,
              ),
            ),
          );
        }

        final items = controller.catalogList;

        return ResponsivePage(
          padding: EdgeInsets.zero,
          child: RefreshIndicator(
            onRefresh: controller.refreshCatalog,
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
                return InkWell(
                  onTap: () async {
                    final result = await Get.toNamed(
                      '/CatalogsDetailsScreen',
                      arguments: item,
                    );
                    if (result == true) {
                      controller.refreshCatalog();
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: _buildCatalogCard(
                    context: context,
                    item: item,
                  ),
                );
              },
            ),
          ),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.toNamed(
            '/AddItemScreen',
            arguments: 'Add Item Screen',
          );

          if (result == true) {
            controller.refreshCatalog();
          }
        },
        backgroundColor: colorsList.colorButton,
        foregroundColor: colorsList.colorWhite,
        elevation: 4,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: Text(
          'Add Item',
          style: TextStyle(
            fontSize: rs.sp(14),
            fontWeight: FontWeight.w600,
            color: colorsList.colorWhite,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // CATALOG CARD ITEM (MATCHES WEB TABLE COLUMNS)
  // ================================================================

  Widget _buildCatalogCard({
    required BuildContext context,
    required CatalogModel item,
  }) {
    final width = context.rs.width;

    final String itemName = item.articleName?.isNotEmpty == true
        ? item.articleName!
        : 'Unnamed Item';

    final String articleNo = item.articleNumber?.isNotEmpty == true
        ? item.articleNumber!
        : '—';

    final String itemTypeStr =
        item.itemType?.toLowerCase().trim() ?? 'service';
    final bool isService = itemTypeStr == 'service';
    final Color typeColor =
        isService ? const Color(0xFF16A34A) : const Color(0xFF2563EB);
    final String typeLabel = isService ? 'Service' : 'Physical';

    final num stockQtyNum = item.stockQty ?? 0;
    final bool isOutOfStock = stockQtyNum <= 0 && !isService;

    final String priceStr = controller.formatCurrency(item.unitPriceNet);
    final String vatStr =
        item.vatRate != null ? '${_formatNum(item.vatRate!)}%' : '0%';
    final String unitStr =
        item.unitCode?.isNotEmpty == true ? item.unitCode! : '—';
    final String qtyStr =
        item.defaultQty != null ? _formatNum(item.defaultQty!) : '1';
    final String dateStr = _formatDate(item.createdAt);

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
            // TOP ROW: ITEM NAME + ARTICLE NO + TYPE BADGE + OUT OF STOCK
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemName,
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
                        articleNo,
                        style: TextStyle(
                          fontSize: width * 0.029,
                          color: colorsList.textHintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // TYPE BADGE
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: typeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            typeLabel,
                            style: TextStyle(
                              fontSize: width * 0.026,
                              fontWeight: FontWeight.normal,
                              color: typeColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // OUT OF STOCK BADGE IF PHYSICAL & STOCK <= 0
                    if (isOutOfStock) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Color(0xFFDC2626),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Out of stock',
                              style: TextStyle(
                                fontSize: width * 0.026,
                                fontWeight: FontWeight.normal,
                                color: const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            SizedBox(height: width * 0.025),
            const Divider(height: 1, color: Color(0xFFF0F4F8)),
            SizedBox(height: width * 0.025),

            // DETAILS GRID ROW: UNIT | DEFAULT QTY | STOCK | VAT | CREATED | PRICE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _miniStat('Unit', unitStr, width),
                _miniStat('Default Qty', qtyStr, width),
                if (!isService)
                  _miniStat(
                      'Stock', '${_formatNum(stockQtyNum.toDouble())}', width),
                _miniStat('VAT %', vatStr, width),
                _miniStat('Created', dateStr, width),
                _miniStat('Price (net)', priceStr, width, isPrimary: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value, double width,
      {bool isPrimary = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: width * 0.025,
            color: colorsList.textHintColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: width * 0.029,
            fontWeight: FontWeight.normal,
            color: isPrimary ? const Color(0xFF063C70) : colorsList.textColor,
          ),
        ),
      ],
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