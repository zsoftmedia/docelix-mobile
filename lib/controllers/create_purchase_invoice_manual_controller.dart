import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/catalog_model.dart';
import 'package:docelix_mobileapp/models/supplier_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PurchaseLineItem {
  final String id;
  TextEditingController itemController;
  TextEditingController descriptionController;
  TextEditingController qtyController;
  TextEditingController unitPriceController;
  TextEditingController discountController;
  TextEditingController taxRateController;
  RxString category;

  PurchaseLineItem({
    required this.id,
    required String item,
    required String description,
    required double qty,
    required double unitPrice,
    double discount = 0,
    double taxRate = 20,
    String categoryName = 'Travelling expenses',
  })  : itemController = TextEditingController(text: item),
        descriptionController = TextEditingController(text: description),
        qtyController = TextEditingController(text: qty.toStringAsFixed(0)),
        unitPriceController = TextEditingController(text: unitPrice.toStringAsFixed(0)),
        discountController = TextEditingController(text: discount.toStringAsFixed(0)),
        taxRateController = TextEditingController(text: taxRate.toStringAsFixed(0)),
        category = categoryName.obs;
}

class SupplierInvoiceModel {
  final int id;
  final String purchaseNumber;
  final String supplierInvoiceNumber;
  final String purchaseDate;
  final double total;
  final String currency;
  final String status;

  SupplierInvoiceModel({
    required this.id,
    required this.purchaseNumber,
    required this.supplierInvoiceNumber,
    required this.purchaseDate,
    required this.total,
    required this.currency,
    required this.status,
  });

  factory SupplierInvoiceModel.fromJson(Map<String, dynamic> json) {
    return SupplierInvoiceModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      purchaseNumber: json['purchase_number']?.toString() ?? json['purchase_no']?.toString() ?? '',
      supplierInvoiceNumber: json['supplier_invoice_number']?.toString() ?? json['invoice_number']?.toString() ?? '',
      purchaseDate: json['purchase_date']?.toString() ?? json['invoice_date']?.toString() ?? '',
      total: (json['total'] as num?)?.toDouble() ?? (json['total_amount'] as num?)?.toDouble() ?? (json['gross_amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? json['currency_code']?.toString() ?? 'EUR',
      status: json['status']?.toString() ?? '',
    );
  }

  String get displayText {
    final formattedTotal = total.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    final currSymbol = (currency == 'EUR' || currency.isEmpty) ? '€' : currency;

    final String suppInv = supplierInvoiceNumber.trim();
    final String purNo = purchaseNumber.trim();

    if (suppInv.isNotEmpty && purNo.isNotEmpty) {
      return '$suppInv - $purNo --- $currSymbol $formattedTotal';
    } else if (suppInv.isNotEmpty) {
      return '$suppInv --- $currSymbol $formattedTotal';
    } else if (purNo.isNotEmpty) {
      return '$purNo --- $currSymbol $formattedTotal';
    }
    return 'Invoice #$id --- $currSymbol $formattedTotal';
  }
}

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
  // RECEIPT TAB STEPPER
  // ============================================================

  final RxInt currentReceiptStep = 0.obs;
  final int totalReceiptSteps = 4;

  static const receiptSteps = <String>[
    'Supplier details',
    'Purchased items / services',
    'Payment details',
    'Internal notes',
  ];

  void goToReceiptStep(int step) {
    if (step <= currentReceiptStep.value) {
      currentReceiptStep.value = step;
    }
  }

  void nextReceiptStep() {
    if (currentReceiptStep.value < totalReceiptSteps - 1) {
      currentReceiptStep.value++;
    } else {
      submitPurchaseInvoice();
    }
  }

  void previousReceiptStep() {
    if (currentReceiptStep.value > 0) {
      currentReceiptStep.value--;
    }
  }

  // ============================================================
  // CREDIT NOTE TAB STEPPER
  // ============================================================

  final RxInt currentCreditNoteStep = 0.obs;
  final int totalCreditNoteSteps = 4;

  static const creditNoteSteps = <String>[
    'Supplier details',
    'Purchased items / services',
    'Payment details',
    'Internal notes',
  ];

  void goToCreditNoteStep(int step) {
    if (step <= currentCreditNoteStep.value) {
      currentCreditNoteStep.value = step;
    }
  }

  void nextCreditNoteStep() {
    if (currentCreditNoteStep.value < totalCreditNoteSteps - 1) {
      currentCreditNoteStep.value++;
    } else {
      submitPurchaseInvoice();
    }
  }

  void previousCreditNoteStep() {
    if (currentCreditNoteStep.value > 0) {
      currentCreditNoteStep.value--;
    }
  }

  void nextStep() {
    if (selectedTabIndex.value == 0) {
      if (currentInvoiceStep.value < totalInvoiceSteps - 1) {
        currentInvoiceStep.value++;
      } else {
        submitPurchaseInvoice();
      }
    } else if (selectedTabIndex.value == 1) {
      if (currentReceiptStep.value < totalReceiptSteps - 1) {
        currentReceiptStep.value++;
      } else {
        submitPurchaseInvoice();
      }
    }
  }

  void previousStep() {
    if (selectedTabIndex.value == 0) {
      if (currentInvoiceStep.value > 0) {
        currentInvoiceStep.value--;
      }
    } else if (selectedTabIndex.value == 1) {
      if (currentReceiptStep.value > 0) {
        currentReceiptStep.value--;
      }
    }
  }

