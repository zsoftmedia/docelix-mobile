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
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,

        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorsList.colorBackArrow,
            size: 20,
          ),
        ),

        title: const Text(
          'Items',
          style: TextStyle(
            color: colorsList.textColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),

        centerTitle: false,
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
                color: colorsList.red,
              ),
            ),
          );
        }

        // Empty
        if (controller.catalogList.isEmpty) {
          return Center(
            child: Text(
              'No items found.',
              style: TextStyle(
                fontSize: 16,
                color: colorsList.colorGray_350,
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

      // ============================================================
      // ADD ITEM BUTTON
      // ============================================================

      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {

          // ----------------------------------------------------------
          // OPEN ADD ITEM PAGE
          // ----------------------------------------------------------

          Get.toNamed(
            '/AddItemScreen',
            arguments: 'Add Item Screen',);

        },

        backgroundColor: colorsList.colorButton,
        foregroundColor: colorsList.colorWhite,

        elevation: 4,

        icon: const Icon(
          Icons.add_rounded,
        ),

        label: Text(
          "Add Item",
          style: TextStyle(
              fontSize: width * 0.038,
              fontWeight: FontWeight.w700,
              color: colorsList.colorWhite
          ),
        ),
      ),

    );
  }

  Widget _catalogItem({
    required BuildContext context,
    required CatalogModel item,
    required double width,
    required double height,
    required bool lowStock,
  })
  {
    return Container(
      color: colorsList.colorWhite,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.045,
              vertical: height * 0.014,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Item icon
                Icon(
                  Icons.inventory_2_outlined,
                  color: colorsList.iconColor,
                  size: width * 0.06,
                ),

                SizedBox(width: width * 0.035),

                // Item information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.articleName ?? 'Unnamed Item',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorsList.textColor,
                          fontSize: width * 0.043,
                        //  fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: height * 0.004),

                      Text(
                        item.articleNumber ?? 'N/A',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorsList.textColor,
                          fontSize: width * 0.032,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: width * 0.025),

                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.unitPriceNet?.toStringAsFixed(2) ?? '0.00',
                      style: TextStyle(
                        color: colorsList.textColor,
                        fontSize: width * 0.037,
                      //  fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: height * 0.003),

                    Text(
                      item.unitCode ?? '',
                      style: TextStyle(
                        color: colorsList.textColor,
                        fontSize: width * 0.029,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // List separator
          Divider(
            height: 1,
            thickness: 1,
            color: colorsList.dividerColor,
            indent: 20,
            endIndent: 20,
          ),
        ],
      ),
    );
  }
}