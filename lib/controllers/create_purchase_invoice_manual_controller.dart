import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/supplier_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CreatePurchaseInvoiceManualController extends GetxController {
  final DioClient _dioClient = DioClient();

  // MAIN TABS: 0 -> Invoice, 1 -> Receipt, 2 -> Credit note
  final RxInt selectedTabIndex = 0.obs;

  static const tabs = <String>[
    'Invoice',
    'Receipt',
    'Credit note',
  ];

  void selectTab(int index) {
    selectedTabIndex.value = index;
  }

  // ============================================================
  // INVOICE TAB STEPPER
  // ============================================================

  final RxInt currentInvoiceStep = 0.obs;
  final int totalInvoiceSteps = 4;

  static const invoiceSteps = <String>[
    'Supplier details',
    'Purchased items / services',
    'Payment details',
    'Internal notes',
  ];

  void goToInvoiceStep(int step) {
    if (step <= currentInvoiceStep.value) {
      currentInvoiceStep.value = step;
    }
  }

  void nextInvoiceStep() {
    if (currentInvoiceStep.value < totalInvoiceSteps - 1) {
      currentInvoiceStep.value++;
    } else {
      submitPurchaseInvoice();
    }
  }

  void previousInvoiceStep() {
    if (currentInvoiceStep.value > 0) {
      currentInvoiceStep.value--;
    }
  }

  // ============================================================
  // STEP 1: SUPPLIER DETAILS FIELDS & CONTROLLERS
  // ============================================================

  final RxList<SupplierModel> suppliers = <SupplierModel>[].obs;
  final Rxn<SupplierModel> selectedSupplier = Rxn<SupplierModel>();
  final RxBool isLoadingSuppliers = false.obs;
  final RxString supplierSearchQuery = ''.obs;

  List<SupplierModel> get filteredSuppliers {
    final query = supplierSearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return suppliers;
    return suppliers.where((s) {
      final name = s.name.toLowerCase();
      final email = (s.email ?? '').toLowerCase();
      final phone = (s.phone ?? '').toLowerCase();
      final city = (s.city ?? '').toLowerCase();
      return name.contains(query) || email.contains(query) || phone.contains(query) || city.contains(query);
    }).toList();
  }

  final supplierInvoiceNumberController = TextEditingController();
  final RxBool hasNoDocumentNumber = false.obs;
  final referenceController = TextEditingController();

  final supplierInvoiceDateController = TextEditingController(
    text: DateFormat('dd.MM.yyyy').format(DateTime.now()),
  );

  final purchaseDateController = TextEditingController(
    text: DateFormat('dd.MM.yyyy').format(DateTime.now()),
  );

  final dueDateController = TextEditingController(
    text: DateFormat('dd.MM.yyyy').format(DateTime.now().add(const Duration(days: 30))),
  );

  // CURRENCY & SEARCH
  final RxString selectedCurrency = 'EUR'.obs;
  final RxString currencySearchQuery = ''.obs;

  final RxList<String> availableCurrencies = <String>[
    'EUR',
    'GBP',
    'INR',
    'PKR',
    'AED',
    'USD',
    'CHF',
  ].obs;

  List<String> get filteredCurrencies {
    final query = currencySearchQuery.value.trim().toUpperCase();
    if (query.isEmpty) return availableCurrencies;
    return availableCurrencies.where((c) => c.contains(query)).toList();
  }

  final ibanController = TextEditingController();
  final deliveryNoteController = TextEditingController();
  final orderReferenceController = TextEditingController();
  final serviceFromDateController = TextEditingController();
  final serviceToDateController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    final token = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;

    if (token == null || token.isEmpty || companyId == null || companyId == 0) {
      return;
    }

    try {
      isLoadingSuppliers.value = true;
      final response = await _dioClient.getSuppliers(
        companyId: companyId,
        accessToken: token,
        page: 1,
        pageSize: 20
      );

      if (response.statusCode == 200 && response.data != null) {
        final supplierRes = SupplierResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        suppliers.assignAll(supplierRes.data);
      }
    } catch (e) {
      debugPrint('[CreatePurchaseInvoiceManualController] loadSuppliers Error: $e');
    } finally {
      isLoadingSuppliers.value = false;
    }
  }

  void selectSupplier(SupplierModel supplier) {
    selectedSupplier.value = supplier;

    // 1. Auto-fill IBAN if available
    if ((supplier.iban ?? '').isNotEmpty) {
      ibanController.text = supplier.iban!;
    } else {
      ibanController.clear();
    }

    // 2. Auto-recalculate Due Date based on supplier payment terms
    final days = supplier.paymentTermsDays ?? 30;
    try {
      final parts = purchaseDateController.text.trim().split('.');
      if (parts.length == 3) {
        final pDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
        final calculatedDueDate = pDate.add(Duration(days: days));
        dueDateController.text = DateFormat('dd.MM.yyyy').format(calculatedDueDate);
      }
    } catch (_) {}
  }

  void selectCurrency(String currency) {
    selectedCurrency.value = currency;
    currencySearchQuery.value = '';
  }

  Future<void> submitPurchaseInvoice() async {
    AppSnackbar.info(
      title: 'Saving Invoice',
      message: 'Purchase invoice processing...',
    );
  }

  @override
  void onClose() {
    supplierInvoiceNumberController.dispose();
    referenceController.dispose();
    supplierInvoiceDateController.dispose();
    purchaseDateController.dispose();
    dueDateController.dispose();
    ibanController.dispose();
    deliveryNoteController.dispose();
    orderReferenceController.dispose();
    serviceFromDateController.dispose();
    serviceToDateController.dispose();
    super.onClose();
  }
}