import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/create_purchase_invoice_manual_controller.dart';
import 'package:docelix_mobileapp/controllers/purchase_invoices_controller.dart';
import 'package:docelix_mobileapp/models/catalog_model.dart';
import 'package:docelix_mobileapp/models/supplier_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:file_picker/file_picker.dart';
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
      approveAndPostPurchase();
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

  // Payment Selection in Review Tab
  final RxString paymentMethodOption = 'Paid by bank or card'.obs;
  final RxBool isDocumentInvoiceChecked = true.obs;
  final RxBool isCheckedAccountLinesChecked = false.obs;

  // ============================================================
  // STEP 2: SUPPLIER DETAILS FIELDS & CONTROLLERS
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
  final supplierInvoiceDateController = TextEditingController();
  final purchaseDateController = TextEditingController();
  final dueDateController = TextEditingController();
  final ibanController = TextEditingController();
  final deliveryNoteController = TextEditingController();
  final orderReferenceController = TextEditingController();
  final serviceFromDateController = TextEditingController();
  final serviceToDateController = TextEditingController();

  // CURRENCY & SEARCH
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

  // ============================================================
  // STEP 3: PURCHASED ITEMS / SERVICES FIELDS & CALCULATIONS
  // ============================================================

  final RxString priceMode = 'Net'.obs; // 'Net' or 'Gross'
  final RxBool showAccountCodes = false.obs;

  final RxList<PurchaseLineItem> purchaseLineItems = <PurchaseLineItem>[].obs;

  static const purchaseCategoryOptions = <String>[
    'Travelling expenses',
    'Operating Expenses',
    'Office Supplies',
    'Software Subscriptions',
    'Vehicle Leasing',
    'Fuel Expense',
    'Professional Fees',
  ];

  void setPriceMode(String mode) {
    if (priceMode.value == mode) return;

    final oldMode = priceMode.value;
    priceMode.value = mode;

    for (final item in purchaseLineItems) {
      final currentPrice = double.tryParse(item.unitPriceController.text) ?? 0;
      final taxRate = double.tryParse(item.taxRateController.text) ?? 20;

      if (oldMode == 'Net' && mode == 'Gross') {
        final grossPrice = currentPrice * (1 + taxRate / 100);
        item.unitPriceController.text = grossPrice.toStringAsFixed(0);
      } else if (oldMode == 'Gross' && mode == 'Net') {
        final netPrice = currentPrice / (1 + taxRate / 100);
        item.unitPriceController.text = netPrice.toStringAsFixed(0);
      }
    }
    purchaseLineItems.refresh();
  }

  void addLineItem() {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    purchaseLineItems.add(
      PurchaseLineItem(
        id: newId,
        item: 'Item ${purchaseLineItems.length + 1}',
        description: 'Item ${purchaseLineItems.length + 1}',
        qty: 1,
        unitPrice: priceMode.value == 'Net' ? 1000.0 : 1200.0,
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

  // CATALOG ITEMS SEARCH & FETCHING
  final RxList<CatalogModel> catalogItems = <CatalogModel>[].obs;
  final RxBool isLoadingCatalog = false.obs;
  final RxString catalogSearchQuery = ''.obs;

  List<CatalogModel> get filteredCatalogItems {
    final query = catalogSearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return catalogItems;
    return catalogItems.where((item) {
      final name = (item.articleName ?? '').toLowerCase();
      final code = (item.articleNumber ?? '').toLowerCase();
      final group = (item.groupCode ?? '').toLowerCase();
      return name.contains(query) || code.contains(query) || group.contains(query);
    }).toList();
  }

  Future<void> loadCatalogItems() async {
    final token = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;

    if (token == null || token.isEmpty || companyId == null || companyId == 0) {
      return;
    }

    try {
      isLoadingCatalog.value = true;
      final response = await _dioClient.getCatalog(
        companyId: companyId,
        accessToken: token,
        page: 1,
        pageSize: 50,
        sort: 'article_name',
        dir: 'asc',
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> dataList = [];
        if (response.data is Map) {
          dataList = (response.data as Map)['data'] as List<dynamic>? ?? [];
        } else if (response.data is List) {
          dataList = response.data as List<dynamic>;
        }

        final parsed = dataList
            .whereType<Map>()
            .map((json) => CatalogModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        catalogItems.assignAll(parsed);
      }
    } catch (e) {
      debugPrint('[ReviewPurchaseInvoiceController] loadCatalogItems Error: $e');
    } finally {
      isLoadingCatalog.value = false;
    }
  }

  void selectCatalogItemForLine(int lineIndex, CatalogModel catalog) {
    if (lineIndex < 0 || lineIndex >= purchaseLineItems.length) return;

    final item = purchaseLineItems[lineIndex];
    item.catalogId = catalog.id;
    item.itemController.text = catalog.articleName ?? '';
    item.descriptionController.text = catalog.articleName ?? '';

    final double priceNet = (catalog.unitPriceNet ?? catalog.purchasePriceNet ?? 0.0).toDouble();
    final double vatRate = (catalog.vatRate ?? 20.0).toDouble();

    if (priceMode.value == 'Gross') {
      final grossPrice = priceNet * (1 + vatRate / 100);
      item.unitPriceController.text = grossPrice.toStringAsFixed(0);
    } else {
      item.unitPriceController.text = priceNet.toStringAsFixed(0);
    }

    item.taxRateController.text = vatRate.toStringAsFixed(0);

    if ((catalog.groupCode ?? '').isNotEmpty) {
      final matchingCat = purchaseCategoryOptions.firstWhereOrNull(
        (c) => c.toLowerCase() == catalog.groupCode!.toLowerCase(),
      );
      if (matchingCat != null) {
        item.category.value = matchingCat;
      }
    }

    purchaseLineItems.refresh();
  }

  // CALCULATED TOTALS
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
  double get amountPaid => 0.0;
  double get outstandingBalance => calculatedGrandTotal - amountPaid;

  // ============================================================
  // STEP 5: PAYMENT DETAILS & SUPPORTING DOCUMENT
  // ============================================================

  final RxString paymentStatus = 'Paid in full'.obs;
  static const paymentStatusOptions = <String>[
    'Unpaid',
    'Partially paid',
    'Paid in full',
  ];

  final RxString paidFrom = 'Bank'.obs;
  static const paidFromOptions = <String>[
    'Bank',
    'Cash',
  ];

  final amountPaidController = TextEditingController();
  final paymentDateController = TextEditingController(
    text: DateFormat('dd.MM.yyyy').format(DateTime.now()),
  );
  final paymentReferenceController = TextEditingController();

  final RxnString attachedDocumentName = RxnString();
  final RxnString attachedDocumentPath = RxnString();

  void setPaymentStatus(String status) {
    paymentStatus.value = status;
  }

  void setPaidFrom(String option) {
    paidFrom.value = option;
  }

  Future<void> pickSupportingDocument() async {
    try {
      final List<PlatformFile> result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result.isNotEmpty) {
        final file = result.first;
        attachedDocumentName.value = file.name;
        attachedDocumentPath.value = file.path;
        AppSnackbar.success(
          title: 'Document Attached',
          message: 'Selected: ${file.name}',
        );
      }
    } catch (e) {
      debugPrint('[ReviewPurchaseInvoiceController] pickSupportingDocument Error: $e');
    }
  }

  void removeSupportingDocument() {
    attachedDocumentName.value = null;
    attachedDocumentPath.value = null;
  }

  // ============================================================
  // STEP 6: INTERNAL NOTES & SUBMISSION CONTROLLERS
  // ============================================================

  final internalNotesController = TextEditingController();
  final RxBool isApproving = false.obs;
  final RxBool isSavingDraft = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      scanData.value = Map<String, dynamic>.from(args);
      _parseScanData();
    }
    loadSuppliers();
    loadCatalogItems();
  }

  void resetForm() {
    purchaseId.value = 0;
    purchaseNumber.value = '';
    supplierInvoiceNumber.value = '';
    supplierInvoiceDate.value = '';
    purchaseDate.value = '';
    dueDate.value = '';
    selectedCurrency.value = 'EUR';
    netTotal.value = 0.0;
    taxTotal.value = 0.0;
    grandTotal.value = 0.0;
    attachmentName.value = '';
    attachmentPath.value = '';
    documentType.value = 'invoice';
    classificationReason.value = 'Goods for resale';

    selectedSupplier.value = null;
    supplierSearchQuery.value = '';

    supplierInvoiceNumberController.clear();
    hasNoDocumentNumber.value = false;
    referenceController.clear();
    supplierInvoiceDateController.clear();
    purchaseDateController.clear();
    dueDateController.clear();
    ibanController.clear();
    deliveryNoteController.clear();
    orderReferenceController.clear();
    serviceFromDateController.clear();
    serviceToDateController.clear();

    priceMode.value = 'Net';
    showAccountCodes.value = false;
    purchaseLineItems.clear();

    paymentStatus.value = 'Paid in full';
    paidFrom.value = 'Bank';
    amountPaidController.clear();
    paymentDateController.clear();
    paymentReferenceController.clear();

    internalNotesController.clear();
    currentStep.value = 0;
  }

  void _parseScanData() {
    final Map<String, dynamic> data = scanData;
    purchaseId.value = (data['id'] as num?)?.toInt() ?? 0;
    purchaseNumber.value = data['purchase_number']?.toString() ?? 'PUR-2026-0025';
    supplierInvoiceNumber.value = data['supplier_invoice_number']?.toString() ?? '';
    supplierInvoiceDate.value = data['supplier_invoice_date']?.toString() ?? '';
    purchaseDate.value = data['purchase_date']?.toString() ?? '';
    dueDate.value = data['due_date']?.toString() ?? '';
    selectedCurrency.value = (data['currency']?.toString() ?? 'EUR').toUpperCase();

    netTotal.value = (data['subtotal'] as num?)?.toDouble() ?? 0.0;
    taxTotal.value = (data['tax_total'] as num?)?.toDouble() ?? 0.0;
    grandTotal.value = (data['total'] as num?)?.toDouble() ?? 0.0;

    attachmentName.value = data['attachment_name']?.toString() ?? 'Untitled.jpg';
    attachmentPath.value = data['attachment_path']?.toString() ?? '';
    documentType.value = data['document_type']?.toString() ?? 'invoice';

    supplierInvoiceNumberController.text = supplierInvoiceNumber.value;
    referenceController.text = data['reference']?.toString() ?? '';
    supplierInvoiceDateController.text = _formatDisplayDate(supplierInvoiceDate.value);
    purchaseDateController.text = _formatDisplayDate(purchaseDate.value);
    dueDateController.text = _formatDisplayDate(dueDate.value);

    ibanController.text = data['payee_iban']?.toString() ?? '';
    deliveryNoteController.text = data['delivery_reference']?.toString() ?? '';
    orderReferenceController.text = data['order_reference']?.toString() ?? '';
    serviceFromDateController.text = _formatDisplayDate(data['service_period_start']?.toString() ?? '');
    serviceToDateController.text = _formatDisplayDate(data['service_period_end']?.toString() ?? '');

    hasNoDocumentNumber.value = (data['no_invoice_number'] as bool?) ?? false;
    priceMode.value = (data['price_mode']?.toString().toLowerCase() == 'gross') ? 'Gross' : 'Net';

    internalNotesController.text = data['notes']?.toString() ?? '';

    final paymentMethod = data['payment_method']?.toString().toLowerCase() ?? '';
    if (paymentMethod == 'cash') {
      paidFrom.value = 'Cash';
    } else {
      paidFrom.value = 'Bank';
    }

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
        final unitPrice = (line['unit_price'] as num?)?.toDouble() ?? (line['net_amount'] as num?)?.toDouble() ?? 0.0;
        final taxRate = (line['tax_rate'] as num?)?.toDouble() ?? 0.0;
        final desc = line['description']?.toString() ?? 'Line item';
        final int? itemId = (line['item_id'] as num?)?.toInt();

        purchaseLineItems.add(
          PurchaseLineItem(
            id: (i + 1).toString(),
            catalogId: itemId,
            item: desc,
            description: desc,
            qty: qty,
            unitPrice: unitPrice,
            discount: (line['discount_percent'] as num?)?.toDouble() ?? 0.0,
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

  String? _formatNullableIsoDate(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    try {
      if (trimmed.contains('.')) {
        final parts = trimmed.split('.');
        if (parts.length == 3) {
          final day = parts[0].padLeft(2, '0');
          final month = parts[1].padLeft(2, '0');
          final year = parts[2];
          return '$year-$month-$day';
        }
      }
      final parsed = DateTime.parse(trimmed);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (_) {
      return null;
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

  void selectCurrency(String currency) {
    selectedCurrency.value = currency;
    currencySearchQuery.value = '';
  }

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

  // ============================================================
  // SAVE DRAFT METHOD (PUT /api/purchases/{id})
  // ============================================================
  Future<void> saveDraft() async {
    final token = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;

    if (token == null || token.isEmpty || companyId == null || companyId == 0) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Access token or company ID is not available.',
      );
      return;
    }

    final id = purchaseId.value;
    if (id <= 0) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Invalid purchase document ID.',
      );
      return;
    }

    try {
      isSavingDraft.value = true;

      final linesPayload = purchaseLineItems.map((item) {
        final qtyStr = item.qtyController.text.trim();
        final priceStr = item.unitPriceController.text.trim();
        final taxStr = item.taxRateController.text.trim();
        final desc = item.descriptionController.text.trim().isNotEmpty
            ? item.descriptionController.text.trim()
            : (item.itemController.text.trim().isNotEmpty
                ? item.itemController.text.trim()
                : 'Describe product or service');

        final double qtyNum = double.tryParse(qtyStr) ?? 1.0;
        final double priceNum = double.tryParse(priceStr) ?? 0.0;
        final double taxNum = double.tryParse(taxStr) ?? 0.0;

        final map = <String, dynamic>{
          'description': desc,
          'quantity': qtyNum == qtyNum.toInt() ? qtyNum.toInt() : qtyNum,
          'unit_price': priceNum == priceNum.toInt() ? priceNum.toInt() : priceNum,
          'tax_rate': taxNum == taxNum.toInt() ? taxNum.toInt() : taxNum,
          'account_id': 1380,
        };
        if (item.catalogId != null && item.catalogId! > 0) {
          map['item_id'] = item.catalogId;
        }
        return map;
      }).toList();

      final Map<String, dynamic> payload = {
        'credited_purchase_id': null,
        'currency': selectedCurrency.value.toUpperCase().isNotEmpty
            ? selectedCurrency.value.toUpperCase()
            : 'EUR',
        'delivery_reference': deliveryNoteController.text.trim(),
        'document_type': documentType.value.isNotEmpty ? documentType.value : 'invoice',
        'due_date': _formatNullableIsoDate(dueDateController.text),
        'fx_rate': null,
        'lines': linesPayload,
        'no_invoice_number': hasNoDocumentNumber.value,
        'notes': internalNotesController.text.trim(),
        'order_reference': orderReferenceController.text.trim(),
        'payee_iban': ibanController.text.trim().isNotEmpty
            ? ibanController.text.trim()
            : (selectedSupplier.value?.iban ?? ''),
        'payment_method': paidFrom.value.toLowerCase() == 'cash'
            ? 'cash'
            : (paidFrom.value.toLowerCase() == 'bank' ? 'bank' : null),
        'price_mode': priceMode.value.toLowerCase(),
        'purchase_date': _formatNullableIsoDate(purchaseDateController.text),
        'purchase_type': 'expense',
        'reference': referenceController.text.trim(),
        'service_period_end': _formatNullableIsoDate(serviceToDateController.text),
        'service_period_start': _formatNullableIsoDate(serviceFromDateController.text),
        'settle_amount': null,
        'settle_date': null,
        'settle_on_post': false,
        'settle_reference': '',
        'supplier_id': selectedSupplier.value?.id,
        'supplier_invoice_date': _formatNullableIsoDate(supplierInvoiceDateController.text),
        'supplier_invoice_number': supplierInvoiceNumberController.text.trim(),
      };

      final response = await _dioClient.updatePurchase(
        purchaseId: id,
        body: payload,
        companyId: companyId,
        accessToken: token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppSnackbar.success(
          title: 'Success',
          message: 'Purchase draft saved successfully.',
        );

        if (Get.isRegistered<PurchaseInvoicesController>()) {
          Get.find<PurchaseInvoicesController>().refreshInvoices();
        }

        resetForm();
        Get.back(result: true);
      } else {
        AppSnackbar.error(
          title: 'Error',
          message: 'Failed to save draft.',
        );
      }
    } on DioException catch (e) {
      debugPrint('[ReviewPurchaseInvoiceController] saveDraft DioError: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage = 'Failed to save draft.';
      if (e.response?.data is Map) {
        final resMap = e.response!.data as Map;
        errorMessage = resMap['message']?.toString() ??
            resMap['error']?.toString() ??
            resMap['detail']?.toString() ??
            errorMessage;
      } else if (e.response?.data is String) {
        errorMessage = e.response!.data.toString();
      }

      AppSnackbar.error(
        title: e.response?.statusCode == 409 ? 'Duplicate / Conflict' : 'Error',
        message: errorMessage,
      );
    } catch (e) {
      debugPrint('[ReviewPurchaseInvoiceController] saveDraft Error: $e');
      AppSnackbar.error(
        title: 'Error',
        message: 'Unable to save draft: $e',
      );
    } finally {
      isSavingDraft.value = false;
    }
  }

  // ============================================================
  // APPROVE & POST METHOD
  // ============================================================
  Future<void> approveAndPostPurchase() async {
    final token = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;

    if (token == null || token.isEmpty || companyId == null || companyId == 0) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Access token or company ID is not available.',
      );
      return;
    }

    if (selectedSupplier.value == null) {
      goToStep(1);
      AppSnackbar.error(
        title: 'Validation Error',
        message: 'Please select a supplier.',
      );
      return;
    }

    if (purchaseLineItems.isEmpty) {
      goToStep(2);
      AppSnackbar.error(
        title: 'Validation Error',
        message: 'Please add at least one line item or service.',
      );
      return;
    }

    try {
      isApproving.value = true;

      final linesPayload = purchaseLineItems.map((item) {
        final qtyStr = item.qtyController.text.trim();
        final priceStr = item.unitPriceController.text.trim();
        final taxStr = item.taxRateController.text.trim();
        final desc = item.descriptionController.text.trim().isNotEmpty
            ? item.descriptionController.text.trim()
            : (item.itemController.text.trim().isNotEmpty
                ? item.itemController.text.trim()
                : 'Describe product or service');

        final double qtyNum = double.tryParse(qtyStr) ?? 1.0;
        final double priceNum = double.tryParse(priceStr) ?? 0.0;
        final double taxNum = double.tryParse(taxStr) ?? 0.0;

        final map = <String, dynamic>{
          'description': desc,
          'quantity': qtyNum == qtyNum.toInt() ? qtyNum.toInt() : qtyNum,
          'unit_price': priceNum == priceNum.toInt() ? priceNum.toInt() : priceNum,
          'tax_rate': taxNum == taxNum.toInt() ? taxNum.toInt() : taxNum,
          'account_id': 1380,
        };
        if (item.catalogId != null && item.catalogId! > 0) {
          map['item_id'] = item.catalogId;
        }
        return map;
      }).toList();

      final Map<String, dynamic> payload = {
        'credited_purchase_id': null,
        'currency': selectedCurrency.value.toUpperCase().isNotEmpty
            ? selectedCurrency.value.toUpperCase()
            : 'EUR',
        'delivery_reference': deliveryNoteController.text.trim(),
        'document_type': documentType.value.isNotEmpty ? documentType.value : 'invoice',
        'due_date': _formatNullableIsoDate(dueDateController.text),
        'fx_rate': null,
        'lines': linesPayload,
        'no_invoice_number': hasNoDocumentNumber.value,
        'notes': internalNotesController.text.trim(),
        'order_reference': orderReferenceController.text.trim(),
        'payee_iban': ibanController.text.trim().isNotEmpty
            ? ibanController.text.trim()
            : (selectedSupplier.value?.iban ?? ''),
        'payment_method': paidFrom.value.toLowerCase() == 'cash'
            ? 'cash'
            : (paidFrom.value.toLowerCase() == 'bank' ? 'bank' : null),
        'price_mode': priceMode.value.toLowerCase(),
        'purchase_date': _formatNullableIsoDate(purchaseDateController.text),
        'purchase_type': 'expense',
        'reference': referenceController.text.trim(),
        'service_period_end': _formatNullableIsoDate(serviceToDateController.text),
        'service_period_start': _formatNullableIsoDate(serviceFromDateController.text),
        'settle_amount': paymentStatus.value == 'Paid in full'
            ? calculatedGrandTotal
            : double.tryParse(amountPaidController.text.trim()),
        'settle_date': paymentDateController.text.trim().isNotEmpty
            ? _formatNullableIsoDate(paymentDateController.text)
            : null,
        'settle_on_post': paymentStatus.value == 'Paid in full',
        'settle_reference': paymentReferenceController.text.trim(),
        'status': 'posted',
        'supplier_id': selectedSupplier.value?.id,
        'supplier_invoice_date': _formatNullableIsoDate(supplierInvoiceDateController.text),
        'supplier_invoice_number': supplierInvoiceNumberController.text.trim(),
      };

      final id = purchaseId.value;
      dynamic response;
      if (id > 0) {
        response = await _dioClient.updatePurchase(
          purchaseId: id,
          body: payload,
          companyId: companyId,
          accessToken: token,
        );
      } else {
        response = await _dioClient.createPurchase(
          body: payload,
          companyId: companyId,
          accessToken: token,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppSnackbar.success(
          title: 'Success',
          message: 'Purchase document approved and posted successfully.',
        );

        if (Get.isRegistered<PurchaseInvoicesController>()) {
          Get.find<PurchaseInvoicesController>().refreshInvoices();
        }

        resetForm();
        Get.back(result: true);
      } else {
        AppSnackbar.error(
          title: 'Error',
          message: 'Failed to approve and post purchase document.',
        );
      }
    } on DioException catch (e) {
      debugPrint('[ReviewPurchaseInvoiceController] approve DioError: ${e.response?.statusCode} - ${e.response?.data}');
      String errorMessage = 'Failed to approve purchase document.';
      if (e.response?.data is Map) {
        final resMap = e.response!.data as Map;
        errorMessage = resMap['message']?.toString() ??
            resMap['error']?.toString() ??
            resMap['detail']?.toString() ??
            errorMessage;
      } else if (e.response?.data is String) {
        errorMessage = e.response!.data.toString();
      }

      AppSnackbar.error(
        title: e.response?.statusCode == 409 ? 'Duplicate / Conflict' : 'Error',
        message: errorMessage,
      );
    } catch (e) {
      debugPrint('[ReviewPurchaseInvoiceController] approve Error: $e');
      AppSnackbar.error(
        title: 'Error',
        message: 'Unable to approve purchase document: $e',
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