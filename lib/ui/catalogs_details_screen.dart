import 'package:docelix_mobileapp/controllers/catalogs_details_controller.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CatalogsDetailsScreen extends StatefulWidget {
  const CatalogsDetailsScreen({super.key});

  @override
  State<CatalogsDetailsScreen> createState() => _CatalogsDetailsScreenState();
}

class _CatalogsDetailsScreenState extends State<CatalogsDetailsScreen> {
  final CatalogsDetailsController controller =
      Get.put(CatalogsDetailsController());

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
          final artNum = controller.item.value?.articleNumber ?? '';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stock Addition Details',
                style: TextStyle(
                  color: colorsList.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                artNum.isNotEmpty ? '#$artNum' : 'Stock Item',
                style: TextStyle(
                  color: colorsList.textHintColor,
                  fontSize: width * 0.030,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          );
        }),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: Obx(() {
        final item = controller.item.value;

        if (item == null) {
          return const Center(
            child: Text(
              'Stock information not available.',
              style: TextStyle(
                color: colorsList.textHintColor,
                fontSize: 15,
              ),
            ),
          );
        }

        final String itemTypeStr =
            item.itemType?.toLowerCase().trim() ?? 'service';
        final bool isService = itemTypeStr == 'service';
        final Color typeColor =
            isService ? const Color(0xFF16A34A) : const Color(0xFF2563EB);
        final String typeLabel = isService ? 'Service' : 'Physical';

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
                      // 1. HEADER CARD
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
                            Container(
                              width: width * 0.12,
                              height: width * 0.12,
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isService
                                    ? Icons.design_services_outlined
                                    : Icons.inventory_2_outlined,
                                color: typeColor,
                                size: width * 0.065,
                              ),
                            ),
                            SizedBox(width: width * 0.035),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.articleName ?? 'Unnamed Item',
                                    style: TextStyle(
                                      fontSize: width * 0.045,
                                      fontWeight: FontWeight.normal,
                                      color: colorsList.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Code: ${item.articleNumber ?? '—'}',
                                    style: TextStyle(
                                      fontSize: width * 0.031,
                                      color: colorsList.textHintColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                typeLabel,
                                style: TextStyle(
                                  fontSize: width * 0.028,
                                  color: typeColor,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: height * 0.018),

                      // ====================================================
                      // 2. ITEM DETAILS CARD
                      // ====================================================
                      _sectionTitle('Stock Details', width),
                      const SizedBox(height: 8),

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(width * 0.045),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE4EAF1)),
                        ),
                        child: Column(
                          children: [
                            _detailRow('Item Name', item.articleName ?? '—', width),
                            _detailRow('Article Code', item.articleNumber ?? '—', width),
                            _detailRow('Item Type', typeLabel, width),
                            _detailRow('Unit', item.unitCode ?? '—', width),
                            _detailRow(
                              'Default Qty',
                              item.defaultQty != null
                                  ? _formatNum(item.defaultQty!)
                                  : '1',
                              width,
                            ),
                            _detailRow(
                              'Net Price',
                              controller.formatCurrency(item.unitPriceNet),
                              width,
                            ),
                            _detailRow(
                              'Gross Price',
                              controller.formatCurrency(item.unitPriceGross),
                              width,
                            ),
                            _detailRow(
                              'VAT %',
                              item.vatRate != null ? '${_formatNum(item.vatRate!)}%' : '0%',
                              width,
                            ),
                            if (item.purchasePriceNet != null)
                              _detailRow(
                                'Purchase Price',
                                controller.formatCurrency(item.purchasePriceNet),
                                width,
                              ),
                            if (!isService) ...[
                              _detailRow(
                                'Stock Quantity',
                                item.stockQty != null
                                    ? _formatNum(item.stockQty!)
                                    : '0',
                                width,
                              ),
                              _detailRow(
                                'Min Stock',
                                item.minStock != null
                                    ? _formatNum(item.minStock!)
                                    : '0',
                                width,
                              ),
                            ],
                            _detailRow(
                              'Created Date',
                              _formatDate(item.createdAt),
                              width,
                              showBorder: (item.description ?? '').isNotEmpty,
                            ),
                            if ((item.description ?? '').isNotEmpty)
                              _detailRow('Description', item.description!, width, showBorder: false),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ==========================================================
              // BOTTOM ACTIONS BAR (EDIT & DELETE)
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
                        onPressed: () async {
                          final result = await Get.toNamed(
                            '/EditCatalogsScreen',
                            arguments: item,
                          );

                          if (result == true) {
                            Get.back(result: true);
                          }
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text(
                          'Edit Item',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorsList.textColor,
                          side: const BorderSide(color: Color(0xFFD0D5DD)),
                          minimumSize: Size(0, height * 0.055),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: width * 0.03),

                    Expanded(
                      child: Obx(
                        () => ElevatedButton.icon(
                          onPressed: controller.isDeleting.value
                              ? null
                              : controller.deleteCatalogItem,
                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                          label: Text(
                            controller.isDeleting.value
                                ? 'Deleting...'
                                : 'Delete Stock',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: Size(0, height * 0.055),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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

  Widget _sectionTitle(String title, double width) {
    return Text(
      title,
      style: TextStyle(
        color: colorsList.textColor,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value,
    double width, {
    bool showBorder = true,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: width * 0.028),
      decoration: showBorder
          ? const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFF0F4F8)),
              ),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: width * 0.031,
              color: colorsList.textHintColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: colorsList.textColor,
              ),
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