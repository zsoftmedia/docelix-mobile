import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateInvoiceController extends GetxController {
  final isLoading = false.obs;

  // --------------------------------------------------
  // Sender
  // --------------------------------------------------

  final senders = <String>[
    'CFC KP',
  ].obs;

  final selectedSender = RxnString();

  void selectSender(String? value) {
    selectedSender.value = value;
  }

  // --------------------------------------------------
  // Client
  // --------------------------------------------------

  final customerController = TextEditingController();
  final addressController = TextEditingController();
  final zipController = TextEditingController();
  final cityController = TextEditingController();
  final attnController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  void selectClient() {
    // Open your client selection screen/dialog here.
    //
    // Example:
    // Get.toNamed('/ClientsScreen');
  }

  // --------------------------------------------------
  // Invoice
  // --------------------------------------------------

  final invoiceNumberController = TextEditingController();
  final invoiceDateController = TextEditingController();

  final autoGenerate = true.obs;
  final enableVat = false.obs;
  final recurringInvoice = false.obs;

  void selectInvoiceDate() async {
    final DateTime? pickedDate = await showDatePicker(
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

  // --------------------------------------------------
  // Line Item
  // --------------------------------------------------

  final descriptionController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final unitPriceController = TextEditingController(text: '0');

  final units = <String>[
    'pcs',
    'hours',
    'kg',
    'm',
    'days',
  ].obs;

  final selectedUnit = RxnString();

  // ============================================================
  // ADDED LINE ITEMS
  // ============================================================

  final lineItems = <Map<String, dynamic>>[].obs;

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
    final description = descriptionController.text.trim();
    final quantityText = quantityController.text.trim();
    final unitPriceText = unitPriceController.text.trim();

    if (description.isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter item description.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (quantityText.isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter quantity.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedUnit.value == null ||
        selectedUnit.value!.trim().isEmpty) {
      Get.snackbar(
        'Required',
        'Please select unit.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (unitPriceText.isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter unit price.',
        snackPosition: SnackPosition.BOTTOM,
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
      Get.snackbar(
        'Invalid quantity',
        'Please enter a valid quantity.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (unitPrice == null || unitPrice < 0) {
      Get.snackbar(
        'Invalid price',
        'Please enter a valid unit price.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final total = quantity * unitPrice;

    lineItems.add({
      'description': description,
      'quantity': quantity,
      'unit': selectedUnit.value,
      'unitPrice': unitPrice,
      'total': total,
    });

    // Clear fields for next item
    descriptionController.clear();
    quantityController.text = '1';
    unitPriceController.text = '0';
    selectedUnit.value = null;
  }

  // ============================================================
  // REMOVE LINE
  // ============================================================

  void removeLine(int index) {
    if (index >= 0 && index < lineItems.length) {
      lineItems.removeAt(index);
    }
  }

  // ============================================================
  // SUBTOTAL
  // ============================================================

  double get subtotal {
    return lineItems.fold(
      0.0,
          (sum, item) =>
      sum + ((item['total'] as num?)?.toDouble() ?? 0.0),
    );
  }


  // --------------------------------------------------
  // Closing Text
  // --------------------------------------------------

  final closingTextController = TextEditingController();

  // --------------------------------------------------
  // Save
  // --------------------------------------------------

  Future<void> saveData() async {
    try {
      isLoading.value = true;

      // Your save API logic goes here.

      print('Customer: ${customerController.text}');
      print('Address: ${addressController.text}');
      print('ZIP: ${zipController.text}');
      print('City: ${cityController.text}');
      print('Attn: ${attnController.text}');
      print('Email: ${emailController.text}');
      print('Phone: ${phoneController.text}');

      print('Invoice Number: ${invoiceNumberController.text}');
      print('Invoice Date: ${invoiceDateController.text}');

      print('Description: ${descriptionController.text}');
      print('Quantity: ${quantityController.text}');
      print('Unit: ${selectedUnit.value}');
      print('Unit Price: ${unitPriceController.text}');

      print('Closing Text: ${closingTextController.text}');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to save invoice.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --------------------------------------------------
  // Dispose
  // --------------------------------------------------

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