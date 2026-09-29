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

      /*appBar: AppBar(
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
      ),*/

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,

        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0A2342),
            size: 20,
          ),
        ),

        title: const Text(
          'Items',
          style: TextStyle(
            color: Color(0xFF0A2342),
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
    return Container(
      color: Colors.white,
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
                  color: const Color(0xFF5F6B7A),
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
                          color: const Color(0xFF172A46),
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
                          color: const Color(0xFF7A8699),
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
                        color: const Color(0xFF172A46),
                        fontSize: width * 0.037,
                      //  fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: height * 0.003),

                    Text(
                      item.unitCode ?? '',
                      style: TextStyle(
                        color: const Color(0xFF7A8699),
                        fontSize: width * 0.029,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // List separator
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE8ECF1),
            indent: 20,
            endIndent: 20,
          ),
        ],
      ),
    );
  }
}