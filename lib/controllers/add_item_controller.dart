import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/catalog_controller.dart';
import 'package:docelix_mobileapp/models/unit_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddItemController extends GetxController {
  final DioClient dioClient = DioClient();
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

  // ============================================================
  // UNITS
  // ============================================================
  final RxList<UnitModel> units = <UnitModel>[].obs;
  final RxList<String> unitNames = <String>[].obs;
  final Rxn<UnitModel> selectedUnitModel = Rxn<UnitModel>();
  final RxnString selectedUnit = RxnString('Ad set (adset)');
  final RxString unitSearchQuery = ''.obs;

  final RxString selectedItemType = 'Physical material'.obs;
  final RxString selectedUnitFilter = ''.obs;

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

  final List<String> itemTypes = const [
    'Physical material',
    'Service',
    'Digital product',
  ];

  List<String> get availableUnits {
    if (unitNames.isNotEmpty) return unitNames;
    return unitOptions;
  }

  String? get currentSelectedUnit {
    final val = selectedUnit.value;
    if (val != null && availableUnits.contains(val)) {
      return val;
    }
    return availableUnits.isNotEmpty ? availableUnits.first : null;
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

  @override
  void onInit() {
    super.onInit();
    getUnits();
  }

  // ============================================================
  // GET UNITS FROM API
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

        final uniqueLabels = <String>[];

        for (final unit in loadedUnits) {
          final label = unit.label.trim();

          if (!uniqueLabels.contains(label)) {
            uniqueLabels.add(label);
          }
        }

        unitNames.assignAll(uniqueLabels);

        if (uniqueLabels.isNotEmpty &&
            (selectedUnit.value == null ||
                !uniqueLabels.contains(selectedUnit.value))) {
          selectUnit(uniqueLabels.first);
        }
      }
    } catch (e) {
      debugPrint('Get Units Error: $e');
    }
  }

  // ============================================================
  // SELECT UNIT
  // ============================================================
  void selectUnit(String? value) {
    if (value == null || value.trim().isEmpty) {
      selectedUnit.value = null;
      selectedUnitModel.value = null;
      return;
    }

    selectedUnit.value = value;

    final foundUnit = units.firstWhereOrNull(
      (u) => u.label.trim() == value.trim() || u.code.trim() == value.trim(),
    );

    selectedUnitModel.value = foundUnit;

    debugPrint('Selected Unit Label: $value');
    debugPrint('Selected Unit Code: ${foundUnit?.code}');
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
              title: 'Required field', message: 'Please enter the item name.');
          return false;
        }
        return true;

      case 1:
        if (selectedUnit.value == null ||
            selectedUnit.value!.trim().isEmpty) {
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
    final companyId = int.tryParse(
      SessionManager.accessCompanyid.toString(),
    );

    if (companyId == null) {
      throw Exception('Invalid company ID');
    }

    final articleName = nameController.text.trim();
    final articleNumber = articleNumberController.text.trim();
    final groupCode = groupCodeController.text.trim();
    final description = descriptionController.text.trim();

    return {
      'company_id': companyId,
      'article_name': articleName,
      if (articleNumber.isNotEmpty) 'article_number': articleNumber,
      'description': description.isEmpty ? null : description,
      'unit_code': _getUnitCode(selectedUnit.value),
      'default_qty': _number(quantityController.text),
      'unit_price_net': _number(salePriceController.text),
      'purchase_price_net': _number(costPriceController.text),
      'unit_price_gross': null,
      'discount': _number(discountController.text),
      'group_code': groupCode.isEmpty ? null : groupCode,
      'price_msrp': _number(msrpController.text),
      'stock_qty': trackStock.value ? _number(stockController.text) : 0,
      'min_stock':
          trackStock.value ? _number(minimumStockController.text) : 0,
      'track_stock': trackStock.value,
      'item_type': _getApiItemType(selectedItemType.value),
      'vat_rate': _number(vatController.text),
    };
  }

  String _getUnitCode(String? value) {
    if (selectedUnitModel.value != null &&
        selectedUnitModel.value!.code.isNotEmpty) {
      return selectedUnitModel.value!.code;
    }
    if (value == null || value.trim().isEmpty) return 'adset';

    final match = RegExp(r'\(([^)]+)\)$').firstMatch(value);
    if (match != null) {
      return match.group(1)!.trim();
    }

    return value.trim().toLowerCase();
  }

  String _getApiItemType(String value) {
    switch (value) {
      case 'Physical material':
        return 'physical';
      case 'Software':
        return 'software';
      case 'Service':
        return 'service';
      case 'Digital product':
        return 'digital';
      default:
        return 'physical';
    }
  }

  Future<void> saveItem() async {
    if (isLoading.value) return;

    if (!validateStep(0)) {
      currentStep.value = 0;
      return;
    }

    if (!validateStep(1)) {
      currentStep.value = 1;
      return;
    }

    if (!validateStep(2)) {
      currentStep.value = 2;
      return;
    }

    final accessToken = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;

    if (accessToken == null || accessToken.toString().isEmpty) {
      AppSnackbar.error(
        title: 'Authentication Error',
        message: 'Please log in again to continue.',
      );
      return;
    }

    if (companyId == null || int.tryParse(companyId.toString()) == null) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Company information is not available.',
      );
      return;
    }

    isLoading.value = true;

    try {
      final payload = itemPayload;

      debugPrint('Creating catalogue item: $payload');

      final response = await dioClient.createCatalogItem(
        data: payload,
        accessToken: accessToken.toString(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        clearForm();

        Get.back(result: true);

        AppSnackbar.success(
          title: 'Success',
          message: 'Catalogue item created successfully.',
        );

        if (Get.isRegistered<CatalogController>()) {
          Get.find<CatalogController>().refreshCatalog();
        }
      } else {
        AppSnackbar.error(
          title: 'Error',
          message: 'Unable to create catalogue item.',
        );
      }
    } on DioException catch (e) {
      debugPrint('Create catalogue item error: ${e.message}');
      debugPrint('API response: ${e.response?.data}');

      final responseData = e.response?.data;
      String message = 'Unable to create catalogue item.';

      if (responseData is Map) {
        message = responseData['message']?.toString() ??
            responseData['error']?.toString() ??
            message;
      }

      AppSnackbar.error(
        title: 'Error',
        message: message,
      );
    } catch (e) {
      debugPrint('Unexpected create item error: $e');

      AppSnackbar.error(
        title: 'Error',
        message: 'Something went wrong while saving the item.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    currentStep.value = 0;
    trackStock.value = false;

    nameController.clear();
    articleNumberController.clear();
    groupCodeController.clear();
    descriptionController.clear();
    unitSearchController.clear();
    unitSearchQuery.value = '';

    quantityController.text = '1';
    stockController.text = '1';
    minimumStockController.text = '0';

    costPriceController.text = '0';
    salePriceController.text = '0';
    vatController.text = '20';
    discountController.text = '0';
    msrpController.text = '0';

    if (availableUnits.isNotEmpty) {
      selectUnit(availableUnits.first);
    } else {
      selectedUnit.value = 'Ad set (adset)';
      selectedUnitModel.value = null;
    }

    selectedItemType.value = 'Physical material';
    selectedUnitFilter.value = '';
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