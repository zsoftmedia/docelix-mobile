import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/add_item_controller.dart';
import 'package:docelix_mobileapp/controllers/catalog_controller.dart';
import 'package:docelix_mobileapp/controllers/catalogs_details_controller.dart';
import 'package:docelix_mobileapp/models/catalog_model.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class EditCatalogsController extends AddItemController {
  final Rxn<CatalogModel> catalogItem = Rxn<CatalogModel>();

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments is CatalogModel) {
      catalogItem.value = Get.arguments as CatalogModel;
      _populateFormFromCatalog(catalogItem.value!);
    }
  }

  void _populateFormFromCatalog(CatalogModel item) {
    nameController.text = item.articleName ?? '';
    articleNumberController.text = item.articleNumber ?? '';
    groupCodeController.text = item.groupCode ?? '';
    descriptionController.text = item.description ?? '';

    quantityController.text = item.defaultQty?.toString() ?? '1';
    stockController.text = item.stockQty?.toString() ?? '0';
    minimumStockController.text = item.minStock?.toString() ?? '0';

    costPriceController.text = item.purchasePriceNet?.toString() ?? '0';
    salePriceController.text = item.unitPriceNet?.toString() ?? '0';
    vatController.text = item.vatRate?.toString() ?? '20';
    discountController.text = item.discount?.toString() ?? '0';
    msrpController.text = item.priceMsrp?.toString() ?? '0';

    trackStock.value = item.trackStock ?? false;

    if (item.itemType != null) {
      selectedItemType.value = _mapApiItemTypeToUI(item.itemType!);
    }

    if (item.unitCode != null && item.unitCode!.isNotEmpty) {
      selectUnit(item.unitCode);
    }
  }

  String _mapApiItemTypeToUI(String apiType) {
    final clean = apiType.toLowerCase().trim();
    if (clean == 'physical') return 'Physical material';
    if (clean == 'software') return 'Software';
    if (clean == 'service') return 'Service';
    if (clean == 'digital') return 'Digital product';

    for (final option in itemTypes) {
      if (option.toLowerCase().trim() == clean) {
        return option;
      }
    }

    return 'Physical material';
  }

  @override
  Future<void> saveItem() async {
    if (isLoading.value) return;

    final currentItem = catalogItem.value;
    if (currentItem == null || currentItem.id == null || currentItem.id! <= 0) {
      AppSnackbar.error(
        title: 'Error',
        message: 'No catalog item selected for update.',
      );
      return;
    }

    if (!validateStep(0)) {
      currentStep.value = 0;
      return;
    }

    if (!validateStep(1)) {
      currentStep.value = 1;
      return;
    }

    if (!validateStep(2)) {
      currentStep.value = 2;
      return;
    }

    final accessToken = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;

    if (accessToken == null || accessToken.isEmpty) {
      AppSnackbar.error(
        title: 'Authentication Error',
        message: 'Please log in again to continue.',
      );
      return;
    }

    if (companyId == null || int.tryParse(companyId.toString()) == null) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Company information is not available.',
      );
      return;
    }

    final int companyIdInt = int.parse(companyId.toString());

    try {
      isLoading.value = true;

      final payload = itemPayload;

      debugPrint('Updating catalog item ID ${currentItem.id}: $payload');

      final response = await dioClient.updateCatalogItem(
        itemId: currentItem.id!,
        companyId: companyIdInt,
        data: payload,
        accessToken: accessToken,
      );

      debugPrint('Update Catalog Item Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        clearForm();

        Get.back(result: true);

        AppSnackbar.success(
          title: 'Success',
          message: 'Catalog item updated successfully.',
        );

        if (Get.isRegistered<CatalogController>()) {
          Get.find<CatalogController>().refreshCatalog();
        }

        if (Get.isRegistered<CatalogsDetailsController>()) {
          final updatedData = response.data is Map && response.data['item'] is Map
              ? CatalogModel.fromJson(Map<String, dynamic>.from(response.data['item'] as Map))
              : null;
          if (updatedData != null) {
            Get.find<CatalogsDetailsController>().item.value = updatedData;
          }
        }
      } else {
        AppSnackbar.error(
          title: 'Update Failed',
          message: 'Unable to update catalog item.',
        );
      }
    } on DioException catch (e) {
      debugPrint('Update catalog item error: ${e.message}');
      debugPrint('API response: ${e.response?.data}');

      String message = 'Unable to update catalog item.';
      if (e.response?.data is Map) {
        message = e.response?.data['message']?.toString() ??
            e.response?.data['error']?.toString() ??
            message;
      }

      AppSnackbar.error(
        title: 'Update Failed',
        message: message,
      );
    } catch (e) {
      debugPrint('Unexpected update item error: $e');

      AppSnackbar.error(
        title: 'Error',
        message: 'Something went wrong while updating the item.',
      );
    } finally {
      isLoading.value = false;
    }
  }
}