  void goToStep(int step) {
    if (selectedTabIndex.value == 0) {
      if (step <= currentInvoiceStep.value) {
        currentInvoiceStep.value = step;
      }
    } else if (selectedTabIndex.value == 1) {
      if (step <= currentReceiptStep.value) {
        currentReceiptStep.value = step;
      }
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

  // ============================================================
  // STEP 2: PURCHASED ITEMS / SERVICES FIELDS & CALCULATIONS
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

    // Recalculate prices for existing items when switching Net <-> Gross
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
    final defaultPrice = priceMode.value == 'Net' ? 1000.0 : 1200.0;

    purchaseLineItems.add(
      PurchaseLineItem(
        id: newId,
        item: 'Item ${purchaseLineItems.length + 1}',
        description: 'Item ${purchaseLineItems.length + 1}',
        qty: 1,
        unitPrice: defaultPrice,
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

  String getCurrencySymbol(String? code) {
    final raw = (code ?? selectedCurrency.value).trim().toUpperCase();
    switch (raw) {
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      case 'PKR':
        return 'Rs.';
      default:
        return raw;
    }
  }

  String formatCurrency(num amount) {
    final symbol = getCurrencySymbol(selectedCurrency.value);
    final value = amount.toDouble();
    final parts = value.toStringAsFixed(2).split('.');
    final formattedInt = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    return '$symbol$formattedInt.${parts[1]}';
  }

  // ============================================================
  // CATALOG ITEMS SEARCH & FETCHING
  // ============================================================

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
      debugPrint('[CreatePurchaseInvoiceManualController] loadCatalogItems Error: $e');
    } finally {
      isLoadingCatalog.value = false;
    }
  }

  void selectCatalogItemForLine(int lineIndex, CatalogModel catalog) {
    if (lineIndex < 0 || lineIndex >= purchaseLineItems.length) return;

    final item = purchaseLineItems[lineIndex];
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

  // ============================================================
  // STEP 3: PAYMENT DETAILS & SUPPORTING DOCUMENT
  // ============================================================

  final RxString paymentStatus = 'Paid in full'.obs;
  static const paymentStatusOptions = <String>[
    'Unpaid',
    'Partially paid',
    'Paid in full',
  ];

  final RxString paidFrom = 'Choose bank or cash'.obs;
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
      debugPrint('[CreatePurchaseInvoiceManualController] pickSupportingDocument Error: $e');
      AppSnackbar.error(
        title: 'File Selection Error',
        message: 'Unable to select file from storage.',
      );
    }
  }

  void removeSupportingDocument() {
    attachedDocumentName.value = null;
    attachedDocumentPath.value = null;
  }

  // ============================================================
  // STEP 4: INTERNAL NOTES
  // ============================================================

  final internalNotesController = TextEditingController();
  final RxBool isSubmittingInvoice = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSuppliers();
    loadCatalogItems();
    purchaseLineItems.clear();
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
        pageSize: 20,
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

    // 3. Fetch supplier invoices for Credit Note tab
    fetchSupplierInvoices(supplier.id);
  }

  // ============================================================
  // CREDIT NOTE: CORRECTS INVOICE DROPDOWN & API
  // ============================================================

  final creditNoteNumberController = TextEditingController();
  final RxList<SupplierInvoiceModel> supplierInvoices = <SupplierInvoiceModel>[].obs;
  final Rxn<SupplierInvoiceModel> selectedCorrectsInvoice = Rxn<SupplierInvoiceModel>();
  final RxBool isLoadingSupplierInvoices = false.obs;
  final RxString correctsInvoiceSearchQuery = ''.obs;

  List<SupplierInvoiceModel> get filteredSupplierInvoices {
    final query = correctsInvoiceSearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return supplierInvoices;
    return supplierInvoices.where((inv) {
      final disp = inv.displayText.toLowerCase();
      return disp.contains(query);
    }).toList();
  }

  Future<void> fetchSupplierInvoices(int supplierId) async {
    final token = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;
    if (token == null || token.isEmpty) return;

    try {
      isLoadingSupplierInvoices.value = true;

      final response = await _dioClient.getSupplierInvoices(
        supplierId: supplierId,
        accessToken: token,
        companyId: companyId,
      );

      debugPrint('[CreatePurchaseInvoiceManualController] fetchSupplierInvoices status: ${response.statusCode}');
      debugPrint('[CreatePurchaseInvoiceManualController] fetchSupplierInvoices data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> rawItems = [];

        if (response.data is Map) {
          final Map<String, dynamic> body = Map<String, dynamic>.from(response.data as Map);
          rawItems = (body['items'] as List<dynamic>?) ?? (body['data'] as List<dynamic>?) ?? (body['invoices'] as List<dynamic>?) ?? [];
        } else if (response.data is List) {
          rawItems = response.data as List<dynamic>;
        }

        final parsed = rawItems
            .whereType<Map>()
            .map((json) => SupplierInvoiceModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        supplierInvoices.assignAll(parsed);
      }
    } catch (e) {
      debugPrint('[CreatePurchaseInvoiceManualController] fetchSupplierInvoices Error: $e');
    } finally {
      isLoadingSupplierInvoices.value = false;
    }
  }

  void selectCorrectsInvoice(SupplierInvoiceModel invoice) {
    selectedCorrectsInvoice.value = invoice;
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