import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/catalog_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/catalog_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CatalogsDetailsController extends GetxController {
  final DioClient dioClient = DioClient();

  final Rxn<CatalogModel> item = Rxn<CatalogModel>();
  final RxBool isDeleting = false.obs;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments is CatalogModel) {
      item.value = Get.arguments as CatalogModel;
    }
  }

  Future<void> deleteCatalogItem() async {
    final currentItem = item.value;
    if (currentItem == null || currentItem.id == null || currentItem.id! <= 0) return;

    final bool? confirmed = await Get.dialog<bool>(
      ResponsiveDialogBody(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Catalog Item',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A2342),
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${currentItem.articleName ?? 'this item'}"? '
            'This action cannot be undone.',
            style: const TextStyle(
              color: Color(0xFF60728D),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF60728D))),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    await _performDelete(currentItem.id!);
  }

  Future<void> _performDelete(int itemId) async {
    try {
      isDeleting.value = true;

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      if (accessToken == null || accessToken.isEmpty || companyId == null) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Authentication token or company ID missing.',
        );
        return;
      }

      final int companyIdInt = int.parse(companyId.toString());

      debugPrint('Deleting catalog item ID $itemId for company $companyIdInt');

      final response = await dioClient.deleteCatalogItem(
        itemId: itemId,
        companyId: companyIdInt,
        accessToken: accessToken,
      );

      debugPrint('Delete Catalog Item Response Status: ${response.statusCode}');

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        while (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
          Get.back();
        }

        Get.back(result: true);

        AppSnackbar.success(
          title: 'Success',
          message: 'Catalog item deleted successfully.',
        );

        if (Get.isRegistered<CatalogController>()) {
          Get.find<CatalogController>().refreshCatalog();
        }
      } else {
        AppSnackbar.error(
          title: 'Delete Failed',
          message: 'Unable to delete catalog item.',
        );
      }
    } on DioException catch (e) {
      debugPrint('Delete Catalog Item Dio Error: ${e.message}');
      String message = 'Unable to delete catalog item.';

      if (e.response?.data is Map) {
        message = e.response?.data['message']?.toString() ??
            e.response?.data['error']?.toString() ??
            message;
      }

      AppSnackbar.error(
        title: 'Delete Failed',
        message: message,
      );
    } catch (e) {
      debugPrint('Delete Catalog Item Exception: $e');

      AppSnackbar.error(
        title: 'Error',
        message: 'Something went wrong while deleting catalog item.',
      );
    } finally {
      isDeleting.value = false;
    }
  }

  String getCurrencySymbol(String? code) {
    final String rawCode = (code != null && code.trim().isNotEmpty)
        ? code.trim().toUpperCase()
        : (SessionManager.accessCorrencycode?.trim().toUpperCase() ?? 'EUR');

    switch (rawCode) {
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      case 'CAD':
        return 'CA\$';
      case 'AUD':
        return 'A\$';
      case 'CHF':
        return 'CHF';
      case 'JPY':
        return '¥';
      case 'PKR':
        return 'Rs.';
      default:
        return rawCode;
    }
  }

  String formatCurrency(num? amount, [String? currencyCode]) {
    final double value = (amount ?? 0).toDouble();
    final String symbol = getCurrencySymbol(currencyCode);

    final parts = value.toStringAsFixed(2).split('.');
    final String integerPart = parts[0];
    final String decimalPart = parts[1];

    final String formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    return '$symbol $formattedInteger.$decimalPart';
  }
}