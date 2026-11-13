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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorsList.iconColor,
            size: 20,
          ),
        ),
        title: const Text(
          'Products',
          style: TextStyle(
            color: colorsList.textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
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
              style: const TextStyle(
                color: colorsList.red,
                fontSize: 14,
              ),
            ),
          );
        }

        if (controller.catalogList.isEmpty) {
          return const Center(
            child: Text(
              'No catalog items found.',
              style: TextStyle(
                fontSize: 15,
                color: colorsList.textHintColor,
              ),
            ),
          );
        }

        final items = controller.catalogList;
        final cols = rs.listColumns;

        if (cols <= 1) {
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
                      asGridTile: false,
                    ),
                  );
                },
              ),
            ),
          );
        }

        return ResponsivePage(
          padding: EdgeInsets.zero,
          child: RefreshIndicator(
            onRefresh: controller.refreshCatalog,
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
                    ? (rs.isLandscape ? 1.85 : 1.40)
                    : (rs.isLandscape ? 2.6 : 1.8),
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
                    asGridTile: true,
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
            fontWeight: FontWeight.bold,
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
    bool asGridTile = false,
  }) {
    final rs = context.rs;
    final isTab = rs.isTablet;

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
                          fontSize: isTab ? 15 : rs.sp(15),
                          fontWeight: FontWeight.bold,
                          color: colorsList.textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        articleNo,
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
                Row(
                  mainAxisSize: MainAxisSize.min,
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
                              fontSize: isTab ? 11 : rs.sp(11),
                              fontWeight: FontWeight.w600,
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
                                fontSize: isTab ? 11 : rs.sp(11),
                                fontWeight: FontWeight.w600,
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

            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF0F4F8)),
            const SizedBox(height: 10),

            // DETAILS GRID ROW: UNIT | DEFAULT QTY | STOCK | VAT | CREATED | PRICE
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _miniStat(context, 'Unit', unitStr),
                  const SizedBox(width: 12),
                  _miniStat(context, 'Default Qty', qtyStr),
                  if (!isService) ...[
                    const SizedBox(width: 12),
                    _miniStat(context, 'Stock', _formatNum(stockQtyNum.toDouble())),
                  ],
                  const SizedBox(width: 12),
                  _miniStat(context, 'VAT %', vatStr),
                  const SizedBox(width: 12),
                  _miniStat(context, 'Created', dateStr),
                  const SizedBox(width: 12),
                  _miniStat(context, 'Price (net)', priceStr, isPrimary: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(
    BuildContext context,
    String label,
    String value, {
    bool isPrimary = false,
  }) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTab ? 9.5 : rs.sp(10),
            color: colorsList.textHintColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isTab ? 12 : rs.sp(12.5),
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
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