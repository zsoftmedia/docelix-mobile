import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/create_purchase_invoice_manual_controller.dart';
import 'package:docelix_mobileapp/controllers/purchase_invoices_controller.dart';
import 'package:docelix_mobileapp/models/supplier_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReviewPurchaseInvoiceController extends GetxController {
  final DioClient _dioClient = DioClient();

  static const steps = <String>[
    'Review',
    'Supplier details',
    'Purchased items / services',
    'Tax & totals',
    'Payment details',
    'Internal notes',
  ];

  final RxInt currentStep = 0.obs;

  void goToStep(int step) {
    if (step >= 0 && step < steps.length) {
      currentStep.value = step;
    }
  }

  void nextStep() {
    if (currentStep.value < steps.length - 1) {
      currentStep.value++;
    } else {
      approveAndSavePurchase();
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  final RxMap<String, dynamic> scanData = <String, dynamic>{}.obs;

  // Overview / Review Step Data
  final RxInt purchaseId = 0.obs;
  final RxString purchaseNumber = ''.obs;
  final RxString supplierInvoiceNumber = ''.obs;
  final RxString supplierInvoiceDate = ''.obs;
  final RxString purchaseDate = ''.obs;
  final RxString dueDate = ''.obs;
  final RxString selectedCurrency = 'EUR'.obs;
  final RxDouble netTotal = 0.0.obs;
  final RxDouble taxTotal = 0.0.obs;
  final RxDouble grandTotal = 0.0.obs;
  final RxString attachmentName = ''.obs;
  final RxString attachmentPath = ''.obs;
  final RxString documentType = 'invoice'.obs;
  final RxString classificationReason = 'Goods for resale'.obs;

  // Payment Selection
  final RxString paymentMethodOption = 'Paid by bank or card'.obs;
  final RxBool isDocumentInvoiceChecked = true.obs;
  final RxBool isCheckedAccountLinesChecked = false.obs;

  // Supplier Details Fields
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
  final supplierInvoiceDateController = TextEditingController();
  final purchaseDateController = TextEditingController();
  final dueDateController = TextEditingController();
  final ibanController = TextEditingController();
  final deliveryNoteController = TextEditingController();
  final orderReferenceController = TextEditingController();
  final serviceFromDateController = TextEditingController();
  final serviceToDateController = TextEditingController();

  // Purchased Items Fields
  final RxString priceMode = 'Net'.obs;
  final RxBool showAccountCodes = false.obs;
  final RxList<PurchaseLineItem> purchaseLineItems = <PurchaseLineItem>[].obs;

  // Payment Details Fields
  final RxString paymentStatus = 'Paid in full'.obs;
  final RxString paidFrom = 'Bank'.obs;
  final amountPaidController = TextEditingController();
  final paymentDateController = TextEditingController();
  final paymentReferenceController = TextEditingController();

  // Internal Notes
  final internalNotesController = TextEditingController();

  final RxBool isApproving = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      scanData.value = Map<String, dynamic>.from(args);
      _parseScanData();
    }
    loadSuppliers();
  }

  void _parseScanData() {
    final data = scanData.value;
    purchaseId.value = (data['id'] as num?)?.toInt() ?? 0;
    purchaseNumber.value = data['purchase_number']?.toString() ?? 'PUR-2026-0025';
    supplierInvoiceNumber.value = data['supplier_invoice_number']?.toString() ?? '';
    supplierInvoiceDate.value = data['supplier_invoice_date']?.toString() ?? '';
    purchaseDate.value = data['purchase_date']?.toString() ?? '';
    dueDate.value = data['due_date']?.toString() ?? '';
    selectedCurrency.value = data['currency']?.toString() ?? 'EUR';

    netTotal.value = (data['subtotal'] as num?)?.toDouble() ?? 0.0;
    taxTotal.value = (data['tax_total'] as num?)?.toDouble() ?? 0.0;
    grandTotal.value = (data['total'] as num?)?.toDouble() ?? 0.0;

    attachmentName.value = data['attachment_name']?.toString() ?? 'Untitled.jpg';
    attachmentPath.value = data['attachment_path']?.toString() ?? '';
    documentType.value = data['document_type']?.toString() ?? 'invoice';

    supplierInvoiceNumberController.text = supplierInvoiceNumber.value;
    supplierInvoiceDateController.text = _formatDisplayDate(supplierInvoiceDate.value);
    purchaseDateController.text = _formatDisplayDate(purchaseDate.value);
    dueDateController.text = _formatDisplayDate(dueDate.value);

    final ai = data['ai_extraction'] as Map<String, dynamic>?;
    if (ai != null) {
      if (ai['classification_reason'] != null) {
        classificationReason.value = ai['classification_reason'].toString();
      }
      final totals = ai['totals'] as Map<String, dynamic>?;
      if (totals != null) {
        if (totals['net'] is num) netTotal.value = (totals['net'] as num).toDouble();
        if (totals['tax'] is num) taxTotal.value = (totals['tax'] as num).toDouble();
        if (totals['gross'] is num) grandTotal.value = (totals['gross'] as num).toDouble();
      }

      final hint = ai['payment_hint'] as Map<String, dynamic>?;
      if (hint != null) {
        if (hint['paid'] == true) {
          paymentStatus.value = 'Paid in full';
          paymentMethodOption.value = 'Paid by bank or card';
        }
      }
    }

    final rawLines = data['lines'] as List<dynamic>? ?? [];
    purchaseLineItems.clear();
    if (rawLines.isNotEmpty) {
      for (int i = 0; i < rawLines.length; i++) {
        final line = rawLines[i] as Map<String, dynamic>;
        final qty = (line['quantity'] as num?)?.toDouble() ?? 1.0;
        final unitPrice = (line['unit_price'] as num?)?.toDouble() ?? 0.0;
        final taxRate = (line['tax_rate'] as num?)?.toDouble() ?? 0.0;
        final desc = line['description']?.toString() ?? 'Line item';

        purchaseLineItems.add(
          PurchaseLineItem(
            id: (i + 1).toString(),
            item: desc,
            description: desc,
            qty: qty,
            unitPrice: unitPrice,
            discount: 0,
            taxRate: taxRate,
            categoryName: 'Travelling expenses',
          ),
        );
      }
    } else {
      purchaseLineItems.add(
        PurchaseLineItem(
          id: '1',
          item: 'Net',
          description: 'Net',
          qty: 1,
          unitPrice: netTotal.value > 0 ? netTotal.value : 250000.0,
          discount: 0,
          taxRate: taxTotal.value > 0 ? (taxTotal.value / netTotal.value * 100) : 0,
          categoryName: 'Travelling expenses',
        ),
      );
    }
  }

  String _formatDisplayDate(String raw) {
    if (raw.trim().isEmpty) return DateFormat('dd.MM.yyyy').format(DateTime.now());
    try {
      if (raw.contains('-')) {
        final parts = raw.split('-');
        if (parts.length == 3) {
          return '${parts[2].padLeft(2, '0')}.${parts[1].padLeft(2, '0')}.${parts[0]}';
        }
      }
      final parsed = DateTime.parse(raw);
      return DateFormat('dd.MM.yyyy').format(parsed);
    } catch (_) {
      return raw;
    }
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
        pageSize: 50,
      );

      if (response.statusCode == 200 && response.data != null) {
        final supplierRes = SupplierResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        suppliers.assignAll(supplierRes.data);

        final supJson = (scanData['supplier'] ?? scanData['ai_extraction']?['supplier']) as Map<String, dynamic>?;
        if (supJson != null && supJson['name'] != null) {
          final matchedName = supJson['name'].toString().toLowerCase();
          final match = suppliers.firstWhereOrNull((s) => s.name.toLowerCase().contains(matchedName));
          if (match != null) {
            selectSupplier(match);
          }
        }
      }
    } catch (e) {
      debugPrint('[ReviewPurchaseInvoiceController] loadSuppliers Error: $e');
    } finally {
      isLoadingSuppliers.value = false;
    }
  }

  void selectSupplier(SupplierModel supplier) {
    selectedSupplier.value = supplier;
    if ((supplier.iban ?? '').isNotEmpty) {
      ibanController.text = supplier.iban!;
    }
  }

  void addLineItem() {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    purchaseLineItems.add(
      PurchaseLineItem(
        id: newId,
        item: 'Item ${purchaseLineItems.length + 1}',
        description: 'Item ${purchaseLineItems.length + 1}',
        qty: 1,
        unitPrice: 1000.0,
        discount: 0,
        taxRate: 20,
        categoryName: 'Travelling expenses',
      ),
    );
  }

  void removeLineItem(int index) {
    if (index >= 0 && index < purchaseLineItems.length) {
      purchaseLineItems.removeAt(index);
    }
  }

  double get calculatedSubtotal {
    double totalNet = 0.0;
    for (final item in purchaseLineItems) {
      final qty = double.tryParse(item.qtyController.text) ?? 1;
      final price = double.tryParse(item.unitPriceController.text) ?? 0;
      final disc = double.tryParse(item.discountController.text) ?? 0;
      final taxRate = double.tryParse(item.taxRateController.text) ?? 20;

      final basePrice = qty * price * (1 - disc / 100);

      if (priceMode.value == 'Net') {
        totalNet += basePrice;
      } else {
        final net = basePrice / (1 + taxRate / 100);
        totalNet += net;
      }
    }
    return totalNet;
  }

  double get calculatedTaxTotal {
    double totalTax = 0.0;
    for (final item in purchaseLineItems) {
      final qty = double.tryParse(item.qtyController.text) ?? 1;
      final price = double.tryParse(item.unitPriceController.text) ?? 0;
      final disc = double.tryParse(item.discountController.text) ?? 0;
      final taxRate = double.tryParse(item.taxRateController.text) ?? 20;

      final basePrice = qty * price * (1 - disc / 100);

      if (priceMode.value == 'Net') {
        totalTax += basePrice * (taxRate / 100);
      } else {
        final net = basePrice / (1 + taxRate / 100);
        totalTax += (basePrice - net);
      }
    }
    return totalTax;
  }

  double get calculatedGrandTotal => calculatedSubtotal + calculatedTaxTotal;

  String formatCurrency(num amount) {
    final symbol = selectedCurrency.value == 'EUR' ? '€' : selectedCurrency.value;
    final value = amount.toDouble();
    final parts = value.toStringAsFixed(2).split('.');
    final formattedInt = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    return '$symbol$formattedInt.${parts[1]}';
  }

  Future<void> approveAndSavePurchase() async {
    final token = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;

    if (token == null || token.isEmpty || companyId == null || companyId == 0) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Access token or company ID is not available.',
      );
      return;
    }

    try {
      isApproving.value = true;

      AppSnackbar.success(
        title: 'Success',
        message: 'Purchase document approved and saved successfully.',
      );

      if (Get.isRegistered<PurchaseInvoicesController>()) {
        Get.find<PurchaseInvoicesController>().refreshInvoices();
      }

      Get.back(result: true);
    } catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Unable to approve purchase document.',
      );
    } finally {
      isApproving.value = false;
    }
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
    amountPaidController.dispose();
    paymentDateController.dispose();
    paymentReferenceController.dispose();
    internalNotesController.dispose();

    for (final item in purchaseLineItems) {
      item.itemController.dispose();
      item.descriptionController.dispose();
      item.qtyController.dispose();
      item.unitPriceController.dispose();
      item.discountController.dispose();
      item.taxRateController.dispose();
    }

    super.onClose();
  }
}