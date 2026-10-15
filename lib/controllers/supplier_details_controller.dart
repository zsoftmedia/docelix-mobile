import 'package:docelix_mobileapp/models/incoming_invoices_model.dart';
import 'package:docelix_mobileapp/models/supplier_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class SupplierDetailsController extends GetxController {
  final DioClient dioClient = DioClient();

  final Rxn<SupplierModel> supplier = Rxn<SupplierModel>();
  final RxInt selectedTab = 0.obs;

  final RxList<IncomingInvoicesModel> purchases = <IncomingInvoicesModel>[].obs;
  final RxBool isLoadingPurchases = false.obs;

  final List<String> tabs = const [
    'Overview',
    'Purchases',
    'Payments',
    'Supplier Ledger',
  ];

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments is SupplierModel) {
      supplier.value = Get.arguments as SupplierModel;
      fetchSupplierPurchases();
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
    if (index == 1 && purchases.isEmpty && !isLoadingPurchases.value) {
      fetchSupplierPurchases();
    }
  }

  Future<void> fetchSupplierPurchases() async {
    final currentSupplier = supplier.value;
    if (currentSupplier == null) return;

    try {
      isLoadingPurchases.value = true;

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      if (accessToken == null || accessToken.isEmpty || companyId == null) {
        return;
      }

      final companyIdInt = int.parse(companyId.toString());

      debugPrint(
          'Fetching purchases for supplier ID ${currentSupplier.id}, company: $companyIdInt');

      final response = await dioClient.getSupplierPurchases(
        companyId: companyIdInt,
        supplierId: currentSupplier.id,
        accessToken: accessToken,
      );

      debugPrint('Supplier Purchases Status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> items = [];

        if (response.data is Map) {
          final Map<String, dynamic> responseData =
              Map<String, dynamic>.from(response.data as Map);
          items = responseData['data'] as List<dynamic>? ?? [];
        } else if (response.data is List) {
          items = response.data as List<dynamic>;
        }

        final List<IncomingInvoicesModel> loadedPurchases = items
            .map(
              (item) => IncomingInvoicesModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();

        purchases.assignAll(loadedPurchases);

        debugPrint('Supplier Purchases Loaded: ${purchases.length}');
      } else {
        purchases.clear();
      }
    } catch (e) {
      debugPrint('Fetch Supplier Purchases Error: $e');
      purchases.clear();
    } finally {
      isLoadingPurchases.value = false;
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