import 'dart:math';

import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/catalog_model.dart';
import 'package:docelix_mobileapp/models/clients_screen_model.dart';
import 'package:docelix_mobileapp/models/company_model.dart';
import 'package:docelix_mobileapp/models/unit_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateInvoiceController extends GetxController {

  final DioClient dioClient = DioClient();
  final RxString sessionEmail = ''.obs;
  final RxString errorMessage = ''.obs;
  // Companies
  final RxList<CompanyModel> companies = <CompanyModel>[].obs;
  final RxList<String> companyNames = <String>[].obs;
  final Rxn<CompanyModel> selectedCompany = Rxn<CompanyModel>();

  // ============================================================
  // UNITS
  // ============================================================
  final RxList<UnitModel> units = <UnitModel>[].obs;
  final RxList<String> unitNames = <String>[].obs;
  final Rxn<UnitModel> selectedUnit = Rxn<UnitModel>();
  final RxString unitSearchQuery = ''.obs;

  final List<String> unitOptions = const [
    'Ad set (adset)',
    'Piece (pc)',
    'Hour (h)',
    'Day (day)',
    'Month (month)',
    'Kilogram (kg)',
    'Gram (g)',
    'Liter (l)',
    'Meter (m)',
    'Square meter (m²)',
    'Cubic meter (m³)',
    'Package (pkg)',
    'Box (box)',
    'Set (set)',
    'Service (service)',
  ];

  List<String> get availableUnits {
    if (unitNames.isNotEmpty) return unitNames;
    return unitOptions;
  }

  String? get currentSelectedUnitLabel {
    return selectedUnit.value?.label ??
        (unitController.text.isNotEmpty ? unitController.text : null);
  }

  void updateUnitSearchQuery(String query) {
    unitSearchQuery.value = query;
  }

  List<String> get filteredUnits {
    final query = unitSearchQuery.value.trim().toLowerCase();
    final listToFilter = availableUnits;

    if (query.isEmpty) return listToFilter;

    return listToFilter
        .where((unit) => unit.toLowerCase().contains(query))
        .toList();
  }

  // ============================================================
  // CATALOG LIST
  // ============================================================

  final RxList<CatalogModel> catalogList = <CatalogModel>[].obs;
  final RxList<String> catalogNames = <String>[].obs;
  final Rxn<CatalogModel> selectedCatalogItem = Rxn<CatalogModel>();

  // ============================================================
  // GENERAL
  // ============================================================
  final isLoading = false.obs;

  // ============================================================
  // CLIENT LIST
  // ============================================================
  final RxList<ClientScreenModel> clients = <ClientScreenModel>[].obs;

  /// Names shown inside dropdown
  final RxList<String> clientNames = <String>[].obs;

  /// Selected client name
  final RxnString selectedClientName = RxnString();

  /// Complete selected client object
  final Rxn<ClientScreenModel> selectedClient = Rxn<ClientScreenModel>();

  /// Search query for client bottom sheet
  final RxString clientSearchQuery = ''.obs;

  void updateClientSearchQuery(String query) {
    clientSearchQuery.value = query;
  }

  List<ClientScreenModel> get filteredClients {
    final query = clientSearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return clients;

    return clients.where((client) {
      final name = client.name.toLowerCase();
      final email = client.email?.toLowerCase() ?? '';
      final phone = client.phone?.toLowerCase() ?? '';
      final city = client.city?.toLowerCase() ?? '';
      final vatId = client.vatId?.toLowerCase() ?? '';

      return name.contains(query) ||
          email.contains(query) ||
          phone.contains(query) ||
          city.contains(query) ||
          vatId.contains(query);
    }).toList();
  }

  void selectClientByModel(ClientScreenModel client) {
    selectedClient.value = client;
    selectedClientName.value = '${client.name.trim()} - ${client.id}';

    _setClientField(customerController, client.name);
    _setClientField(addressController, client.addressLine1);
    _setClientField(zipController, client.postalCode);
    _setClientField(cityController, client.city);
    _setClientField(attnController, client.contactName);
    _setClientField(emailController, client.email);
    _setClientField(phoneController, client.phone);
  }

  // ============================================================
  // PAGINATION
  // ============================================================

  final RxInt currentPage = 1.obs;
  final RxInt pageSize = 10.obs;

  // ============================================================
  // STEPPER
  // ============================================================

  final currentStep = 0.obs;
  final int totalSteps = 4;

  // ============================================================
  // CLIENT TEXT CONTROLLERS
  // ============================================================

  final customerController = TextEditingController();
  final addressController = TextEditingController();
  final zipController = TextEditingController();
  final cityController = TextEditingController();
  final attnController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // ============================================================
  // INVOICE
  // ============================================================

  final invoiceNumberController = TextEditingController();

  final invoiceDateController = TextEditingController();

  final vatRateController = TextEditingController(text: '0');

  final autoGenerate = true.obs;

  final enableVat = false.obs;

  final recurringInvoice = false.obs;

  /*void toggleAutoGenerate(bool value) {
    autoGenerate.value = value;
  }*/

  void toggleAutoGenerate(bool value) {
    autoGenerate.value = value;

    if (value) {
      final invoiceDate = _getInvoiceDate();

      invoiceNumberController.text =
          generateInvoiceNumber(date: invoiceDate);
    } else {
      invoiceNumberController.clear();
    }
  }

  void toggleEnableVat(bool value) {
    enableVat.value = value;

    if (!value) {
      vatRateController.text = '0';
    } else {
      if (vatRateController.text.trim().isEmpty ||
          vatRateController.text.trim() == '0') {
        vatRateController.text = '';
      }
    }
  }

  void toggleRecurringInvoice(bool value) {
    recurringInvoice.value = value;
  }

  // ============================================================
  // LINE ITEM
  // ============================================================

  final descriptionController = TextEditingController();
  final unitController = TextEditingController();
  final quantityController = TextEditingController();
  final unitPriceController = TextEditingController();

  final lineItems = <Map<String, dynamic>>[].obs;

  // ============================================================
  // CLOSING TEXT
  // ============================================================

  final closingTextController = TextEditingController();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    sessionEmail.value = SessionManager.email ?? '';
    // Get List Clients
    getClients();
    // Get List Item
    getCatalog();
    // Get List Companies
    getCompanies();
    // Get List Units
    getUnits();

    if (autoGenerate.value) {
      invoiceNumberController.text = generateInvoiceNumber();
    }
  }

  // ============================================================
  // GET CLIENTS
  // ============================================================

  Future<void> getClients({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      isLoading.value = true;

      final accessToken =
          SessionManager.accessToken;

      final companyId =
          SessionManager.accessCompanyid;

      // ----------------------------------------------------------
      // ACCESS TOKEN
      // ----------------------------------------------------------
      if (accessToken == null ||
          accessToken.isEmpty) {
        isLoading.value = false;
        AppSnackbar.error(
          title: 'Error',
          message:
          'Access token is not available.',
        );

        return;
      }

      // ----------------------------------------------------------
      // COMPANY ID
      // ----------------------------------------------------------
      if (companyId == null) {
        isLoading.value = false;

        AppSnackbar.error(
          title: 'Error',
          message:
          'Company ID is not available.',
        );

        return;
      }

      final int companyIdInt =
      int.parse(companyId.toString());


      // ----------------------------------------------------------
      // API
      // ----------------------------------------------------------

      final response =
      await dioClient.getClientsScreen(
        companyId: companyIdInt,
        accessToken: accessToken,
        page: page,
        pageSize: pageSize,
      );

      print('Clients Response: ${response.data}',);

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      if (response.statusCode == 200) {

        isLoading.value = false;

        final List<dynamic> data = response.data;

        final List<ClientScreenModel> fetchedClients =
        data
            .map(
              (json) => ClientScreenModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
            .toList();

        // Save all clients
        clients.assignAll(fetchedClients);

        clientNames.assignAll(
          fetchedClients
              .where(
                (client) =>
            (client.name ?? '').trim().isNotEmpty,
          )
              .map(
                (client) =>
            '${client.name!.trim()} - ${client.id}',
          )
              .toList(),
        );

        currentPage.value = page;
        this.pageSize.value = pageSize;
      } else {
        clients.clear();

        clientNames.clear();

        isLoading.value = false;

        AppSnackbar.error(
          title: 'Error',
          message:
          'Unable to load clients.',
        );
      }
    } catch (e) {
      clients.clear();

      clientNames.clear();

      isLoading.value = false;

      print(
        'Get Clients Error: $e',
      );

      AppSnackbar.error(
        title: 'Error',
        message:
        'Unable to load clients.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // SELECT CLIENT
  // ============================================================

  void selectClient(String? value) {
    if (value == null || value.trim().isEmpty) {
      return;
    }

    selectedClientName.value = value;

    final client = clients.firstWhereOrNull(
          (item) => '${item.name?.trim()} - ${item.id}' == value,
    );

    if (client == null) {
      selectedClient.value = null;
      _clearClientFields();
      return;
    }

    selectedClient.value = client;

    _setClientField(
      customerController,
      client.name,
    );

    _setClientField(
      addressController,
      client.addressLine1,
    );

    _setClientField(
      zipController,
      client.postalCode,
    );

    _setClientField(
      cityController,
      client.city,
    );

    _setClientField(
      attnController,
      client.contactName,
    );

    _setClientField(
      emailController,
      client.email,
    );

    _setClientField(
      phoneController,
      client.phone,
    );
  }

  void _setClientField(
      TextEditingController controller,
      String? value,
      ) {
    controller.text = value?.trim() ?? '';
  }

  void _clearClientFields() {
    customerController.clear();
    addressController.clear();
    zipController.clear();
    cityController.clear();
    attnController.clear();
    emailController.clear();
    phoneController.clear();
  }

  // ============================================================
  // STEPPER - NEXT
  // ============================================================

  void nextStep() {
    if (!validateCurrentStep()) {
      return;
    }

    if (currentStep.value <
        totalSteps - 1) {
      currentStep.value++;
    } else {
      saveData();
    }
  }

  // ============================================================
  // STEPPER - BACK
  // ============================================================

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  // ============================================================
  // STEPPER - GO TO STEP
  // ============================================================

  void goToStep(int step) {
    if (step <= currentStep.value) {
      currentStep.value = step;
    }
  }

  // ============================================================
  // VALIDATE CURRENT STEP
  // ============================================================

  bool validateCurrentStep() {
    switch (currentStep.value) {
    // --------------------------------------------------------
    // STEP 1 - SENDER
    // --------------------------------------------------------

      case 0:
        if (selectedCompany.value == null) {
          AppSnackbar.error(
            title: 'Required',
            message:
            'Please select a sender.',
          );

          return false;
        }

        return true;

    // --------------------------------------------------------
    // STEP 2 - CLIENT
    // --------------------------------------------------------

      case 1:
        if (selectedClient.value ==
            null) {
          AppSnackbar.error(
            title: 'Required',
            message:
            'Please select a client.',
          );

          return false;
        }

        return true;

    // --------------------------------------------------------
    // STEP 3 - INVOICE
    // --------------------------------------------------------

      case 2:
        if (invoiceDateController.text
            .trim()
            .isEmpty) {
          AppSnackbar.error(
            title: 'Required',
            message:
            'Please select invoice date.',
          );

          return false;
        }

        if (!autoGenerate.value &&
            invoiceNumberController.text
                .trim()
                .isEmpty) {
          AppSnackbar.error(
            title: 'Required',
            message:
            'Please enter invoice number.',
          );

          return false;
        }

        return true;

    // --------------------------------------------------------
    // STEP 4 - ITEMS
    // --------------------------------------------------------

      case 3:
        if (lineItems.isEmpty) {
          AppSnackbar.error(
            title: 'Required',
            message:
            'Please add at least one line item.',
          );

          return false;
        }

        return true;

      default:
        return true;
    }
  }

  // ============================================================
  // SELECT INVOICE DATE
  // ============================================================

  Future<void> selectInvoiceDate() async {
    final DateTime? pickedDate =
    await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      invoiceDateController.text =
      '${pickedDate.day.toString().padLeft(2, '0')}.'
          '${pickedDate.month.toString().padLeft(2, '0')}.'
          '${pickedDate.year}';
    }
  }

  // ============================================================
  // ADD LINE
  // ============================================================

  void addLine() {
    final description = descriptionController.text.trim();
    final quantityText = quantityController.text.trim();
    final unitPriceText = unitPriceController.text.trim();
    final unit = unitController.text.trim();

    if (description.isEmpty) {
      AppSnackbar.error(
        title: 'Required',
        message: 'Please enter item description.',
      );
      return;
    }

    if (quantityText.isEmpty) {
      AppSnackbar.error(
        title: 'Required',
        message: 'Please enter quantity.',
      );
      return;
    }

    if (unitPriceText.isEmpty) {
      AppSnackbar.error(
        title: 'Required',
        message: 'Please enter unit price.',
      );
      return;
    }

    final quantity = double.tryParse(
      quantityText.replaceAll(',', '.'),
    );

    final unitPrice = double.tryParse(
      unitPriceText.replaceAll(',', '.'),
    );

    if (quantity == null || quantity <= 0) {
      AppSnackbar.error(
        title: 'Invalid quantity',
        message: 'Please enter a valid quantity.',
      );
      return;
    }

    if (unitPrice == null || unitPrice < 0) {
      AppSnackbar.error(
        title: 'Invalid price',
        message: 'Please enter a valid unit price.',
      );
      return;
    }

    // VAT rate
   // final vatRate = enableVat.value ? 20.0 : 0.0;

    // VAT rate
    double vatRate = 0.0;

    if (enableVat.value) {
      vatRate = double.tryParse(
        vatRateController.text.trim().replaceAll(',', '.'),
      ) ??
          0.0;

      if (vatRate < 0 || vatRate > 100) {
        AppSnackbar.error(
          title: 'Invalid VAT',
          message: 'Please enter a VAT rate between 0% and 100%.',
        );
        return;
      }
    }

    // Net amount
    final netAmount = quantity * unitPrice;

    // Gross amount
    final grossAmount = netAmount + (netAmount * vatRate / 100);

    lineItems.add({
      'catalog_item_id': selectedCatalogItem.value?.id,
      'item_desc': description,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'unit_price': unitPrice,
      'unitPrice': unitPrice,
      'vat_rate': vatRate,
      'gross_amount': grossAmount,
      'total': grossAmount,
    });

    // Reset selected catalog item
    selectedCatalogItem.value = null;

    descriptionController.clear();
    unitController.clear();
  }

  // ============================================================
  // REMOVE LINE
  // ============================================================

  void removeLine(int index) {
    if (index >= 0 &&
        index < lineItems.length) {
      lineItems.removeAt(index);
    }
  }

  // ============================================================
  // SUBTOTAL
  // ============================================================
  double get subtotal {
    return lineItems.fold(
      0.0,
          (sum, item) {
        return sum +
            ((item['gross_amount'] as num?)?.toDouble() ?? 0.0);
      },
    );
  }

  String? _formatInvoiceDateForApi(String value) {
    if (value.trim().isEmpty) {
      return null;
    }

    try {
      final parts = value.trim().split('.');

      if (parts.length != 3) {
        return null;
      }

      final day = parts[0].padLeft(2, '0');
      final month = parts[1].padLeft(2, '0');
      final year = parts[2];

      return '$year-$month-$day';
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> saveData() async {
    if (isLoading.value) {
      return;
    }

    // ============================================================
    // BASIC VALIDATION
    // ============================================================

    if (selectedCompany.value == null) {
      AppSnackbar.error(
        title: 'Required',
        message: 'Please select a sender.',
      );
      return;
    }

    if (selectedClient.value == null) {
      AppSnackbar.error(
        title: 'Required',
        message: 'Please select a client.',
      );
      return;
    }

    if (invoiceDateController.text.trim().isEmpty) {
      AppSnackbar.error(
        title: 'Required',
        message: 'Please select invoice date.',
      );
      return;
    }

    if (lineItems.isEmpty) {
      AppSnackbar.error(
        title: 'Required',
        message: 'Please add at least one line item.',
      );
      return;
    }

    final accessToken = SessionManager.accessToken;

    if (accessToken == null || accessToken.isEmpty) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Access token is not available.',
      );
      return;
    }

    // ============================================================
    // COMPANY ID
    // ============================================================

    final companyId = selectedCompany.value?.id;

    if (companyId == null) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Company ID is not available.',
      );
      return;
    }

    // ============================================================
    // CLIENT ID
    // ============================================================

    final clientId = selectedClient.value?.id;

    if (clientId == null) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Client ID is not available.',
      );
      return;
    }

    // ============================================================
    // INVOICE DATE
    // ============================================================

    final issueDate = _formatInvoiceDateForApi(
      invoiceDateController.text,
    );

    if (issueDate == null) {
      AppSnackbar.error(
        title: 'Invalid date',
        message: 'Please select a valid invoice date.',
      );
      return;
    }

    // ============================================================
    // INVOICE NUMBER
    // ============================================================

    final invoiceNumber = invoiceNumberController.text.trim();

    print('Auto Gene:---- $invoiceNumber');

    if (!autoGenerate.value && invoiceNumber.isEmpty) {
      AppSnackbar.error(
        title: 'Required',
        message: 'Please enter invoice number.',
      );
      return;
    }

    try {
      isLoading.value = true;

      // ============================================================
      // BUILD ITEMS
      // ============================================================

      final List<Map<String, dynamic>> items =
      lineItems.map((item) {
        final map = <String, dynamic>{
          'item_desc':
          item['item_desc']?.toString() ?? '',
          'quantity':
          (item['quantity'] as num?)?.toDouble() ?? 0,
          'unit_price':
          (item['unit_price'] as num?)?.toDouble() ?? 0,
          'vat_rate':
          (item['vat_rate'] as num?)?.toDouble() ?? 0,
          'gross_amount':
          (item['gross_amount'] as num?)?.toDouble() ?? 0,
        };

        final catalogItemId = item['catalog_item_id'];

        if (catalogItemId != null) {
          map['catalog_item_id'] = catalogItemId;
        }

        return map;
      }).toList();

      // ============================================================
      // BUILD PAYLOAD
      // ============================================================

      final Map<String, dynamic> payload = {
        'company_id': companyId,
        'client_id': clientId,

        // If auto generation is enabled, backend should generate it.
        // If backend requires a string, send empty string.
        'invoice_number': autoGenerate.value
            ? invoiceNumberController.text.trim()
            : invoiceNumber,

        'issue_date': issueDate,

        'due_date': null,

        'notes': closingTextController.text.trim().isEmpty
            ? null
            : closingTextController.text.trim(),

        'notes_pre': null,

        'notes_post': null,

        'layout_order': [
          'pretext',
          'items',
          'posttext',
        ],

        'items': items,
      };

      /*debugPrint(
        '========== INVOICE PAYLOAD ==========\n'
            '${JsonEncoder.withIndent('  ').convert(payload)}\n'
            '=====================================',
      );*/

      // ============================================================
      // RECURRING SCHEDULE
      // ============================================================

      if (recurringInvoice.value) {
        payload['schedule'] = {
          'enabled': true,
          'frequency': 'monthly',
          'interval': 1,
          'startDate': issueDate,
          'endType': 'never',
          'autoSendEmail': false,
        };
      }

      // ============================================================
      // API CALL
      // ============================================================

      final response = await dioClient.createInvoice(
        accessToken: accessToken,
        data: payload,
      );

      print('Create Invoice Status: ${response.statusCode}');
      print('Create Invoice Response: ${response.data}');

      // ============================================================
      // SUCCESS
      // ============================================================

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final responseData = response.data;

        print('Invoice created successfully.');
        print('Invoice ID: ${responseData['id']}');
        print(
          'Invoice Number: ${responseData['invoice_number']}',
        );

        AppSnackbar.success(
          title: 'Success',
          message: 'Invoice created successfully.',
        );

        // Small delay so the success message is visible
        await Future.delayed(
          const Duration(milliseconds: 500),
        );

        Get.back(result: responseData);
      } else {
        AppSnackbar.error(
          title: 'Error',
          message: 'Unable to create invoice.',
        );
      }
    } on DioException catch (e) {
      print('==============================');
      print('CREATE INVOICE ERROR');
      print('==============================');
      print('Message: ${e.message}');
      print('Status: ${e.response?.statusCode}');
      print('Response: ${e.response?.data}');
      print('==============================');

      String message = 'Unable to create invoice.';

      final responseData = e.response?.data;

      if (responseData is Map<String, dynamic>) {
        if (responseData['detail'] != null) {
          message = responseData['detail'].toString();
        } else if (responseData['message'] != null) {
          message = responseData['message'].toString();
        } else if (responseData['error'] != null) {
          message = responseData['error'].toString();
        }
      }

      AppSnackbar.error(
        title: 'Error',
        message: message,
      );
    } catch (e) {
      print('Create Invoice Error: $e');

      AppSnackbar.error(
        title: 'Error',
        message: 'Unable to create invoice.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void onClose() {
    customerController.dispose();
    addressController.dispose();
    zipController.dispose();
    cityController.dispose();
    attnController.dispose();
    emailController.dispose();
    phoneController.dispose();

    invoiceNumberController.dispose();
    invoiceDateController.dispose();

    descriptionController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
    vatRateController.dispose();

    closingTextController.dispose();

    super.onClose();
  }

  // ============================================================
  // GET CATALOG
  // ============================================================

  Future<void> getCatalog({
    int page = 1,
    int pageSize = 10,
  }) async
  {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      if (accessToken == null || accessToken.isEmpty) {
        errorMessage.value = 'Access token is not available.';

        AppSnackbar.error(
          title: 'Error',
          message: 'Access token is not available.',
        );

        return;
      }

      if (companyId == null) {
        errorMessage.value = 'Company ID is not available.';

        AppSnackbar.error(
          title: 'Error',
          message: 'Company ID is not available.',
        );

        return;
      }

      final companyIdInt = int.parse(companyId.toString());

      final response = await dioClient.getCatalog(
        companyId: companyIdInt,
        accessToken: accessToken,
        page: page,
        pageSize: pageSize,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        final fetchedCatalog = data
            .map(
              (json) => CatalogModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
            .toList();

        catalogList.assignAll(fetchedCatalog);

        catalogNames.assignAll(
          fetchedCatalog
              .map((item) => item.articleName?.trim() ?? '')
              .where((name) => name.isNotEmpty)
              .toList(),
        );

        currentPage.value = page;
        this.pageSize.value = pageSize;
      } else {
        catalogList.clear();
        catalogNames.clear();

        errorMessage.value = 'Unable to load items.';

        AppSnackbar.error(
          title: 'Error',
          message: 'Unable to load items.',
        );
      }
    } catch (e) {
      catalogList.clear();
      catalogNames.clear();

      errorMessage.value = 'Unable to load items.';

      print('Get Catalog Error: $e');

      AppSnackbar.error(
        title: 'Error',
        message: 'Unable to load items.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void selectCatalogItem(String? value) {
    if (value == null || value.trim().isEmpty) {
      return;
    }

    final item = catalogList.firstWhereOrNull(
          (catalog) => catalog.articleName?.trim() == value.trim(),
    );

    if (item == null) {
      return;
    }

    selectedCatalogItem.value = item;

    // Description
    descriptionController.text = item.articleName ?? '';

    // Unit
    if (item.unitCode != null) {
      unitController.text =
          item.unitCode!.toString();
    }

    // Unit price
    if (item.unitPriceNet != null) {
      unitPriceController.text =
          item.unitPriceNet!.toString();
    }
  }

  // ============================================================
  // GET COMPANIES
  // ============================================================

  Future<void> getCompanies() async {

    try {

      isLoading.value = true;

      final accessToken = SessionManager.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        print("Access token not found");
        return;
      }

      final response = await dioClient.getCompanies(
        accessToken: accessToken,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        final fetchedCompanies = data
            .map(
              (json) => CompanyModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
            .toList();

        companies.assignAll(fetchedCompanies);

        // Create dropdown names
        companyNames.assignAll(
          companies
              .map((company) => company.name?.trim() ?? '')
              .where((name) => name.isNotEmpty)
              .toList(),
        );

        print("Companies loaded: ${companies.length}");
        print("Company names: $companyNames");

        // Select company from SessionManager
        final sessionCompanyId = SessionManager.accessCompanyid;

        if (sessionCompanyId != null) {
          final company = companies.firstWhereOrNull(
                (company) => company.id.toString() == sessionCompanyId.toString(),
          );

          if (company != null) {
            selectedCompany.value = company;
          }
        }

        // If no company is selected, select first company
        if (selectedCompany.value == null && companies.isNotEmpty) {
          await selectCompany(
            companies.first,
            loadDashboard: false,
          );
        }
      }

    } on DioException catch (e) {

      print("Companies API Error: ${e.message}");

      AppSnackbar.error(
        title: 'Error',
        message: e.response?.data?.toString() ??
            e.message ??
            'Unable to load companies',
      );

    } catch (e) {

      print("Companies Error: $e");

      AppSnackbar.error(
        title: 'Error',
        message: e.toString(),
      );

    } finally {

      isLoading.value = false;
    }
  }


  // ============================================================
  // SELECT COMPANY
  // ============================================================

  Future<void> selectCompanyByName(String? value) async {
    if (value == null || value.trim().isEmpty) {
      return;
    }

    final company = companies.firstWhereOrNull(
          (company) => company.name?.trim() == value.trim(),
    );

    if (company == null) {
      return;
    }

    await selectCompany(
      company,
      loadDashboard: false,
    );
  }

  Future<void> selectCompany(
      CompanyModel company, {
        bool loadDashboard = true,
      }) async
  {
    selectedCompany.value = company;

    await SessionManager.saveCompanyid(company.id);

    print("Selected company: ${company.name}");
    print("Selected company ID: ${company.id}");

    if (loadDashboard) {
      // Load dashboard if required
    }
  }

  // ============================================================
  // GET UNITS
  // ============================================================

  Future<void> getUnits() async {
    try {
      final accessToken = SessionManager.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        return;
      }

      final response = await dioClient.getUnits(
        accessToken: accessToken,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        final loadedUnits = data
            .map(
              (json) => UnitModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
            .where(
              (unit) =>
          unit.code.trim().isNotEmpty &&
              unit.label.trim().isNotEmpty,
        )
            .toList();

        units.assignAll(loadedUnits);

        // Remove duplicate labels.
        final uniqueLabels = <String>[];

        for (final unit in loadedUnits) {
          final label = unit.label.trim();

          if (!uniqueLabels.contains(label)) {
            uniqueLabels.add(label);
          }
        }

        unitNames.assignAll(uniqueLabels);
      }
    } catch (e) {
      debugPrint('Get Units Error: $e');
      units.clear();
      unitNames.clear();
    }
  }

  // ============================================================
  // SELECT UNIT
  // ============================================================
  void selectUnit(String? value) {
    if (value == null || value.trim().isEmpty) {
      selectedUnit.value = null;
      unitController.clear();
      return;
    }

    final selected = units.firstWhereOrNull(
      (unit) =>
          unit.label.trim().toLowerCase() == value.trim().toLowerCase() ||
          unit.code.trim().toLowerCase() == value.trim().toLowerCase(),
    );

    if (selected != null) {
      selectedUnit.value = selected;
      unitController.text = selected.code;
    } else {
      selectedUnit.value = null;
      unitController.text = value.trim();
    }

    debugPrint('Selected Unit Label: ${selected?.label ?? value}');
    debugPrint('Selected Unit Code: ${unitController.text}');
  }

  DateTime _getInvoiceDate() {
    final value = invoiceDateController.text.trim();

    if (value.isEmpty) {
      return DateTime.now();
    }

    try {
      final parts = value.split('.');

      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (e) {
      debugPrint('Invoice date parse error: $e');
    }

    return DateTime.now();
  }

  // ============================================================
// GENERATE INVOICE NUMBER
// ============================================================

  String generateInvoiceNumber({DateTime? date}) {
    final invoiceDate = date ?? DateTime.now();

    final year = invoiceDate.year.toString().substring(2);
    final month = invoiceDate.month.toString().padLeft(2, '0');
    final day = invoiceDate.day.toString().padLeft(2, '0');

    // Random 4-digit number
    final random = Random();
    final randomNumber =
    random.nextInt(10000).toString().padLeft(4, '0');

    return 'INVM-$year$month$day' '00-$randomNumber';
  }

}