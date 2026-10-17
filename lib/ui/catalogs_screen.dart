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
            color: colorsList.colorBackArrow,
            size: rs.s(20),
          ),
        ),
        title: Text(
          'Items',
          style: TextStyle(
            color: colorsList.textColor,
            fontSize: rs.sp(20),
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
              'No items found.',
              style: TextStyle(
                fontSize: rs.sp(16),
                color: colorsList.colorGray_350,
              ),
            ),
          );
        }

        final cols = rs.listColumns;
        final items = controller.catalogList;

        return ResponsivePage(
          padding: EdgeInsets.zero,
          child: RefreshIndicator(
            onRefresh: controller.refreshCatalog,
            child: cols <= 1
                ? ListView.builder(
                    padding: EdgeInsets.only(
                      left: rs.pagePaddingH,
                      right: rs.pagePaddingH,
                      bottom: rs.s(96),
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final double stock = item.stockQty ?? 0;
                      final double minStock = item.minStock ?? 0;
                      return _catalogItem(
                        context: context,
                        item: item,
                        lowStock: stock <= minStock,
                        asGridTile: false,
                      );
                    },
                  )
                : GridView.builder(
                    padding: EdgeInsets.only(
                      left: rs.pagePaddingH,
                      right: rs.pagePaddingH,
                      top: rs.s(8),
                      bottom: rs.s(96),
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: rs.s(12),
                      mainAxisSpacing: rs.s(12),
                      childAspectRatio: rs.isLandscape ? 2.8 : 2.3,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final double stock = item.stockQty ?? 0;
                      final double minStock = item.minStock ?? 0;
                      return _catalogItem(
                        context: context,
                        item: item,
                        lowStock: stock <= minStock,
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
            fontSize: rs.sp(15),
            fontWeight: FontWeight.w700,
            color: colorsList.colorWhite,
          ),
        ),
      ),
    );
  }

  Widget _catalogItem({
    required BuildContext context,
    required CatalogModel item,
    required bool lowStock,
    required bool asGridTile,
  }) {
    final rs = context.rs;

    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: asGridTile ? rs.s(12) : rs.s(4),
        vertical: rs.s(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: lowStock ? colorsList.orange : colorsList.iconColor,
            size: rs.s(24),
          ),
          SizedBox(width: rs.s(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.articleName ?? 'Unnamed Item',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorsList.textColor,
                    fontSize: rs.sp(16),
                  ),
                ),
                SizedBox(height: rs.s(4)),
                Text(
                  item.articleNumber ?? 'N/A',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorsList.textColor,
                    fontSize: rs.sp(12),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: rs.s(10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.unitPriceNet?.toStringAsFixed(2) ?? '0.00',
                style: TextStyle(
                  color: colorsList.textColor,
                  fontSize: rs.sp(14),
                ),
              ),
              SizedBox(height: rs.s(3)),
              Text(
                item.unitCode ?? '',
                style: TextStyle(
                  color: colorsList.textColor,
                  fontSize: rs.sp(11),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (asGridTile) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: colorsList.colorWhite,
          borderRadius: BorderRadius.circular(rs.s(12)),
          border: Border.all(color: colorsList.borderColor),
        ),
        child: content,
      );
    }

    return Container(
      color: colorsList.colorWhite,
      child: Column(
        children: [
          content,
          Divider(
            height: 1,
            thickness: 1,
            color: colorsList.dividerColor,
            indent: rs.s(20),
            endIndent: rs.s(20),
          ),
        ],
      ),
    );
  }
}
