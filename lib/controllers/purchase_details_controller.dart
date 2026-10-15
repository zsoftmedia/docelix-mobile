import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/incoming_invoices_model.dart';
import 'package:docelix_mobileapp/models/purchase_details_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class PurchaseDetailsController extends GetxController {
  final DioClient dioClient = DioClient();

  final Rxn<PurchaseDetailsModel> purchase = Rxn<PurchaseDetailsModel>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    int? purchaseId;

    if (Get.arguments is int) {
      purchaseId = Get.arguments as int;
    } else if (Get.arguments is IncomingInvoicesModel) {
      purchaseId = (Get.arguments as IncomingInvoicesModel).id;
    } else if (Get.arguments is Map && Get.arguments['id'] != null) {
      purchaseId = int.tryParse(Get.arguments['id'].toString());
    }

    if (purchaseId != null && purchaseId > 0) {
      fetchPurchaseDetails(purchaseId);
    }
  }

  Future<void> fetchPurchaseDetails(int purchaseId) async {
    try {
      isLoading.value = true;

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      if (accessToken == null || accessToken.isEmpty) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Access token is not available.',
        );
        return;
      }

      if (companyId == null) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Company ID is not available.',
        );
        return;
      }

      final companyIdInt = int.parse(companyId.toString());

      debugPrint('Fetching purchase details for ID $purchaseId, company: $companyIdInt');

      final response = await dioClient.getPurchaseDetails(
        companyId: companyIdInt,
        purchaseId: purchaseId,
        accessToken: accessToken,
      );

      debugPrint('Purchase Details Status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(response.data as Map);

        purchase.value = PurchaseDetailsModel.fromJson(data);

        debugPrint('Purchase Details Loaded: #${purchase.value?.purchaseNumber}');
      } else {
        purchase.value = null;
        AppSnackbar.error(
          title: 'Error',
          message: 'Unable to load purchase details.',
        );
      }
    } on DioException catch (e) {
      debugPrint('Purchase Details Dio Error: ${e.message}');
      AppSnackbar.error(
        title: 'Error',
        message: e.response?.data?['message']?.toString() ??
            e.message ??
            'Unable to load purchase details.',
      );
    } catch (e) {
      debugPrint('Purchase Details Error: $e');
      AppSnackbar.error(
        title: 'Error',
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  String getCurrencySymbol(String? code) {
    final String rawCode = (code != null && code.trim().isNotEmpty)
        ? code.trim().toUpperCase()
        : (purchase.value?.currency?.trim().toUpperCase() ??
            SessionManager.accessCorrencycode?.trim().toUpperCase() ??
            'EUR');

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