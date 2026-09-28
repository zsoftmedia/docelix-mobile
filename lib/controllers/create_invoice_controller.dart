import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/clients_screen_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateInvoiceController extends GetxController {
  final DioClient dioClient = DioClient();

  // ============================================================
  // GENERAL
  // ============================================================

  final isLoading = false.obs;

  // ============================================================
  // CLIENT LIST
  // ============================================================

  final RxList<ClientScreenModel> clients =
      <ClientScreenModel>[].obs;

  /// Names shown inside dropdown
  final RxList<String> clientNames =
      <String>[].obs;

  /// Selected client name
  final RxnString selectedClientName =
  RxnString();

  /// Complete selected client object
  final Rxn<ClientScreenModel> selectedClient =
  Rxn<ClientScreenModel>();

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
  // SENDER
  // ============================================================

  final senders = <String>[
    'CFC KP',
  ].obs;

  final selectedSender = RxnString();

  void selectSender(String? value) {
    selectedSender.value = value;
  }

  // ============================================================
  // CLIENT TEXT CONTROLLERS
  // ============================================================

  final customerController =
  TextEditingController();

  final addressController =
  TextEditingController();

  final zipController =
  TextEditingController();

  final cityController =
  TextEditingController();

  final attnController =
  TextEditingController();

  final emailController =
  TextEditingController();

  final phoneController =
  TextEditingController();

  // ============================================================
  // INVOICE
  // ============================================================

  final invoiceNumberController =
  TextEditingController();

  final invoiceDateController =
  TextEditingController();

  final autoGenerate = true.obs;

  final enableVat = false.obs;

  final recurringInvoice = false.obs;

  void toggleAutoGenerate(bool value) {
    autoGenerate.value = value;
  }

  void toggleEnableVat(bool value) {
    enableVat.value = value;
  }

  void toggleRecurringInvoice(bool value) {
    recurringInvoice.value = value;
  }

  // ============================================================
  // LINE ITEM
  // ============================================================

  final descriptionController =
  TextEditingController();

  final quantityController =
  TextEditingController(text: '1');

  final unitPriceController =
  TextEditingController(text: '0');

  final units = <String>[
    'pcs',
    'hours',
    'kg',
    'm',
    'days',
  ].obs;

  final selectedUnit = RxnString();

  final lineItems =
      <Map<String, dynamic>>[].obs;

  // ============================================================
  // CLOSING TEXT
  // ============================================================

  final closingTextController =
  TextEditingController();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    getClients();
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
        AppSnackbar.error(
          title: 'Error',
          message:
          'Company ID is not available.',
        );

        return;
      }

      final int companyIdInt =
      int.parse(companyId.toString());

      print('==============================');
      print('GET CLIENTS');
      print('Company ID: $companyIdInt');
      print('Page: $page');
      print('Page Size: $pageSize');
      print('==============================');

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

      print(
        'Clients Response: ${response.data}',
      );

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      if (response.statusCode == 200) {
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

        AppSnackbar.error(
          title: 'Error',
          message:
          'Unable to load clients.',
        );
      }
    } catch (e) {
      clients.clear();

      clientNames.clear();

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
        if (selectedSender.value ==
            null ||
            selectedSender.value!
                .trim()
                .isEmpty) {
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
  // SELECT UNIT
  // ============================================================

  void selectUnit(String? value) {
    selectedUnit.value = value;
  }

  // ============================================================
  // ADD LINE
  // ============================================================

  void addLine() {
    final description =
    descriptionController.text.trim();

    final quantityText =
    quantityController.text.trim();

    final unitPriceText =
    unitPriceController.text.trim();

    // ----------------------------------------------------------
    // DESCRIPTION
    // ----------------------------------------------------------

    if (description.isEmpty) {
      AppSnackbar.error(
        title: 'Required',
        message:
        'Please enter item description.',
      );

      return;
    }

    // ----------------------------------------------------------
    // QUANTITY
    // ----------------------------------------------------------

    if (quantityText.isEmpty) {
      AppSnackbar.error(
        title: 'Required',
        message:
        'Please enter quantity.',
      );

      return;
    }

    // ----------------------------------------------------------
    // UNIT
    // ----------------------------------------------------------

    if (selectedUnit.value ==
        null ||
        selectedUnit.value!
            .trim()
            .isEmpty) {
      AppSnackbar.error(
        title: 'Required',
        message:
        'Please select unit.',
      );

      return;
    }

    // ----------------------------------------------------------
    // PRICE
    // ----------------------------------------------------------

    if (unitPriceText.isEmpty) {
      AppSnackbar.error(
        title: 'Required',
        message:
        'Please enter unit price.',
      );

      return;
    }

    // ----------------------------------------------------------
    // PARSE
    // ----------------------------------------------------------

    final quantity =
    double.tryParse(
      quantityText.replaceAll(
        ',',
        '.',
      ),
    );

    final unitPrice =
    double.tryParse(
      unitPriceText.replaceAll(
        ',',
        '.',
      ),
    );

    // ----------------------------------------------------------
    // QUANTITY VALIDATION
    // ----------------------------------------------------------

    if (quantity == null ||
        quantity <= 0) {
      AppSnackbar.error(
        title: 'Invalid quantity',
        message:
        'Please enter a valid quantity.',
      );

      return;
    }

    // ----------------------------------------------------------
    // PRICE VALIDATION
    // ----------------------------------------------------------

    if (unitPrice == null ||
        unitPrice < 0) {
      AppSnackbar.error(
        title: 'Invalid price',
        message:
        'Please enter a valid unit price.',
      );

      return;
    }

    // ----------------------------------------------------------
    // TOTAL
    // ----------------------------------------------------------

    final total =
        quantity * unitPrice;

    // ----------------------------------------------------------
    // ADD
    // ----------------------------------------------------------

    lineItems.add({
      'description': description,
      'quantity': quantity,
      'unit': selectedUnit.value,
      'unitPrice': unitPrice,
      'total': total,
    });

    // ----------------------------------------------------------
    // RESET
    // ----------------------------------------------------------

    descriptionController.clear();

    quantityController.text = '1';

    unitPriceController.text = '0';

    selectedUnit.value = null;
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
            ((item['total'] as num?)
                ?.toDouble() ??
                0.0);
      },
    );
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> saveData() async {
    if (isLoading.value) {
      return;
    }

    try {
      isLoading.value = true;

      print('==============================');
      print('CREATE INVOICE');
      print('==============================');

      print(
        'Sender: ${selectedSender.value}',
      );

      print(
        'Client: ${selectedClientName.value}',
      );

      print(
        'Customer: ${customerController.text}',
      );

      print(
        'Address: ${addressController.text}',
      );

      print(
        'ZIP: ${zipController.text}',
      );

      print(
        'City: ${cityController.text}',
      );

      print(
        'Attn: ${attnController.text}',
      );

      print(
        'Email: ${emailController.text}',
      );

      print(
        'Phone: ${phoneController.text}',
      );

      print(
        'Invoice Number: ${invoiceNumberController.text}',
      );

      print(
        'Invoice Date: ${invoiceDateController.text}',
      );

      print(
        'Auto Generate: ${autoGenerate.value}',
      );

      print(
        'Enable VAT: ${enableVat.value}',
      );

      print(
        'Recurring: ${recurringInvoice.value}',
      );

      print(
        'Line Items: ${lineItems.length}',
      );

      print(
        'Subtotal: $subtotal',
      );

      print(
        'Closing Text: ${closingTextController.text}',
      );

      print('==============================');

      // ========================================================
      // YOUR API SAVE LOGIC
      // ========================================================

      AppSnackbar.success(
        title: 'Success',
        message:
        'Invoice saved successfully.',
      );
    } catch (e) {
      print(
        'Save Invoice Error: $e',
      );

      AppSnackbar.error(
        title: 'Error',
        message:
        'Unable to save invoice.',
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

    closingTextController.dispose();

    super.onClose();
  }
}