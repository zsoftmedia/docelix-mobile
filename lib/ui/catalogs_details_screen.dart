import 'package:docelix_mobileapp/controllers/catalogs_details_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/catalog_model.dart';
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
    final rs = context.rs;
    final isTab = rs.isTablet;

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
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                artNum.isNotEmpty ? '#$artNum' : 'Stock Item',
                style: const TextStyle(
                  color: colorsList.textHintColor,
                  fontSize: 12,
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
                  padding: EdgeInsets.symmetric(
                    horizontal: rs.pagePaddingH,
                    vertical: rs.s(16),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: rs.sheetMaxWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ====================================================
                          // 1. HEADER CARD
                          // ====================================================
                          _buildHeaderCard(context, item, isService, typeColor, typeLabel),

                          const SizedBox(height: 14),

                          // ====================================================
                          // 2. ITEM DETAILS CARD
                          // ====================================================
                          _sectionTitle('Stock Details', isTab),
                          const SizedBox(height: 8),

                          _buildStockDetailsCard(context, item, isService, typeLabel),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ==========================================================
              // BOTTOM ACTIONS BAR (EDIT & DELETE)
              // ==========================================================

              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  rs.pagePaddingH,
                  12,
                  rs.pagePaddingH,
                  16,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFE5EAF0)),
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: rs.sheetMaxWidth),
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
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorsList.textColor,
                              side: const BorderSide(color: Color(0xFFD0D5DD)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

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
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
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
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ================================================================
  // 1. HEADER CARD
  // ================================================================

  Widget _buildHeaderCard(
    BuildContext context,
    CatalogModel item,
    bool isService,
    Color typeColor,
    String typeLabel,
  ) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTab ? 16 : rs.s(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EAF1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isService
                  ? Icons.design_services_outlined
                  : Icons.inventory_2_outlined,
              color: typeColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.articleName ?? 'Unnamed Item',
                  style: TextStyle(
                    fontSize: isTab ? 18 : rs.sp(18),
                    fontWeight: FontWeight.bold,
                    color: colorsList.textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Code: ${item.articleNumber ?? '—'}',
                  style: TextStyle(
                    fontSize: isTab ? 13 : rs.sp(13),
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
              color: typeColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              typeLabel,
              style: TextStyle(
                fontSize: isTab ? 11 : rs.sp(11),
                color: typeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // 2. STOCK DETAILS CARD
  // ================================================================

  Widget _buildStockDetailsCard(
    BuildContext context,
    CatalogModel item,
    bool isService,
    String typeLabel,
  ) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTab ? 16 : rs.s(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4EAF1)),
      ),
      child: Column(
        children: [
          _detailRow(context, 'Item Name', item.articleName ?? '—'),
          _detailRow(context, 'Article Code', item.articleNumber ?? '—'),
          _detailRow(context, 'Item Type', typeLabel),
          _detailRow(context, 'Unit', item.unitCode ?? '—'),
          _detailRow(
            context,
            'Default Qty',
            item.defaultQty != null
                ? _formatNum(item.defaultQty!)
                : '1',
          ),
          _detailRow(
            context,
            'Net Price',
            controller.formatCurrency(item.unitPriceNet),
          ),
          _detailRow(
            context,
            'Gross Price',
            controller.formatCurrency(item.unitPriceGross),
          ),
          _detailRow(
            context,
            'VAT %',
            item.vatRate != null ? '${_formatNum(item.vatRate!)}%' : '0%',
          ),
          if (item.purchasePriceNet != null)
            _detailRow(
              context,
              'Purchase Price',
              controller.formatCurrency(item.purchasePriceNet),
            ),
          if (!isService) ...[
            _detailRow(
              context,
              'Stock Quantity',
              item.stockQty != null
                  ? _formatNum(item.stockQty!)
                  : '0',
            ),
            _detailRow(
              context,
              'Min Stock',
              item.minStock != null
                  ? _formatNum(item.minStock!)
                  : '0',
            ),
          ],
          _detailRow(
            context,
            'Created Date',
            _formatDate(item.createdAt),
            showBorder: (item.description ?? '').isNotEmpty,
          ),
          if ((item.description ?? '').isNotEmpty)
            _detailRow(context, 'Description', item.description!, showBorder: false),
        ],
      ),
    );
  }

  // ================================================================
  // HELPER WIDGETS
  // ================================================================

  Widget _sectionTitle(String title, bool isTab) {
    return Text(
      title,
      style: TextStyle(
        color: colorsList.textColor,
        fontSize: isTab ? 15 : 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    String label,
    String value, {
    bool showBorder = true,
  }) {
    final rs = context.rs;
    final isTab = rs.isTablet;

    return Container(
      padding: EdgeInsets.symmetric(vertical: isTab ? 10 : 12),
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
              fontSize: isTab ? 13 : rs.sp(13),
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
                fontSize: isTab ? 13 : rs.sp(13),
                fontWeight: FontWeight.bold,
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