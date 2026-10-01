
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddItemController extends GetxController {
  final RxInt currentStep = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool trackStock = false.obs;

  // Basic information
  final nameController = TextEditingController();
  final articleNumberController = TextEditingController();
  final groupCodeController = TextEditingController();
  final descriptionController = TextEditingController();

  // Unit and quantity
  final unitSearchController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final stockController = TextEditingController(text: '1');
  final minimumStockController = TextEditingController(text: '0');

  // Pricing
  final costPriceController = TextEditingController(text: '0');
  final salePriceController = TextEditingController(text: '0');
  final vatController = TextEditingController(text: '20');
  final discountController = TextEditingController(text: '0');
  final msrpController = TextEditingController(text: '0');

  final RxString selectedUnit = 'Ad set (adset)'.obs;
  final RxString selectedItemType = 'Physical material'.obs;

  final RxString selectedUnitFilter = ''.obs;

  final List<String> unitOptions = [
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

  final List<String> itemTypes = [
    'Physical material',
    'Service',
    'Digital product',
  ];

  List<String> get filteredUnits {
    final query = unitSearchController.text.trim().toLowerCase();

    if (query.isEmpty) return unitOptions;

    return unitOptions
        .where((unit) => unit.toLowerCase().contains(query))
        .toList();
  }

  void selectUnit(String? value) {
    if (value != null) {
      selectedUnit.value = value;
    }
  }

  void selectItemType(String? value) {
    if (value != null) {
      selectedItemType.value = value;
    }
  }

  void toggleStock(bool value) {
    trackStock.value = value;
  }

  void nextStep() {
    if (!validateStep(currentStep.value)) return;

    if (currentStep.value < 2) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    } else {
      Get.back();
    }
  }

  bool validateStep(int step) {
    switch (step) {
      case 0:
        if (nameController.text.trim().isEmpty) {

          AppSnackbar.error(
              title: 'Required field',
              message: 'Please enter the item name.');

          return false;
        }
        return true;

      case 1:
        if (selectedUnit.value.isEmpty) {

          AppSnackbar.error(
              title: 'Required field',
              message: 'Please select a measurement unit.');

          return false;
        }

        if (!_isValidNumber(quantityController.text) ||
            _number(quantityController.text) <= 0) {

          AppSnackbar.error(
              title: 'Invalid quantity',
              message: 'Default quantity must be greater than zero.');

          return false;
        }

        if (trackStock.value &&
            (!_isValidNumber(stockController.text) ||
                _number(stockController.text) < 0)) {

          AppSnackbar.error(
              title: 'Invalid stock',
              message: 'Please enter a valid stock quantity.');

          return false;
        }

        return true;

      case 2:
        final fields = {
          'Cost price': costPriceController.text,
          'Sale price': salePriceController.text,
          'VAT': vatController.text,
          'Discount': discountController.text,
          'MSRP': msrpController.text,
        };

        for (final entry in fields.entries) {
          if (!_isValidNumber(entry.value) || _number(entry.value) < 0) {

            AppSnackbar.error(
                title: 'Invalid value',
                message: '${entry.key} must be a valid non-negative number.');

            return false;
          }
        }

        if (_number(vatController.text) > 100 ||
            _number(discountController.text) > 100) {

          AppSnackbar.error(
              title: 'Invalid percentage',
              message: 'VAT and discount must be between 0 and 100.');

          return false;
        }

        return true;

      default:
        return true;
    }
  }

  bool _isValidNumber(String value) {
    return double.tryParse(value.trim()) != null;
  }

  double _number(String value) {
    return double.tryParse(value.trim()) ?? 0;
  }

  Map<String, dynamic> get itemPayload {
    return {
      'name': nameController.text.trim(),
      'article_number': articleNumberController.text.trim(),
      'group_code': groupCodeController.text.trim(),
      'description': descriptionController.text.trim(),
      'unit': selectedUnit.value,
      'unit_search': unitSearchController.text.trim(),
      'default_quantity': _number(quantityController.text),
      'item_type': selectedItemType.value,
      'track_stock': trackStock.value,
      'stock_in_store':
      trackStock.value ? _number(stockController.text) : null,
      'minimum_stock_alert_threshold':
      trackStock.value ? _number(minimumStockController.text) : null,
      'cost_price': _number(costPriceController.text),
      'sale_price': _number(salePriceController.text),
      'vat_percent': _number(vatController.text),
      'discount_percent': _number(discountController.text),
      'msrp': _number(msrpController.text),
    };
  }

  Future<void> saveItem() async {
    if (!validateStep(0) ||
        !validateStep(1) ||
        !validateStep(2)) {
      // Return to the first invalid step.
      if (nameController.text.trim().isEmpty) {
        currentStep.value = 0;
      } else if (!_isValidNumber(quantityController.text) ||
          _number(quantityController.text) <= 0 ||
          (trackStock.value &&
              (!_isValidNumber(stockController.text) ||
                  _number(stockController.text) < 0))) {
        currentStep.value = 1;
      } else {
        currentStep.value = 2;
      }
      return;
    }

    debugPrint('Item payload: $itemPayload');

    AppSnackbar.success(
        title: 'Ready to save',
        message: 'Validation completed. Connect the create-item API to save this item.');

  }

  @override
  void onClose() {
    nameController.dispose();
    articleNumberController.dispose();
    groupCodeController.dispose();
    descriptionController.dispose();
    unitSearchController.dispose();
    quantityController.dispose();
    stockController.dispose();
    minimumStockController.dispose();
    costPriceController.dispose();
    salePriceController.dispose();
    vatController.dispose();
    discountController.dispose();
    msrpController.dispose();
    super.onClose();
  }
}