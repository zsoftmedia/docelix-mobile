import 'package:docelix_mobileapp/controllers/catalog_controller.dart';
import 'package:docelix_mobileapp/models/catalog_model.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CatalogsScreen extends StatelessWidget {
  CatalogsScreen({super.key});

  final CatalogController controller = Get.put(CatalogController());

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: colorsList.backgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Items',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Obx(() {
        // Loading
        if (controller.isLoading.value &&
            controller.catalogList.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Error
        if (controller.errorMessage.value.isNotEmpty &&
            controller.catalogList.isEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
          );
        }

        // Empty
        if (controller.catalogList.isEmpty) {
          return const Center(
            child: Text(
              'No items found.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshCatalog,
          child: ListView.builder(
            itemCount: controller.catalogList.length,
            itemBuilder: (context, index) {
              final item = controller.catalogList[index];

              final double stock = item.stockQty ?? 0;
              final double minStock = item.minStock ?? 0;

              final bool lowStock = stock <= minStock;

              return _catalogItem(
                context: context,
                item: item,
                width: width,
                height: height,
                lowStock: lowStock,
              );
            },
          ),
        );
      }),
    );
  }

  Widget _catalogItem({
    required BuildContext context,
    required CatalogModel item,
    required double width,
    required double height,
    required bool lowStock,
  }) {
    final Color stockColor =
    lowStock ? Colors.red : const Color(0xFF00B894);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.045,
        vertical: height * 0.018,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // ==========================================================
          // ITEM ICON
          // ==========================================================

          Container(
            width: width * 0.115,
            height: width * 0.115,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(width * 0.03),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: const Color(0xFF063C70),
              size: width * 0.09,
            ),
          ),

          SizedBox(width: width * 0.035),

          // ==========================================================
          // ITEM INFORMATION
          // ==========================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  item.articleName ?? 'Unnamed Item',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF172A46),
                    fontSize: width * 0.045,
                  ),
                ),

                SizedBox(height: height * 0.006),

                Text(
                  item.articleNumber ?? 'N/A',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF71829A),
                    fontSize: width * 0.033,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            thickness: 1,
            indent: 52,
            endIndent: 4,
            color: Color(0xFFEFF2F6),
          ),

          // ==========================================================
          // RIGHT SIDE: STOCK + PRICE
          // ==========================================================

          /*Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              // Stock
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.025,
                  vertical: height * 0.005,
                ),
                decoration: BoxDecoration(
                  color: stockColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Stock: ${item.stockQty?.toStringAsFixed(0) ?? '0'}',
                  style: TextStyle(
                    color: stockColor,
                    fontSize: width * 0.03,
                  ),
                ),
              ),

              SizedBox(height: height * 0.006),

              // Price
              Text(
                '${item.unitPriceNet?.toStringAsFixed(2) ?? '0.00'} ${item.unitCode ?? ''}',
                style: TextStyle(
                  color: const Color(0xFF172A46),
                  fontSize: width * 0.043,
                ),
              ),
            ],
          ),*/
        ],
      ),
    );
  }
}