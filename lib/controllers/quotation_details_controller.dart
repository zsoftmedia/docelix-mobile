import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/models/quotation_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class QuotationDetailsController extends GetxController {
  final DioClient dioClient = DioClient();

  final Rxn<QuotationModel> quotation = Rxn<QuotationModel>();
  final RxList<QuotationItemModel> offerItems = <QuotationItemModel>[].obs;
  final RxBool isLoadingItems = false.obs;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments is QuotationModel) {
      quotation.value = Get.arguments as QuotationModel;
      if (quotation.value?.items.isNotEmpty == true) {
        offerItems.assignAll(quotation.value!.items);
      }
      getOfferItems();
    }
  }

  double get totalAmount {
    if (offerItems.isNotEmpty) {
      return offerItems.fold(0.0, (sum, item) => sum + item.total);
    }
    return quotation.value?.totalAmount ?? 0.0;
  }

  Future<void> getOfferItems() async {
    final currentOffer = quotation.value;
    if (currentOffer == null || currentOffer.id <= 0) return;

    try {
      isLoadingItems.value = true;

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      if (accessToken == null || accessToken.isEmpty || companyId == null) {
        return;
      }

      final companyIdInt = int.parse(companyId.toString());

      debugPrint('Fetching items for offer ID: ${currentOffer.id}');

      final response = await dioClient.getOfferItems(
        offerId: currentOffer.id,
        companyId: companyIdInt,
        accessToken: accessToken,
      );

      debugPrint('Get Offer Items Status Code: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> items = [];

        if (response.data is List) {
          items = response.data as List<dynamic>;
        } else if (response.data is Map) {
          final map = Map<String, dynamic>.from(response.data as Map);
          items = map['data'] as List<dynamic>? ?? map['items'] as List<dynamic>? ?? [];
        }

        final List<QuotationItemModel> loaded = items
            .map(
              (item) => QuotationItemModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();

        if (loaded.isNotEmpty) {
          offerItems.assignAll(loaded);
        }

        debugPrint('Offer Items Loaded: ${offerItems.length}');
      }
    } on DioException catch (e) {
      debugPrint('Get Offer Items Dio Error: ${e.message}');
    } catch (e) {
      debugPrint('Get Offer Items Exception: $e');
    } finally {
      isLoadingItems.value = false;
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